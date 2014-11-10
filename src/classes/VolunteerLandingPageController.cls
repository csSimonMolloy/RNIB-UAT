public with sharing class VolunteerLandingPageController {
    public final String APP_STATUS_DRAFT = 'Draft';
    public final String APP_STATUS_SUBMITTED = 'Submitted';
    public final String APP_STATUS_PENDING_REFEREE_CHECKS = 'Pending Referee Checks';
    public final String APP_STATUS_PENDING_INTERVIEW = 'Pending Interviews';
    public final String APP_STATUS_SUCCESSFUL = 'Successful';
    public final String APP_STATUS_WITHDRAWN = 'Withdrawn';
    public final String APP_STATUS_UNSUCCESSFUL_ROLE_FILLED = 'Unsuccessful - Role Filled';
    public final String APP_STATUS_UNSUCCESSFUL_NOT_SUITABLE_AT_INTERVIEW = 'Unsuccessful - Not Suitable at Interview';
    public final String APP_STATUS_UNSUCCESSFUL_NOT_SUITABLE_FOR_INTERVIEW = 'Unsuccessful - Not Suitable for Interview';
    public final String APP_STATUS_UNSUCCESSFUL_UNSUITABLE_REFERENCES = 'Unsuccessful - Unsuitable References';
    public final String APP_STATUS_ACTIVE = 'Active';
    public final String APP_STATUS_INACTIVE = 'Inactive';
    public final String APP_STATUS_CONTACT_GVT = 'Contact GVT';
    public final String APP_STATUS_RESIGNED_FROM_ROLE = 'Resigned from Role';
    public final String APP_STATUS_UNSUCCESSFUL_UNSUITABLE_RISK_ASSESSMENT = 'Unsuccessful - Unsuitable Risk Assessment';
    
    public Map<String, String> appStatusMap {get; set;}

    
    
    public VolunteerLandingPageController(){
        appStatusMap = new Map<String, String>();
        appStatusMap.put(APP_STATUS_DRAFT,'Draft');
        appStatusMap.put(APP_STATUS_SUBMITTED,'Submitted');
        appStatusMap.put(APP_STATUS_PENDING_REFEREE_CHECKS,'In Progress');
        appStatusMap.put(APP_STATUS_PENDING_INTERVIEW,'In Progress');
        appStatusMap.put(APP_STATUS_SUCCESSFUL,'Successful');
        appStatusMap.put(APP_STATUS_WITHDRAWN,'Withdrawn');
        appStatusMap.put(APP_STATUS_UNSUCCESSFUL_ROLE_FILLED,'Closed');
        appStatusMap.put(APP_STATUS_UNSUCCESSFUL_NOT_SUITABLE_AT_INTERVIEW,'Closed');
        appStatusMap.put(APP_STATUS_UNSUCCESSFUL_NOT_SUITABLE_FOR_INTERVIEW,'Closed');
        appStatusMap.put(APP_STATUS_UNSUCCESSFUL_UNSUITABLE_REFERENCES,'Closed');
        appStatusMap.put(APP_STATUS_ACTIVE,'Active');
        appStatusMap.put(APP_STATUS_INACTIVE,'Inactive');
        appStatusMap.put(APP_STATUS_CONTACT_GVT,'In Progress');
        appStatusMap.put(APP_STATUS_RESIGNED_FROM_ROLE,'Resigned from Role');
        appStatusMap.put(APP_STATUS_UNSUCCESSFUL_UNSUITABLE_RISK_ASSESSMENT,'Closed');
    }
    private User user;
    //UAT Community ID
    //public final String GROUP_ID = '0F9g0000000CcnS';
    //LIVE Community ID
    public final String GROUP_ID = '0F9110000008Q5M';
    
    public final String COMMUNITY_ID = null;
    
    
    
    public List<ConnectAPI.FeedItem> getNewsFeedItems(){
        List<CollaborationGroup> cgList = new List<CollaborationGroup>();
        
        cgList = [select c.Id from CollaborationGroup c where c.Name = 'Volunteer Community' LIMIT 1];
        
        String groupId;
        
        if (cgList.size() > 0){
            groupId = cgList[0].Id;
        }else {
            groupId = GROUP_ID;
        }
        //return ConnectAPI.ChatterFeeds.getFeedItemsFromFeed(COMMUNITY_ID,ConnectApi.FeedType.Record,groupId).items;

        return ConnectAPI.ChatterFeeds.getFeedItemsFromFeed(COMMUNITY_ID, ConnectApi.FeedType.Record, groupId, 0, ConnectApi.FeedDensity.AllUpdates, null, 1, ConnectApi.FeedSortOrder.CreatedDateDesc).items;
    }
    
    public List<Customer_Requests__c> getCustomerRequests(){
        Id currentUserId = UserInfo.getUserId();
        List<Customer_Requests__c> customerRequests = [Select c.OwnerId, c.Id, c.Description__c, c.Customer_Phone__c, c.Customer_Name__c, c.Customer_Name__r.name,
                            c.Customer_Email__c, c.Allocated__c, c.Activity__c, c.Name, c.service__c, c.status__c, c.Date_Time_Opened__c, c.Referral_Contact_Name__r.Name, c.Closed__c From Customer_Requests__c c
                            where c.OwnerId = :currentUserId and c.Closed__c = false Order by c.Date_Time_Opened__c DESC];
        
        return customerRequests;
    }

    
    //2014-01-24 : SM : This new method is for the volunteer applications.  As we are returning ALL applications now, but with 'tailored' statuses
    //(See the appStatusMap above) we need to use a wrapper class rather than just the object.
    public List<ApplicationWrapper> getApplications(){
        List<ApplicationWrapper> appWrapperList = new List<ApplicationWrapper>();
        Id currentUserId = [select contactid from User where id = :UserInfo.getUserId()].contactid;

        RecordType roleRT = [select r.Id from RecordType r where r.Name = 'Application' and r.SobjectType = 'Application__c' LIMIT 1];

        for (Application__c a : [Select a.RecordType.id, a.Applicant__c, a.Applicant__r.Name, a.Role__r.Name, a.Role__r.id, a.status__c, a.start_date__c, a.Volunteer_Coordinator__r.Name, a.Service__c, a.Volunteer_Manager__r.Name, a.Role__r.RNIB_Group__c, a.Role__r.Opportunity_Family__c, a.Role_Title__c, a.application_status__c From Application__c a
                            where a.RecordType.id = :roleRT.id and a.Applicant__r.id = :currentUserId]){
                                ApplicationWrapper appWrapper = new ApplicationWrapper(a);
                                appWrapper.displayStatus = appStatusMap.get(a.Status__c);
                                appWrapperList.add(appWrapper);
                            }        
        return appWrapperList;
    }
    

    public List<Application__c> getCurrentRoles(){
        Id currentUserId = [select contactid from User where id = :UserInfo.getUserId()].contactid;

        RecordType roleRT = [select r.Id from RecordType r where r.Name = 'Role' and r.SobjectType = 'Application__c' LIMIT 1];

        List<Application__c> currentroles = [Select a.RecordType.id, a.Applicant__c, a.Applicant__r.Name, a.Role__r.Name, a.status__c, a.start_date__c, a.Volunteer_Coordinator__r.Name, a.Service__c, a.Volunteer_Manager__r.Name, a.Role__r.RNIB_Group__c, a.Role__r.Opportunity_Family__c, a.Role_Title__c From Application__c a
                            where a.RecordType.id = :roleRT.id and a.Applicant__r.id = :currentUserId and (a.status__c != 'Contact GVT' and a.status__c != 'Inactive')];
        
        return currentroles;
    }

    public User getUser() {
        return user;
    }

    public List<Role_Opportunity__c> getAvaliableOpportunities(){
        String soqlQuery = '';
        user = [SELECT id, contact.id, contact.Region__c, contact.Skills__c,contact.Areas_of_Interest__c FROM User WHERE id = :UserInfo.getUserId()];

        try { 
            soqlQuery = 'Select o.Role_Title__c, o.Active_on_Website__c, o.location__c, Interests__c, Role_Description__c From Role_Opportunity__c o where o.Active_on_Website__c = True';
            
            if (user.Contact.Region__c != null){
                soqlQuery += ' and o.Location__c includes (';
                String[] locSplit = user.Contact.Region__c.split(';');
                for (String s : locSplit){
                    soqlQuery += '\''+s+'\',';  
                }
                soqlQuery = soqlQuery.substring(0,soqlQuery.length()-1);
                soqlQuery += ')';
            }
            
            if (user.Contact.Areas_of_Interest__c != null){
                soqlQuery += ' and o.Interests__c includes (';
                String[] skillSplit = user.Contact.Areas_of_Interest__c.split(';');
                for (String s : skillSplit){
                    soqlQuery += '\''+s+'\',';  
                }
                soqlQuery = soqlQuery.substring(0,soqlQuery.length()-1);
                soqlQuery += ')';
            }
            soqlQuery += 'ORDER BY CreatedDate DESC LIMIT 5';
            
            List<Role_Opportunity__c> availableOpps;
            try {
                availableOpps = Database.query(soqlQuery);
            }catch (DMLException dmlEx){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There has been an error retrieving available Roles'));
            }
            
            
            return availableOpps;
        } 
            catch (Exception e) { 
            }
        return null;
    }
    
    public class ApplicationWrapper {
        
        public Application__c theApplication {get; set;}
        public String displayStatus {get; set;}
        
            public ApplicationWrapper(Application__c inApp){
                this.theApplication = inApp;
            }
    }

}