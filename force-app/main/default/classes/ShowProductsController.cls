/**
* @description ShowProductsController used in lwc
* @Author: Maroun Al Hourani
* @Company: EI-Technologies
* @<14/08/2025>        Maroun Al Hourani 

*/




public with sharing class ShowProductsController {

     /**
     * @description show products in main tab , use filtering from backend, used dynamic query
     * param  
     **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAvailabledProducts(String coutryOfOrigin, String recordTypeName, Integer pageNumber, Integer pageSize) {
        //we will return this Map, it will contain records after filtering and pagination, all records, total records, total page
        Map<String, Object> response = new Map<String, Object>();

        //get the correct price book for B2C Account
        Pricebook2 B2Cpb = [SELECT Id FROM Pricebook2 WHERE Name =:Label.personAccountPriceBookName LIMIT 1];
        
        List<Product2> products; // will contain a max of 5 records, paginated, and filtered
        String query = 'SELECT Id, Name, Country_Of_Origin__c, recordTypeName__c, Description,Serial_Number__c, IsActive From Product2' ;
        String baseWhere = ' WHERE IsActive = True';

        if ( coutryOfOrigin <> 'All') {
            baseWhere = baseWhere + ' AND Country_Of_Origin__c = :coutryOfOrigin';
        }
        if ( recordTypeName <> 'All'){
            baseWhere = baseWhere + ' AND recordTypeName__c = :recordTypeName';
        }

        //added
        Integer offsetVal = (pageNumber - 1) * pageSize;
                // Get total record count (for pagination)
        Integer totalRecords = Database.countQuery('SELECT COUNT() FROM Product2' + baseWhere);

        // Calculate total pages
        Integer totalPages = (totalRecords + pageSize - 1) / pageSize;


        query = query + baseWhere + ' ORDER BY Name LIMIT :pageSize OFFSET :offsetVal';
        products = Database.query(query);
        List<Product2> allProducts = [SELECT Id, Name, Country_Of_Origin__c, recordTypeName__c, Description,Serial_Number__c, IsActive From Product2 WHERE IsActive = True];




       
        //get pricebook entries for b2c pricebook
        Map<Id, PricebookEntry> productIdToEntry = new Map<Id, PricebookEntry>();
        for(PriceBookEntry pbe : [SELECT Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id in :products AND Pricebook2Id = :B2Cpb.Id AND IsActive = True]){
            productIdToEntry.put(pbe.Product2Id, pbe);
        }

        Map<Id, PricebookEntry> productIdToEntryForAllProducts = new Map<Id, PricebookEntry>();
        for(PriceBookEntry pbe : [SELECT Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id in :allProducts AND Pricebook2Id = :B2Cpb.Id AND IsActive = True]){
            productIdToEntry.put(pbe.Product2Id, pbe);
        }

         //build wrapper list
        List<ProductWrapper> resultAllProducts = new List<ProductWrapper>();
        for(Product2 p: allProducts){
            Decimal price = productIdToEntryForAllProducts.containsKey(p.Id) ? productIdToEntryForAllProducts.get(p.Id).UnitPrice : null;
            resultAllProducts.add(new ProductWrapper(p.Id, p.Name, p.Country_Of_Origin__c, p.recordTypeName__c, price, p.Description, p.Serial_Number__c));
        }
        
        //build wrapper list
        List<ProductWrapper> result = new List<ProductWrapper>();
        for(Product2 p: products){
            Decimal price = productIdToEntry.containsKey(p.Id) ? productIdToEntry.get(p.Id).UnitPrice : null;
            result.add(new ProductWrapper(p.Id, p.Name, p.Country_Of_Origin__c, p.recordTypeName__c, price, p.Description, p.Serial_Number__c));
        }
        

        // Add data to response map
        response.put('records', result);
        response.put('totalRecords', totalRecords);
        response.put('totalPages', totalPages);
        response.put('allRecords', resultAllProducts);


        return response;
        
    }
    
    
    
    // Wrapper class reprenting a product with its description
    public class ProductWrapper {
        @AuraEnabled public Id productId;
        @AuraEnabled public String name;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String country;
        @AuraEnabled public String recordType;
        @AuraEnabled public Decimal price;
        @AuraEnabled public String fullUrl;
        @AuraEnabled public String description;
        @AuraEnabled public String pictureId;


        
        
        
        // 7 arguments constructor
        public ProductWrapper(Id productId, String name, String country, String recordType, Decimal price, String description, String serialNumber) {
            this.productId = productId;
            this.name = name;
            this.country = country;
            this.recordType = recordType;
            this.price = price;
            this.fullUrl = null;
            this.description = description;
            this.serialNumber = serialNumber;
        }

        // 9 arguments constructor       
        public ProductWrapper(Id productId, String name, String country, String recordType, Decimal price, String description, String serialNumber, String fullUrl, String pictureId) {
            this.productId = productId;
            this.name = name;
            this.country = country;
            this.recordType = recordType;
            this.price = price;
            this.description = description;
            this.serialNumber = serialNumber;
            this.fullUrl = fullUrl;
            this.pictureId = pictureId;
        }
        
        
        // 6-argument constructor (optional image)
        public ProductWrapper(Id productId, String name, String country, String recordType, Decimal price, String fullUrl) {
            this.productId = productId;
            this.name = name;
            this.country = country;
            this.recordType = recordType;
            this.price = price;
            this.fullUrl = fullUrl;
            this.description = description;
            this.serialNumber = serialNumber;
        }
        
        
    }
    


     /**
     * @description once we click on a product, we use pub sub to send product id from 1 comp to another, a
     * then we display info of product 
     * param  productId
     **/
    @AuraEnabled(cacheable=true)
    public static ProductWrapper getProductDetails(Id productId) {
        Id picId;
        ContentVersion cv;
        String ordDomain = Label.org_domain;
        String fullUrl;
        ContentDocumentLink PictureId;
        Product2 p = [SELECT Id, Name, Country_Of_Origin__c, recordTypeName__c, IsActive, Description, Serial_Number__c From Product2 WHERE Id = :productId LIMIT 1];
        Pricebook2 B2Cpb = [SELECT Id FROM Pricebook2 WHERE Name = 'Person Account Price Book' LIMIT 1];
        PriceBookEntry pbe =  [SELECT Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id = :p.Id AND Pricebook2Id = :B2Cpb.Id AND IsActive = True LIMIT 1];
        try {    
          PictureId = [SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: productId AND ContentDocument.Title LIKE 'MAIN%' LIMIT 1];
            picId =PictureId.ContentDocumentId;
            cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :picId ORDER BY CreatedDate DESC LIMIT 1];
            fullUrl = Label.org_domain + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + cv.Id + '&operation=View';
        }catch (Exception e) {
            
            fullUrl = null;
        }

        String mainPicId = (PictureId != null) ? String.valueOf(PictureId.ContentDocumentId) : '';
        System.Debug('picture Id is here: ' + mainPicId );
        ProductWrapper wrapper = new ProductWrapper(p.id, p.name, p.Country_Of_Origin__c, p.recordTypeName__c, pbe.UnitPrice,  p.Description,p.Serial_Number__c, fullUrl, mainPicId );
        System.debug('product Id: '+ wrapper.productId);
        System.debug('product name: '+ wrapper.name);
        System.debug('product country: '+ wrapper.country);
        System.debug('product recordType: '+ wrapper.recordType);
        System.debug('product price: '+ wrapper.price);
        System.debug('product Picture URL: '+ wrapper.fullUrl);
        System.debug('product Picture Id: '+ wrapper.pictureId);


        
        
        return wrapper;
        
    }
    

     /**
     * @description once we click submit,we create an opportunity
     * param  
     **/
    @AuraEnabled
    public static Id createOpportunity(List<Id> productIds, Id accountId, String opportunityName){
        Pricebook2 B2Cpb = [SELECT Id FROM Pricebook2 WHERE Name =: Label.personAccountPriceBookName LIMIT 1];
        Id oppId;
        if (productIds.size() > 0) {
            Opportunity opp = new Opportunity(
            Name = opportunityName,
            AccountId = accountId,
            StageName = 'Qualification',
            // Pricebook2Id = B2Cpb.Id, 
            CloseDate = Date.today()
            );
            
            insert opp;
            oppId = opp.Id;
            
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
                opp.StageName = 'Closed Won';
                update opp;
                System.Debug('opp update tp closed won');

                
            }
            
        }
        return oppId;
        
    }
}