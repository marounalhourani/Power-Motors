public with sharing class ExternalLeadEnrichmentService {
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
    
    private static String getAccountQueryEndpoint(String website) {
        String baseUrl = 'https://neo-discom2-dev-ed.my.salesforce.com/services/data/v54.0/query/?q=';
        String soql = 'SELECT logoUrl__c, NumberOfEmployees, Foundation_date__c, BillingAddress, ShippingAddress, Description FROM Account WHERE Website = \'' + String.escapeSingleQuotes(website) + '\'';
        String encodedQuery = EncodingUtil.urlEncode(soql, 'UTF-8');
        String fullEndpoint = baseUrl + encodedQuery;
        
        return fullEndpoint;
    }
    
    // public static WebsiteInfo Get_Website_info(String website){
        
    //     WebsiteInfo info = new WebsiteInfo();
        
    //     String logoUrl;
    //     Integer employees;
    //     String foundationDate;
    //     String description ;
    //     String city;
    //     String country;
    //     String street;
    //     String state;
    //     String postalCode;
        
    //     String endpoint = getAccountQueryEndpoint(website);
    //     Http http = new Http();
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(endpoint);
    //     request.setMethod('GET');
        
    //     request.setHeader('Authorization', 'Bearer ' + Get_Access_Token());
    //     HttpResponse response = http.send(request);
    //     String responseBody = response.getBody();
    //     System.debug('api response' + responseBody);
    //     System.debug('status: ' + response.getStatus());
    //     System.debug('deserializeUntyped response body is:' + JSON.deserializeUntyped(responseBody));
    //     Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    //     List<Object> r = (List<Object>) result.get('records');
    //     if (!r.isEmpty()) {
    //         Map<String, Object> firstRecord = (Map<String, Object>) r[0];
            
    //         logoUrl = (String) firstRecord.get('logoUrl__c');
    //         foundationDate = (String) firstRecord.get('Foundation_date__c');
            
    //         info.logoUrl = logoUrl;
    //         info.foundationDate = foundationDate;
    //         System.debug('logoUrl'+ logoUrl);
    //         System.debug('foundation date: ' + foundationDate);
    //     }
        
        
    //     if(response.getStatusCode()==200){
    //         LeadWrapper responseBodyWrapper = LeadWrapper.parse(responseBody);
    //         System.debug('response body wrapper: ' + responseBodyWrapper);
    //         for(LeadWrapper.Records record: responseBodyWrapper.records){
    //             employees = record.NumberOfEmployees;
    //             description = record.Description;
    //             city = record.BillingAddress.city;
    //             country = record.BillingAddress.country;
    //             postalCode = record.BillingAddress.postalCode;
    //             street = record.BillingAddress.street;
    //             state = record.BillingAddress.state;
                
    //             info.employees = employees;
    //             info.description = description;
    //             info.city = city;
    //             info.country = country;
    //             info.postalCode = postalCode;
    //             info.street = street;
    //             info.state = state;
                
    //             System.debug('employees: ' + employees);
    //             System.debug('description :' + description);
    //             System.debug('city :' + city);
    //             System.debug('country :' + country);
    //             System.debug('postal code :' + postalCode);
    //             System.debug('street :' + street);
    //             System.debug('state :' + state);
                
                
                
    //         }
    //         Integer x = responseBodyWrapper.totalSize;
    //         System.debug('x' + x);
    //         System.debug(responseBodyWrapper.records);
            
    //         System.debug(info);
            
    //     }
    //     return info;
    // }
    
    
    public static LeadWrapper Get_Website_infonew(String website){
        
        LeadWrapper info = new LeadWrapper();  
        WebsiteInfo websiteInfo = new WebsiteInfo();      
        String endpoint = getAccountQueryEndpoint(website);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + Get_Access_Token());
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        // LeadWrapper responseBodyWrapper = LeadWrapper.parse(responseBody);
        // System.debug('reponse body wrapper' + responseBodyWrapper);
        // System.debug('status: ' + response.getStatus());
        // System.debug('status code: ' + response.getStatusCode());
        // System.debug(responseBodyWrapper.records[0].BillingAddress.city);
        
        
        if(response.getStatusCode()==200){
            LeadWrapper responseBodyWrapper = LeadWrapper.parse(responseBody);
            for(LeadWrapper.Records record: responseBodyWrapper.records){
                websiteInfo.employees = record.NumberOfEmployees;
                websiteInfo.description = record.Description;
                websiteInfo.logoUrl = record.logoUrl;
                websiteInfo.foundationDate = record.Foundation_date;
                websiteInfo.city = record.BillingAddress.city;
                websiteInfo.country = record.BillingAddress.country;
                websiteInfo.postalCode = record.BillingAddress.postalCode;
                websiteInfo.street = record.BillingAddress.street;
                websiteInfo.state= record.BillingAddress.state;
                
                System.debug('employees: ' + websiteInfo.employees);
                System.debug('description :' + websiteInfo.description);
                System.debug('logourl :' + websiteInfo.logoUrl);
                System.debug('foundationDate :' + websiteInfo.foundationDate);
                System.debug('city :' + websiteInfo.city);
            
                
                
            }
            Integer x = responseBodyWrapper.totalSize;
            System.debug('x:' + x);
            System.debug('response body wrapper . records'+responseBodyWrapper.records);
            
            System.debug('info are:' + info);
            
        }
        return info;
    }
}
