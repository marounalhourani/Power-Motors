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

}