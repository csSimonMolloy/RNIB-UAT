/*
* 2014-02-11 : SM : This class is used to hold any methods called from the Vehicle_Check__c trigger
*/
public with sharing class VehicleCheckTriggerMethods {

	public static final String STATUS_ACTIVE = 'Active';
	
	//This method will update the 'Vehicle_Check_OK__c' field on the corresponding Application__c record if the Vehicle Check status is Active
	public static void updateApplication(List<Vehicle_Check__c> inRecords){
		Set<Id> appIds = new Set<Id>();
		List<Application__c> appsToSave = new List<Application__c>(); 
		for (Vehicle_Check__c vc : inRecords){
			appIds.add(vc.Role__c);
		}
		
		Map<Id, Application__c> appMap = new Map<Id, Application__c>([select a.Id, a.Vehicle_Check_OK__c from Application__c a where a.Id in :appIds]);
		
		for (Vehicle_Check__c vc : inRecords){
			if (STATUS_ACTIVE.equalsIgnoreCase(vc.Status__c)){
				Application__c theApp = appMap.get(vc.Role__c);
				if (theApp != null){
					theApp.Vehicle_Check_OK__c = true;
					appsToSave.add(theApp);
				}
			}
		}
		
		if (appsToSave.size() > 0){
			update appsToSave;
		}
	}
	
}