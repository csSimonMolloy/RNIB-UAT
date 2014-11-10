trigger ApplicationTrigger on Application__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if (trigger.isBefore){
        if (trigger.isInsert){
            ApplicationTriggerMethods.markApplicationCheckboxesOnInsert(trigger.new);
        }else if (trigger.isUpdate){
            List<Application__c> processList = new List<Application__c>();
            for (Application__c a : trigger.new){
                //if ('SUCCESSFUL'.equalsIgnoreCase(a.Status__c)){
                    processList.add(a);
                //}
            }
            
            //Call the method
            ApplicationTriggerMethods.markApplicationCheckboxes(processList);
        }
    }
    
    if (trigger.isAfter){
        if (trigger.isInsert){
            List<Application__c> processList = new List<Application__c>();
            for (Application__c a : trigger.new){
                if (a.Group_Induction__c != null){
                    processList.add(a);
                }
            }
            ApplicationTriggerMethods.updateGroupInduction(processList);
        }else if (trigger.isUpdate){
            List<Application__c> processList = new List<Application__c>();
            List<Id> deleteList = new List<Id>();
            for (Application__c a : trigger.new){
                if (a.Automatic_Deletion_Required__c){
                    deleteList.add(a.Id);
                }else {
                    if (a.Group_Induction__c != null){
                        Application__c oldApp = trigger.oldMap.get(a.Id);
                        if (oldApp.Group_Induction__c != a.Group_Induction__c){
                            processList.add(a);
                        }
                    }   
                }
            }
            if (deleteList.size() > 0){
                ApplicationTriggerMethods.autoDeleteApplications(deleteList);
            }
            if (processList.size() > 0){
                ApplicationTriggerMethods.updateGroupInduction(processList);
            }
        }
    }

}