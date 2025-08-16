@isTest
private with sharing class LeadAutoComplete_Test {

 @TestSetup
    static void makeData() {
        
        List<Lead> insertLeads = TestDataFactory.createNewLeads(5);
        insert insertLeads;
    }
    
    @isTest
    static void testInsertWithWebsite() {
        // Simulate an insert scenario → oldvalueupdate is null
        List<Lead> newLeads = [SELECT Website FROM Lead WHERE Email = 'testdatadactory@email.com'];

        Test.startTest();
            for (Lead l : newLeads){
                l.Website = 'www.google.com';
            }
            update newLeads;
        Test.stopTest();
      
    }

    @isTest
    public static void sendPOSTRequest_Test(){
        String mockReponse = '{"access_token":"testtoken","instance_url":"testurl","id":"testid","token_type":"bearer","issued_at":"testissued_at","signature":"testsignature"}';
        Test.setMock(HttpCalloutMock.class, new WebsiteWebServiceCallout_Test(mockReponse)) ;
        Test.startTest();
            String fakeReponse = ExternalLeadEnrichmentService.Get_Access_Token();
        Test.stopTest();
        Assert.areEqual('testtoken', fakeReponse, 'callout response what not as expected');
    }

    @isTest
    public static void getRequest_Test(){
        String mockResponse = '{' +
    '"totalSize": 1,' +
    '"done": true,' +
    '"records": [' +
        '{' +
            '"attributes": {' +
                '"type": "Account",' +
                '"url": "/services/data/v54.0/sobjects/Account/0018d00000G2qrbAAB"' +
            '},' +
            '"logoUrl__c": "logourltest",' +
            '"NumberOfEmployees": 999,' +
            '"Foundation_date__c": "2008-09-24",' +
            '"BillingAddress": {' +
                '"city": "citytest",' +
                '"country": "countrytest",' +
                '"geocodeAccuracy": null,' +
                '"latitude": null,' +
                '"longitude": null,' +
                '"postalCode": null,' +
                '"state": null,' +
                '"street": "street test"' +
            '},' +
            '"Description": "description test"' +
        '}' +
    ']' +
'}' ;
        Test.setMock(HttpCalloutMock.class, new WebsiteWebServiceCallout_Test(mockResponse)) ;
        Test.startTest();
            WebsiteInfo fakeReponse = ExternalLeadEnrichmentService.Get_Website_info('www.google.com');
        Test.stopTest();
        Assert.areEqual('description test', fakeReponse.description, 'callout response what not as expected');
    }

}