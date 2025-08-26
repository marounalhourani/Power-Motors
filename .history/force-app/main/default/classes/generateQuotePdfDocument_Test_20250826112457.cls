@isTest
public with sharing class generateQuotePdfDocument_Test {

@TestSetup
static void makeData() {
    // Create an Account
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    
    // Create a Contact
    Contact con = new Contact(
        FirstName = 'John', 
        LastName = 'Doe', 
        Email = 'john.doe@example.com', 
        AccountId = acc.Id
    );
    insert con;

    // Create an Opportunity
    Opportunity opp = new Opportunity(
        Name = 'Test Opp551100', 
        AccountId = acc.Id, 
        StageName = 'Qualification', 
        CloseDate = Date.today()
    );
    insert opp;

    // Create a Quote linked to the Opportunity
    Quote qt = new Quote(
        Name = 'Test Quote55555', 
        OpportunityId = opp.Id,
        Status = 'New'
        // AccountId is automatically set from Opportunity
        // IsSyncing is read-only on insert
    );
    insert qt;

    qt.Status = 'Approved';
    update qt;

    qt.Status = 'Sent_to_Client';
    update qt;

    qt.Status = 'Approved';
    update qt;

    qt.Status = 'Approved_by_Client';
    update qt;

    qt.Status = 'Closed';
    update qt;

    opp.SyncedQuoteId = qt.Id;
    update opp;


}

    @isTest
    public static void QuoteCreateAndEmail_Test() {
        List<Opportunity> opps = [SELECT Id From Opportunity Where Name = 'Test Opp551100'];
        System.debug('ooppsss list'+opps);
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp: opps){
                oppIds.add(opp.Id);
        }
        Test.startTest();
         generateQuotePdfDocument.QuoteCreateAndEmail(oppIds);
        Test.stopTest();

    }
}