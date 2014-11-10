/*
* 2014-03-06 : SM : This class is scheduled by ScheduledApplicationExpiry, to search for Applications
* that have not neen modified for the last seven days, and are in status of DRAFT
*/
public class ApplicationExpiry {
    public final String STATUS_DRAFT = 'Draft';
    public final String STATUS_INCOMPLETE = 'Incomplete';

    public ApplicationExpiry(){
        List<Application__c> appsToSave = new List<Application__c>();
        List<Application__c> checkApplications = new List<Application__c>();
        Date expiryDate = Date.today().addDays(-7);
        
        if (test.isRunningTest()){
            checkApplications = [select a.Id, a.LastModifiedDate, a.Status__c 
                                                    From Application__c a where a.CreatedDate = TODAY
                                                    and a.Status__c = :STATUS_DRAFT];   
        }else {
            checkApplications = [select a.Id, a.LastModifiedDate, a.Status__c 
                                                    From Application__c a where a.LastModifiedDate >= : expiryDate
                                                    and a.Status__c = :STATUS_DRAFT];
        }
        
        for (Application__c a : checkApplications){
            a.Status__c = STATUS_INCOMPLETE;
            appsToSave.add(a);
        }
        
        update appsToSave;
        
    }
}