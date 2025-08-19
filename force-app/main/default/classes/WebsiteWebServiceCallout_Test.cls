/**
     * @description Create a Fake Mock Response
	 * @Author: Maroun Al Hourani
     * @Company: EI-Technologies
	 * @14/08/2025    Maroun Al Hourani Création
     */ 

global with sharing class WebsiteWebServiceCallout_Test implements HttpCalloutMock {
    private String responseBody;

     /**
     * @description WebsiteWebServiceCallout_Test used for testing response
     * param  body  of the mock response which looks almost identical to the Json response given by a certain callback
     */



    global HttpResponse respond(HttpRequest req) {
        String getInfo = '{' +
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

        String postAccessToken = '{"access_token":"testtoken","instance_url":"testurl","id":"testid","token_type":"bearer","issued_at":"testissued_at","signature":"testsignature"}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        if(req.getEndpoint().contains('/services/oauth2/token')) {
            res.setBody(postAccessToken);
        } else if(req.getEndpoint().contains('https://neo-discom2-dev-ed.my.salesforce.com/services/data/v54.0/query/?')) {
            res.setBody(getInfo);
        }
        return res;



    }
}