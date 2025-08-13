public with sharing class Quote_Email_Trigger_Handler  extends TriggerHandler implements ITriggerHandler{
    
    private Map<Id, Quote> newMap;
    private Map<Id, Quote> oldMap;
    private List<Quote> TriggerNew;
    private List<Quote> TriggerOld;
    
    public Quote_Email_Trigger_Handler(){
        this.newMap = (Map<Id, Quote>) Trigger.newMap;
        this.oldMap = (Map<Id, Quote>) Trigger.oldMap;
        this.TriggerNew= (List<Quote>) Trigger.New;
        this.TriggerOld= (List<Quote>) Trigger.Old;
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

    }
    
    public  override void beforeUpdate() { 
        //here
    }
    
    public override void afterUpdate() {
        // Send_Emails_From_Quote.Send_Emails_From_Quote(oldMap, TriggerNew);


    }
    
    public override void beforeDelete() {}
    
    public override void afterDelete() {}
    
    public override void afterUnDelete() {}

}