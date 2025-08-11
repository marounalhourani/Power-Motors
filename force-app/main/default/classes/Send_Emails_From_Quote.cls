public with sharing class Send_Emails_From_Quote {
    public static void Send_Emails_From_Quote(Map<Id, Opportunity> oldMap, List<Opportunity> newList ) {
        
        OrgWideEmailAddress owea = new OrgWideEmailAddress(); //Senders Email is The Org Wide Email Address
        owea = [SELECT Id, Address, DisplayName From OrgWideEmailAddress WHERE DisplayName = 'Maroun'];
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>(); //list of people(s) to send email to
        Id templateId = [SELECT Id, Name , DeveloperName FROM EmailTemplate WHERE Name = 'send quote to contacts'].id; //get the template it, template to send to all contacts

        Set<Id> oppIdsToProcess = new Set<Id>(); // the opportunity IDS that made the Trigger
        Set<Id> accountIds = new Set<Id>(); // the account Ids related

        //(accountId, Contacts)
        Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();

        Opportunity oldO; // for loop for putting to Ids, to records, of the triggering opps
        for (Opportunity o : newList) {
             oldQ = oldMap.get(o.Id);
            if (oldO != null && oldO.Status != o.Status && o.Status == 'Closed') {
                oppIdsToProcess.add(o.Id);
            }
        }

        List<Id> quootePDF = new List<Id>(oppIdsToProcess);
        generateQuotePdfDocument.QuoteCreate(quootePDF);

        
        //get the quote records
        // Step 2: after that we got the Id of the quotes, now we need to retrive the record
        Map<Id, Quote> quotesWithDetails = new Map<Id, Quote>(
        [SELECT Id, Name, AccountId FROM Quote WHERE Id IN :quoteIdsToProcess]
        );
        
        //step 3: get all account ids
        for (Quote q:quotesWithDetails.values() ){
            if(q.AccountId != null){
                accountIds.add(q.AccountId);
            }
        }
        
        
        //list of account Id, and their Records Contact
        for (Contact c : [SELECT Id, Name, FirstName, Email, AccountId FROM Contact WHERE AccountId IN :accountIds AND Email != null]) {
            if (!contactsByAccount.containsKey(c.AccountId)) {
                contactsByAccount.put(c.AccountId, new List<Contact>());
            }
            contactsByAccount.get(c.AccountId).add(c);
        }
        
        for(Id i: quoteIdsToProcess){
            Quote q = quotesWithDetails.get(i);
            if(accountIds.contains(q.AccountId)){
                for (Contact c: contactsByAccount.get(q.AccountId)){
                    if(c.Email != null){
                        Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
                        // List<String> sendToAddressesList = new List<String>();
                        newMail.setTemplateId(templateId); 
                        newMail.setTargetObjectId(c.Id);
                        newMail.setWhatId(q.Id);
                        newMail.setOrgWideEmailAddressId(owea.Id);

                        // sendToAddressesList.add(c.Email);
                        // newMail.setToAddresses(sendToAddressesList);

                        // newMail.setSubject('yoour contact deital hve been added');
                        // String body = 'helo' + c.FirstName + ',' ;

                        // newMail.setHtmlBody(body);
                        mailList.add(newMail);
                    }
                    //sendemail(c.email);
                }
            }
        }
        Messaging.sendEmail(mailList);


        
    }
}