trigger ReferenceTrigger on Reference__c (after insert, after update, before insert, before update) {

    if (trigger.isAfter){
        //if (trigger.isInsert || trigger.isUpdate){
        if (trigger.isUpdate){
            ReferenceTriggerMethods.updateApplication(trigger.new);
        }
    }

}