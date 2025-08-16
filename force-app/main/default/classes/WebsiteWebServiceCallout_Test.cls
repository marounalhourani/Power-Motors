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

    public WebsiteWebServiceCallout_Test(String body){
        this.responseBody = body;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        res.setBody(responseBody);

        return res;

    }
}