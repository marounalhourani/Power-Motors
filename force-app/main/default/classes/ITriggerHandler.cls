Public interface ITriggerHandler{

    void beforeInsert();
    void afterInsert();
    void beforeUpdate();
    void afterUpdate();
    void beforeDelete();   
    void afterDelete();   
    void afterUnDelete();
    Boolean isDisabled();
}
