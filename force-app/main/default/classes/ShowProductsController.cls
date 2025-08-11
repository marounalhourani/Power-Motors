public with sharing class ShowProductsController {
    
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAvailabledProducts() {
        
        Pricebook2 B2Cpb = [SELECT Id FROM Pricebook2 WHERE Name = 'Person Account Price Book' LIMIT 1];
        
        List<Product2> products = [SELECT Id, Name, Country_Of_Origin__c, recordTypeName__c, IsActive From Product2 
        WHERE IsActive = True];
        
        //get pricebook entries for b2c pricebook
        Map<Id, PricebookEntry> productIdToEntry = new Map<Id, PricebookEntry>();
        for(PriceBookEntry pbe : [SELECT Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id in :products AND Pricebook2Id = :B2Cpb.Id AND IsActive = True]){
            productIdToEntry.put(pbe.Product2Id, pbe);
        }
        
        //build wrapper list
        List<ProductWrapper> result = new List<ProductWrapper>();
        for(Product2 p: products){
            Decimal price = productIdToEntry.containsKey(p.Id) ? productIdToEntry.get(p.Id).UnitPrice : null;
            result.add(new ProductWrapper(p.Id, p.Name, p.Country_Of_Origin__c, p.recordTypeName__c, price));
        }
        
        return result;
        
    }
    
    
    
    // Wrapper class reprenting a product with its description
    public class ProductWrapper {
        @AuraEnabled public Id productId;
        @AuraEnabled public String name;
        @AuraEnabled public String country;
        @AuraEnabled public String recordType;
        @AuraEnabled public Decimal price;
        @AuraEnabled public String fullUrl;
        
        
        public ProductWrapper(Id productId, String name, String country, String recordType, Decimal price) {
            this.productId = productId;
            this.name = name;
            this.country = country;
            this.recordType = recordType;
            this.price = price;
            this.fullUrl = null;
            
        }
        
        // 6-argument constructor (optional image)
        public ProductWrapper(Id productId, String name, String country, String recordType, Decimal price, String fullUrl) {
            this.productId = productId;
            this.name = name;
            this.country = country;
            this.recordType = recordType;
            this.price = price;
            this.fullUrl = fullUrl;
        }
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static ProductWrapper getProductDetails(Id productId) {
        Id picId;
        ContentVersion cv;
        String ordDomain = Label.org_domain;
        String fullUrl;
        Product2 p = [SELECT Id, Name, Country_Of_Origin__c, recordTypeName__c, IsActive From Product2 WHERE Id = :productId LIMIT 1];
        Pricebook2 B2Cpb = [SELECT Id FROM Pricebook2 WHERE Name = 'Person Account Price Book' LIMIT 1];
        PriceBookEntry pbe =  [SELECT Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :B2Cpb.Id AND IsActive = True LIMIT 1];
        try {    
            ContentDocumentLink PictureId = [SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: productId AND ContentDocument.Title LIKE 'MAIN%' LIMIT 1];
            picId =PictureId.ContentDocumentId;
            cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :picId ORDER BY CreatedDate DESC LIMIT 1];
            fullUrl = Label.org_domain + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + cv.Id + '&operation=View';
        }catch (Exception e) {
            
            fullUrl = null;
        }
        
        ProductWrapper wrapper = new ProductWrapper(p.id, p.name, p.Country_Of_Origin__c, p.recordTypeName__c, pbe.UnitPrice, fullUrl);
        System.debug('product Id: '+ wrapper.productId);
        System.debug('product name: '+ wrapper.name);
        System.debug('product country: '+ wrapper.country);
        System.debug('product recordType: '+ wrapper.recordType);
        System.debug('product price: '+ wrapper.price);
        System.debug('product Picture URL: '+ wrapper.fullUrl);
        
        
        return wrapper;
        
    }
    
    @AuraEnabled()
    public static void createOpportunity(List<Id> productIds, Id accountId, String opportunityName){
        Pricebook2 B2Cpb = [SELECT Id FROM Pricebook2 WHERE Name = 'Person Account Price Book' LIMIT 1];
        if (productIds.size() > 0) {
            Opportunity opp = new Opportunity(
            Name = opportunityName,
            AccountId = accountId,
            StageName = 'Qualification',
            Pricebook2Id = B2Cpb.Id, 
            CloseDate = Date.today()
            );
            
            insert opp;
            Map<Id, PricebookEntry> productIdToPbe = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbe : [
            SELECT Id, Product2Id, UnitPrice 
            FROM PricebookEntry
            WHERE Pricebook2Id = :B2Cpb.Id
            AND Product2Id IN :productIds
            AND IsActive = TRUE
            ]) {
                productIdToPbe.put(pbe.Product2Id, pbe);
            }
            //create opportunityLineItems for each products selected
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            
            for (Id productId : productIds) 
            {
                if (productIdToPbe.containsKey(productId)) 
                {
                    PricebookEntry pbe = productIdToPbe.get(productId);
                    OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                    );
                    oppLineItems.add(oli);
                }
                
            }
            if (!oppLineItems.isEmpty()) {
                insert oppLineItems;
            }
            
            
        }
    }
}