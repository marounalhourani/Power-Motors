@isTest
private with sharing class LeadAutoComplete_Test {

 @TestSetup
    static void makeData() {
        
        List<Lead> insertLeads = TestDataFactory.createNewLeads(5);
    }
    
    @isTest
    static void testInsertWithWebsite() {
        // Simulate an insert scenario → oldvalueupdate is null
        List<Lead> newLeads = [SELECT Id, Website FROM Lead WHERE Email = 'testdatadactory@email.com'];

        Test.startTest();
            insert newLeads;
            for (Lead l : newLeads){
                l.Website = 'www.google.com';
            }
            update newLeads;
        Test.stopTest();
      
    }

    @isTest
    public static void sendPOSTRequest_Test(){
        Test.setMock(HttpCalloutMock.class, new WebsiteWebServiceCallout_Test()) ;
        Test.startTest();
            ExternalLeadEnrichmentService.Get_Access_Token();
        Test.stopTest();
    }


}