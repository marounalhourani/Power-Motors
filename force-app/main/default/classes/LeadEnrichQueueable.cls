/**
     * @description Queue Job to be Able to Call asynchronous callout
	 * @Author: maroun al hourani
     * @Company: EI-Technologies
	 * @<11/8/2025>        <Maroun Al Hourani>
*/ 


public with sharing class LeadEnrichQueueable implements Queueable, Database.AllowsCallouts{
    private Set<Id> leadIds;

    public LeadEnrichQueueable(Set<Id> leadIds) {
        this.leadIds = leadIds;
    }

     /**
     * @description execute perform the enrichment
     * Here we got all the Lead Id that got triggered and met our criteria ( insert / update with website field changed)
     */

    public void execute(QueueableContext ctx) {
        List<Lead> leads = [
            SELECT Id, Website,
                   logoUrl__c, NumberOfEmployees, Foundation_date__c,
                   Description, Description__c, City, Country, PostalCode, Street, State
            FROM Lead
            WHERE Id IN :this.leadIds 
        ];

        // cache per website to avoid redundant callouts
        Map<String, WebsiteInfo> websiteCache = new Map<String, WebsiteInfo>();

        for (Lead l : leads) {
            String website = l.Website; 

            if (!websiteCache.containsKey(website)) {
                //WebsiteInfo is a wrapper
                WebsiteInfo info = ExternalLeadEnrichmentService.Get_Website_info(website);
                websiteCache.put(website, info);
            }

            WebsiteInfo info = websiteCache.get(website);
            System.debug('info: ' + info);
            if (info != null) {
                // apply enrichment 
                l.logoUrl__c = info.logoUrl;
                l.NumberOfEmployees = info.employees;
                l.Foundation_date__c = info.foundationDate != null ? Date.valueOf(info.foundationDate) : null;
                l.Description= info.description;
                l.Description__c= info.description;
                l.City = info.city;
                l.Country = info.country;
                l.PostalCode = info.postalCode;
                l.Street = info.street;
                l.State = info.state;
            }
        }

        if (!leads.isEmpty()) {
            try {
                update leads;
            } catch (DmlException e) {
                System.debug('Lead enrichment update failed: ' + e.getMessage());
            }
        }
    }
}