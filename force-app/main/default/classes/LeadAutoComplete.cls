/**
     * @description : Class Used for Lead Trigger Website, to Autocomplete Info Based on Website Field
	 * @Author: Maroun Al Hourani
             * @Company: EI-Technologies
	 * @<11/8/2025>
     */


public with sharing class LeadAutoComplete {
     /**
     * @description Method used to get the Lead Ids to call the LeadEnrichment service
     * param  oldmap if exist, and new value triggered
     */

    public static void getLeadIdsToCallout(Map<Id, Lead> oldvalueupdate, List<Lead> newvalueupdate) {
        
        Set<Id> toEnrich = new Set<Id>();
        for (Lead l: newvalueupdate){             
            Lead oldLead = (oldvalueupdate != null) ? oldvalueupdate.get(l.Id) : null;  // in the case of insert, cannot do null.get(l.Id), this is why we use this technnique

            if((oldLead == null && l.Website != null) || (oldLead != null && l.Website != oldLead.Website)) // insert with website there or update with website change
            {                 
                toEnrich.add(l.Id);    // add Id of the Lead to the Set of Leads to Enrich          
            }         
            
        }

        if (!toEnrich.isEmpty()){
            System.enqueueJob(new LeadEnrichQueueable(toEnrich)); // to be able to perform callouts use Future, QueueJob, Batches
        }
    } 

    }
    

    