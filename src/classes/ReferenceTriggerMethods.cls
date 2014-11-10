/*
* 2014-02-11 : SM : This class is used to hold any methods called from the Reference__c trigger
*/
public with sharing class ReferenceTriggerMethods {

	public static final String RISK_ASSESSMENT_RT_DEVNAME = 'Risk_Assessment_Reference';
	public static final String STANDARD_REFERENCES_RT_DEVNAME = 'Standard_Reference';
	public static final String STATUS_ACCEPTED = 'Accepted';
	public static final String STATUS_APPROVED = 'Approved';
	
	//This method will update the 'References_OK__c' field on the corresponding Application__c record if the EITHER
	//A Risk Assessment record type exists of status APPROVED or the right number of References record type exist of status ACCEPTED
	public static void updateApplication(List<Reference__c> inRecords){
		system.debug('*** -- into updateApplication on Reference -- ***');
		Map<String, RecordType>recordTypeMap = new Map<String, RecordType>();
		for (RecordType r : [select r.DeveloperName, r.Name, r.Id, r.SobjectType from RecordType r where r.IsActive = true]){
			recordTypeMap.put(r.DeveloperName, r);
		}
		Set<Id> appIds = new Set<Id>();
		Map<Id, Application__c> appsToSave = new Map<Id, Application__c>(); 
		for (Reference__c r : inRecords){
			appIds.add(r.Application__c);
		}
		
		Map<Id, Application__c> appMap = new Map<Id, Application__c>([select a.Id, a.References_OK__c, a.Role__r.Number_of_References_Required__c, 
																		(Select Id, Outcome__c, RecordTypeId From References__r where Outcome__c = :STATUS_APPROVED or Outcome__c = :STATUS_ACCEPTED) 
																		from Application__c a where a.Id in :appIds]);
		system.debug('*** -- Process all incoming references -- ***');
		for (Reference__c r : inRecords){
			Application__c theApp = appMap.get(r.Application__c);
			
			integer numOfRefsReq;
			if (theApp != null){
				system.debug('*** -- Found an app -- ***');
				numOfRefsReq = (theApp.Role__r.Number_of_References_Required__c == null ? 0 : integer.valueOf(theApp.Role__r.Number_of_References_Required__c));			
				if (r.RecordTypeId == recordTypeMap.get(RISK_ASSESSMENT_RT_DEVNAME).Id){
					system.debug('*** -- Its a RISK ASSESSMENT -- ***');
					if (STATUS_APPROVED.equalsIgnoreCase(r.Outcome__c)){
						theApp.References_OK__c = true;
						if (!appsToSave.containsKey(theApp.Id)){
							appsToSave.put(theApp.Id, theApp);
						}
					}
				}else if (r.RecordTypeId == recordTypeMap.get(STANDARD_REFERENCES_RT_DEVNAME).Id){
					system.debug('*** -- Its a STANDARD REFERENCE -- ***');
					system.debug('*** -- references size = ' + theApp.References__r.size() + ' -- ***');
					system.debug('*** -- Number of refs required = ' + numOfRefsReq + ' -- ***');
					system.debug('*** -- Size of reference list at this point is : ' + theApp.References__r.size() + ' -- ***');
					if (STATUS_ACCEPTED.equalsIgnoreCase(r.Outcome__c)){
						integer howMany = theApp.References__r.size();
						if (howMany >= numOfRefsReq){
							theApp.References_OK__c = true;
							if (!appsToSave.containsKey(theApp.Id)){
								appsToSave.put(theApp.Id, theApp);
							}
						}
					}	
				
				}
			}
		}
		
		if (appsToSave.size() > 0) {
			update appsToSave.values();
		}
			
	}

}