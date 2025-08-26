/**
     * @description Class used in flow to generate a quote and send it by email when opp is closed won
	 * @Author: Maroun Al Hourani
     * @Company: EI-Technologies
	 * @<16/08/2025>
*/ 

public without sharing class generateQuotePdfDocument {



     /**
     * @description invocable method bcz its used in a flow. it should take a list and not a single Id
     * otherwise it doesnt work
     * param list of opp that triggered the flow, irl its 1 opp, we get it sinced 
     * quote and return its Id
     */  
    @InvocableMethod // to use in flow, 1 invocoble method in a class
    public static void QuoteCreateAndEmail(List<Id> oppIds) { 
        
        List<Quote> quoteList = [SELECT ID FROM Quote WHERE OpportunityId IN :oppIds AND IsSyncing = TRUE];

        if (!quoteList.isEmpty()) {
            for (Quote q : quoteList) 
                {
                CreateQuotePDF(q.Id);
                }
        }

    }
    
     /**
     * @description takes the quote Id, use it to generate a pdf, then send it by email
     */

    @future(callout=true)
    public static void CreateQuotePDF(Id quoteID) {
        
        Quote quoteRecord = [SELECT Id, AccountId FROM Quote WHERE Id = :quoteID LIMIT 1];
        Id accountId = quoteRecord.AccountId;
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :accountId];
        
        //This Url creates the pdf for quote
        String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?id=';
        quoteUrl += quoteID;
        quoteUrl += '&headerHeight=190&footerHeight=188&summlid=';
        quoteUrl += Label.quote_template_id; // found in setup -> quote template 
        quoteUrl += '#toolbar=1&navpanes=0&zoom=90';
        
        //Create pdf content 
        PageReference pg = new PageReference(quoteUrl);
        System.Debug('fff' + pg);
        
        //Document object of quote which holds the quote pdf
        //quote document holds the actual quote and metadata about it
        //the we need to assign to this object, some information, then we need to insert it
        QuoteDocument quotedoc = new QuoteDocument();
        

        //this or (for testing purposes)
        Blob b;
        if (!Test.isRunningTest()) {
            b = pg.getContentAsPDF();
        } else {
            // simulate pdf in test context
            b = Blob.valueOf('FakePDF');
        }

        //this
        //Get the content of Pdf.
        // Blob b = pg.getContentAsPDF();// getcontent is async
        
        //content assign to document
        quotedoc.Document = b;
        
        //assign quote id where pdf should attach
        quotedoc.QuoteId = QuoteID;
        //www.youtube.com/feed/downloads
        //insert the quotdoc
        insert quotedoc;
        for (Contact c: contacts){
            SendEmail(quoteID, Label.emailtemplateIdtosendPDF,c.Email ,c.Id  , quotedoc.Id );
            
        }
        
    }
    
    
    public static void SendEmail(Id quoteID, String emailTemplateID, String emailAddress, Id contactID, Id quotedocID) {
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(contactID);
        message.setSenderDisplayName('Quote Confirmation');
        message.setReplyTo('no-reply@company.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(True);
        message.setTemplateID(emailTemplateID);
        message.setWhatId(quoteID); //This is important for the merge fields in template to work
        message.toAddresses = new String[]{emailAddress};
        
        //Get and attach the Quote Document
        List<QuoteDocument> QDs = [SELECT Name, Document, ContentVersionDocumentId FROM QuoteDocument WHERE QuoteId = :quoteID ORDER BY CreatedDate DESC LIMIT 1];
       
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (QuoteDocument QD: QDs) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(QD.Name);
            efa.setBody(QD.Document);
            attachments.add(efa);}
            message.setFileAttachments(attachments);
            
            
            Messaging.SingleEmailMessage[] messages = new List < Messaging.SingleEmailMessage > {
                message
            };
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
            }
            
        }
        
    }