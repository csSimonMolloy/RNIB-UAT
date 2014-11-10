/*
* 2014-02-11 : SM : This class is used to hold any methods called from the Risk_Assessment__c trigger
*/
public class RiskAssesmentTriggerClass {

	public static final String STATUS_APPROVED = 'Approved';
	public static final String STATUS_CERTIFICATE_APPROVED = 'Certificate Approved';
	
	//This method will update the corresponding Contact record if the check box On_Update_Service is ticked / unticked
	public static void updateOnUpdateService(List<Risk_Assessment__c> inRecords){
		Set<Id> contactIds = new Set<Id>();
		List<Contact> contactsToSave = new List<Contact>();
		
		for (Risk_Assessment__c ra : inRecords){
			contactIds.add(ra.Volunteer__c);
		}
		
		Map<Id, Contact> contactMap = new Map<Id, Contact>([select c.Id, c.On_Update_Service__c from Contact c where c.Id in :contactIds]);
		
		for (Risk_Assessment__c ra : inRecords){
			Contact c = contactMap.get(ra.Volunteer__c);
			if (c != null){
				c.On_Update_Service__c = ra.On_Update_Service__c;
				contactsToSave.add(c);
			}
		}
		
		update contactsToSave;
		
	}
	
	//This method will update the 'Criminal_Check_OK__c' field on the corresponding Application__c record if the Risk Assessment status is Approved
	public static void updateApplication(List<Risk_Assessment__c> inRecords){
		Set<Id> appIds = new Set<Id>();
		List<Application__c> appsToSave = new List<Application__c>(); 
		for (Risk_Assessment__c ra : inRecords){
			appIds.add(ra.Application__c);
		}
		
		Map<Id, Application__c> appMap = new Map<Id, Application__c>([select a.Id, a.Criminal_Check_OK__c from Application__c a where a.Id in :appIds]);
		
		for (Risk_Assessment__c ra : inRecords){
			if (STATUS_APPROVED.equalsIgnoreCase(ra.Status__c) || STATUS_CERTIFICATE_APPROVED.equalsIgnoreCase(ra.Status__c)){
				Application__c theApp = appMap.get(ra.Application__c);
				if (theApp != null){
					theApp.Criminal_Check_OK__c = true;
					appsToSave.add(theApp);
				}
			}
		}
		
	}

}