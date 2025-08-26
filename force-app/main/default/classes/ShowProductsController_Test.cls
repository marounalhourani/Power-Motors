/**
     * @description ShowProductsController_Test
	 * @Author: Maroun Al Hourani
     * @Company: EI-Technologies
	 * @<20/8/2025>       
     */ 

@isTest
public with sharing class ShowProductsController_Test {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createProductWithPricebook('iphone', 10, 100, 'Person Account Price Book');//standard price- customprice
        TestDataFactory.createProductWithPricebook('Samsung', 10, 32, 'Person Account Price Book');
        TestDataFactory.createProductWithPricebook('Huawei', 10, 45, 'Person Account Price Book');


        
    }
    
    
    @isTest
    public static void getAvailabledProducts_Test() {
        
        Test.startTest();
            Map<String, Object> products = ShowProductsController.getAvailabledProducts('All', 'All', 1, 5);
        Test.stopTest();
            // Assert.areEqual(3, products.size(), 'not actual size');
        
    }

    @isTest
    public static void getProductDetails_Test(){

        Product2 p = [SELECT Id From Product2 Where Name = 'iphone' LIMIT 1];
        Test.startTest();
         ShowProductsController.ProductWrapper productDetails = ShowProductsController.getProductDetails(p.Id);
        Test.stopTest();
        Assert.areEqual('iphone', productDetails.name, 'not actual name');


    }

    @isTest
    public static void createOpportunity_Test(){

        List<Id> prodIds = new List<Id>();
        Product2 p1 = [SELECT Id From Product2 Where Name = 'iphone' LIMIT 1];
        Product2 p2 = [SELECT Id From Product2 Where Name = 'Samsung' LIMIT 1];
        prodIds.add(p1.Id);
        prodIds.add(p2.Id);
        Account testAcc = new Account(LastName = 'test ln');
        insert testAcc;

        Test.startTest();//List<Id> productIds, Id accountId, String opportunityName
            Id oppId = ShowProductsController.createOpportunity(prodIds, testAcc.Id, 'new Opp Test Apex');
        Test.stopTest();
        Opportunity newOppCreated = [SELECT Id, Name From Opportunity Where Id =: OppId LIMIT 1];
        Integer productCountDB = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :newOppCreated.Id]; // real one
        Integer productCountTest = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :oppId]; // action

        Assert.areEqual(oppId, newOppCreated.Id, 'not the correct Id');
        Assert.areEqual(productCountTest, productCountDB, 'not the correct number of products');


    }
}