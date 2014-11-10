trigger CustomerRequestsTrigger on Customer_Requests__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if (trigger.isBefore){
        if (trigger.isInsert){
            CustomerRequestsTriggerClass.autoAssignCustomerRequest(trigger.new);
        }
    }
    
    if (trigger.isAfter){
    	if (trigger.isUpdate){
    		String CLOSED_APPROVED_STATUS = 'Closed - Approved';
    		List<Customer_Requests__c> crList = new List<Customer_Requests__c>();
    		for (Customer_Requests__c c : trigger.new){
    			if (CLOSED_APPROVED_STATUS.equalsIgnoreCase(c.Status__c) && c.Total_Number_of_Hours_Donated_to_Resolve__c > 0){
    				if (c.Assigned_Volunteer__c != null){
    					crList.add(c);
    				}
    			}
    		}
    		//Call the method
    		CustomerRequestsTriggerClass.createTimeDonation(crList);
    	}
    }

}