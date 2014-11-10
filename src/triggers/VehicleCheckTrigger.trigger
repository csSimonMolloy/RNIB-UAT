trigger VehicleCheckTrigger on Vehicle_Check__c (after insert, after update) {

    if (trigger.isAfter){
        if (trigger.isInsert || trigger.isUpdate){
            VehicleCheckTriggerMethods.updateApplication(trigger.new);
        }
    }

}