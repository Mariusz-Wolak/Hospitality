public with sharing class Hos_TriggerFactory {
    public static void createHandler(Schema.sObjectType soType)
    {
        Hos_ITrigger handler = getHandler(soType);
        if (handler == null)
        {
            throw new Hos_TriggerException();
        }
        if(Hos_Utils.isTriggerExceptionEnabled(soType)==false) {
            execute(handler);
        }
    }

    private static void execute(Hos_ITrigger handler)
    {
        if (Trigger.isBefore)
        {
            handler.bulkBefore();
            if (Trigger.isDelete) {
                handler.beforeDelete(trigger.old,trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                handler.beforeInsert(trigger.new);
            }
            else if (Trigger.isUpdate)
            {
                handler.beforeUpdate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            }
        }
        else
        {
            handler.bulkAfter();
            if (Trigger.isDelete) {
                handler.afterDelete(trigger.old,trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                handler.afterInsert(trigger.new,trigger.newMap);
            }
            else if (Trigger.isUpdate) {
                handler.afterUpdate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            }
        }
        handler.andFinally();
    }

    public static Hos_ITrigger getHandler(Schema.sObjectType soType)
    {
        if (soType == Hos_Contract__c.sObjectType){
            return new Hos_ContractTriggerHandler();
        }
        if (soType == Hos_Doctor__c.sObjectType){
            return new Hos_DoctorsTriggerHandler();
        }
        return null;
    }
}