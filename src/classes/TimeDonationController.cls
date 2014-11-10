/*
* 2014-04-04 : SM : TimeDonationController class.  Used on the TimeDonation VF page to offer extra functionality
*/
public with sharing class TimeDonationController {

    //final variables
    public final String TIME_DONATION_OBJECT_ID = '01Ib0000000TM8g';
    public final String EXPENSE_OBJECT_ID = '01Ib0000000TM8Y';
    public final String USER_TYPE_STANDARD = 'Standard';
    public final String USER_TYPE_GUEST = 'Guest';
    public final String USER_TYPE_PORTAL = 'CspLitePortal';
    public final String STATUS_ACTIVE = 'Active';

    //Check for logged in user
    public boolean isLoggedIn {
        get {
            if (isLoggedIn == null){
                if (!'GUEST'.equalsIgnoreCase(UserInfo.getUserType())){
                    isLoggedIn = true;
                }else {
                    isLoggedIn = false;
                }
            }
            return isLoggedIn;
        }
        set;
    }
    
    public List<Application__c> applist {get; set;}
    public User loggedInUser {get; set;}
    public Id selectedApplication {get; set;}
    public String applicationName {get; set;}
    public ApexPages.StandardController tdController {get; set;}
    public boolean isPortalUser {get; set;}
    public Contact portalContact {get; set;}
    public Time_Donation__c td {get; set;}
    
    //Constructor with standard controller from Time_Donation__c
    public TimeDonationController(ApexPages.standardController std){
        tdController = std;
        isPortalUser = false;
        td = (Time_Donation__c) std.getRecord();
        
        if (isLoggedIn){
            User loggedInUser = [select u.Id, u.ContactId, u.UserType from User u where u.Id = :UserInfo.getUserId() LIMIT 1];
            //Check user type if logged in to determine which Applications to return
            if (USER_TYPE_PORTAL.equalsIgnoreCase(UserInfo.getUserType())){
                isPortalUser = true;
                portalContact = [select c.Name, c.Id from Contact c where c.Id = :loggedInUser.ContactId LIMIT 1];
                td.Volunteer_Name__c = portalContact.Id;
                appList = [Select a.Applicant__r.Name, a.Volunteer_Manager__r.Name, a.Volunteer_Coordinator__r.Name, a.Status__c, a.Role__r.Name, a.Role_Title__c, a.Role_Description__c, a.Name, a.Id, a.Applicant__c From Application__c a where a.Applicant__c = :loggedInUser.ContactId and a.Status__c = :STATUS_ACTIVE];   
            }else {
                //appList = [Select a.Applicant__r.Name, a.Volunteer_Manager__r.Name, a.Volunteer_Coordinator__r.Name, a.Status__c, a.Role__r.Name, a.Role_Title__c, a.Role_Description__c, a.Name, a.Id, a.Applicant__c From Application__c a];
            }
        }
    }
    
    public PageReference save(){
        td.Volunteer_Role__c = selectedApplication;
        
        return tdController.Save();
        
    }
    
    //Save & New functionality
    public PageReference saveAndNew(){
        PageReference pageRef;
        
        tdController.save();
        
        pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=' + TIME_DONATION_OBJECT_ID);
        
        pageRef.setRedirect(true);
        
        return pageRef;
        
    }

}