trigger RiskAssessmentTrigger on Risk_Assessment__c (after insert, after update) {

    if (trigger.isAfter){
        if (trigger.isInsert || trigger.isUpdate){
            RiskAssessmentTriggerMethods.updateApplication(trigger.new);
        }
        
        if (trigger.isInsert){
            //This method will update the On Update Service field on the corresponding Contact
            //to be the same as that on the Risk Assessment
            RiskAssessmentTriggerMethods.updateOnUpdateService(trigger.new);
        }else if (trigger.isUpdate){
            List<Risk_Assessment__c> recordsToProcess = new List<Risk_Assessment__c>();
            for (Risk_Assessment__c ra : trigger.new){
                Risk_Assessment__c oldRA = trigger.oldMap.get(ra.Id);
                if (ra.On_Update_Service__c != oldRA.On_Update_Service__c
                    || ra.Date_of_Birth__c != oldRA.Date_of_Birth__c){
                    recordsToProcess.add(ra);
                }
            }
            
            if (recordsToProcess.size() > 0){
                //This method will update the On Update Service field on the corresponding Contact
                //to be the same as that on the Risk Assessment
                RiskAssessmentTriggerMethods.updateOnUpdateService(recordsToProcess);
            }
        }
    }

}