/**
* @description TestDataFactory Generate List of leads with a partical email so we can capture them refering to their email later. 
* @Author: Maroun Al Hourani
* @Company: EI-Technologies
* @<14/08/2025>        Maroun Al Hourani 

*/


public with sharing class TestDataFactory {
    public static List<Lead> createNewLeads(Integer numLeads) {
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = 0; i < numLeads; i++) {
            Lead l = new Lead(FirstName = 'Test', LastName = 'Test' + i, Company = 'Comapny #' + i, Email ='testdatadactory@email.com', Website='www.eit-mena.com');
            newLeads.add(l);
        }
        return newLeads;
    }
    
    public static Product2 createProductWithPricebook(String productName, Decimal standardPrice, Decimal customPrice, String customPricebookName){
        // 1. Create the product
        Product2 prod = new Product2(Name = productName, IsActive = true);
        insert prod;
        
        PricebookEntry standardPBE = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = prod.Id,
        UnitPrice = standardPrice,
        IsActive = true
        );
        Insert standardPBE;
        
        // 3. Create custom Pricebook
        Pricebook2 customPB;
        List<Pricebook2> existingPB = [SELECT Id FROM Pricebook2 WHERE Name = :customPricebookName LIMIT 1 ];

        customPB = new Pricebook2(Name = customPricebookName, IsActive = true);
        if (!existingPB.isEmpty()) {
            customPB = existingPB[0];
        } else {
            customPB = new Pricebook2(Name = customPricebookName, IsActive = true);
            insert customPB;
        }

        // 4. Custom Pricebook Entry
        PricebookEntry customPBE = new PricebookEntry(
            Pricebook2Id = customPB.Id,
            Product2Id = prod.Id,
            UnitPrice = customPrice,
            IsActive = true
        );
        insert customPBE;

        return prod;

        
        
        
    }
    
}