global with sharing class WebsiteWebServiceCallout_Test implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('{"access_token":"testtoken","instance_url":"testurl", "id":"testid", "token_type":"bearer"}');
        res.setStatusCode(200);
        return res;

    }
}