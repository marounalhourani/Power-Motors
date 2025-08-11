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

    public void execute(QueueableContext ctx) {
        // adjust the Lead field API names to match your org
        List<Lead> leads = [
            SELECT Id, Website,
                   logoUrl__c, NumberOfEmployees, Foundation_date__c,
                   Description, City, Country, PostalCode, Street, State
            FROM Lead
            WHERE Id IN :leadIds AND Website != null
        ];

        // cache per website to avoid redundant callouts
        Map<String, WebsiteInfo> websiteCache = new Map<String, WebsiteInfo>();

        for (Lead l : leads) {
            String website = l.Website;
            if (String.isBlank(website)) continue;

            if (!websiteCache.containsKey(website)) {
                WebsiteInfo info = ExternalLeadEnrichmentService.Get_Website_info(website);
                websiteCache.put(website, info);
            }
            WebsiteInfo info = websiteCache.get(website);
            if (info != null) {
                // apply enrichment (overwrite or guard if you want)
                l.logoUrl__c = info.logoUrl;
                l.NumberOfEmployees = info.employees;
                l.Foundation_date__c = Date.valueOf(info.foundationDate);
                l.Description	 = info.description;
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