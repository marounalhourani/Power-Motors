/**  
     * @description External web service callout to get the Lead Info
	 * @Author: Tony Tawk
             * @Company: EI-Technologies
	 * @<Date>        <Authors Name>      <Brief Description of Change>
	 * @18/05/2020    Tony Tawk           Création
	 * @03/01/2021    Tony Tawk           Optimisation
     */ 



public with sharing class ExternalLeadEnrichmentService {

    /**
     * @description Get Access Token From SalesForce Org, As a specific User
     * Return Access Token to be used in Get Request 
     */

    public static String Get_Access_Token() {
        
        try{
            String endpoint = 'callout:Saleforce_Access_Token_Endpoint';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            String body = 
            'grant_type=password'+ 
            '&client_id='+ Label.sfwcClientId +
            '&client_secret='+ Label.sfwsClientSecret +
            '&username='+ Label.sfwsUsername +
            '&password=' + Label.sfwsPassword;
            
            request.setBody(body);
            
            HttpResponse response = http.send(request);
            System.debug('Status: ' + response.getStatus());
            System.debug('Response: ' + response.getBody());
            
            String responseBody = response.getBody();
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            String token = (String) result.get('access_token');
            System.debug('Actual token: ' + token); // Will still say "SESSION_ID_REMOVED" in Developer Console, but you can use it now
            
            return token;
            
            
        }catch(Exception e){
            system.debug(e.getMessage());
            return null;
        }
        
    }
       /**
     * @description, input the String website, get the endpoint with query needed for get request
     * Params string website 
     */
    private static String getAccountQueryEndpoint(String website) {
        String x = (website != null && website != '') ? String.escapeSingleQuotes(website) : '';
        String baseUrl = 'https://neo-discom2-dev-ed.my.salesforce.com/services/data/v54.0/query/?q=';
        String soql = 'SELECT logoUrl__c, NumberOfEmployees, Foundation_date__c, BillingAddress, ShippingAddress, Description FROM Account WHERE Website = \'' +  x + '\'';
        String encodedQuery = EncodingUtil.urlEncode(soql, 'UTF-8');
        String fullEndpoint = baseUrl + encodedQuery;
        
        return fullEndpoint;
    }
    
    /**
     * @description now that we have the access token. we need to access the website to get info, Get Request
     * Params: String website to get the Info From 
     */
    public static WebsiteInfo Get_Website_info(String website){

        LeadWrapper info = new LeadWrapper();//Big Generated Wrapper
        WebsiteInfo websiteInfo = new WebsiteInfo();//Only What we Need
    
        
        //Get Callout
        String endpoint = getAccountQueryEndpoint(website);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + Get_Access_Token());
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        responseBody = responseBody.replaceAll('__c', '');
        
        if(response.getStatusCode()==200){
            LeadWrapper responseBodyWrapper = LeadWrapper.parse(responseBody);
            for(LeadWrapper.Records record: responseBodyWrapper.records){
                websiteInfo.employees = record.NumberOfEmployees;
                System.debug('number of employees : ' + record.NumberOfEmployees);
                websiteInfo.description = record.Description;
                websiteInfo.logoUrl = record.logoUrl;
                websiteInfo.foundationDate = record.Foundation_date;
                websiteInfo.city = record.BillingAddress?.city;
                websiteInfo.country = record.BillingAddress?.country;
                websiteInfo.postalCode = record.BillingAddress?.postalCode;
                websiteInfo.street = record.BillingAddress?.street;
                websiteInfo.state= record.BillingAddress?.state; 
                System.debug('fnd date: ' +  record.Foundation_date);
                System.debug('logo url: ' +  record.logoUrl);  
                System.debug('n of emp' + record.NumberOfEmployees);
               
            }
            
        }
        System.Debug('website information: ' + websiteInfo);

        return websiteInfo;
    }
}




