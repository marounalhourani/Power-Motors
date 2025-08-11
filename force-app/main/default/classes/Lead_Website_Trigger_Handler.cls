/**
 * @description Trigger Handler for the Lead Object, Used for :Website field enrichment, auto populate fields
	 * @Author: Maroun Al Hourani
             * @Company: EI-Technologies
	 * @<11/8/2025>
 */

public with sharing class Lead_Website_Trigger_Handler  extends TriggerHandler implements ITriggerHandler{
    
    private Map<Id, Lead> newMap;
    private Map<Id, Lead> oldMap;
    private List<Lead> TriggerNew;
    private List<Lead> TriggerOld;
    
    public Lead_Website_Trigger_Handler(){
        this.newMap = (Map<Id, Lead>) Trigger.newMap;
        this.oldMap = (Map<Id, Lead>) Trigger.oldMap;
        this.TriggerNew= (List<Lead>) Trigger.New;
        this.TriggerOld= (List<Lead>) Trigger.Old;
    }
    
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() { 
    }
    
    public override void afterInsert() { 
        

        LeadAutoComplete.getLeadIdsToCallout(null, TriggerNew);

    }
    
    public  override void beforeUpdate() { 

    }
    
    public override void afterUpdate() {
        LeadAutoComplete.getLeadIdsToCallout(oldMap, TriggerNew);

    }
    
    public override void beforeDelete() {}
    
    public override void afterDelete() {}
    
    public override void afterUnDelete() {}

}