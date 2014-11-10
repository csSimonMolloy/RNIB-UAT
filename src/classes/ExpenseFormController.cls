/*
* 2014-04-04 : SM : ExpenseFormController class.  Used on the Expense Form VF page to offer extra functionality
*/
public with sharing class ExpenseFormController {

	//final variables
	public final String USER_TYPE_STANDARD = 'Standard';
	public final String USER_TYPE_GUEST = 'Guest';
	public final String USER_TYPE_PORTAL = 'CspLitePortal';

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
	public ApexPages.StandardController eController {get; set;}
	public boolean isPortalUser {get; set;}
	public Contact portalContact {get; set;}
	public Expense_Form__c ef {get; set;}
		
	//Constructor with standard controller from Time_Donation__c
	public ExpenseFormController(ApexPages.standardController std){
		isPortalUser = false;
		eController = std;
		
		ef = (Expense_Form__c) std.getRecord();
		
		if (isLoggedIn){
			User loggedInUser = [select u.Id, u.ContactId, u.UserType from User u where u.Id = :UserInfo.getUserId() LIMIT 1];
			//Check user type if logged in to determine which Applications to return
			if (USER_TYPE_PORTAL.equalsIgnoreCase(UserInfo.getUserType())){
				isPortalUser = true;
				portalContact = [select c.Name, c.Id from Contact c where c.Id = :loggedInUser.ContactId LIMIT 1];
				appList = [Select a.Applicant__r.Name, a.Volunteer_Manager__r.Name, a.Volunteer_Coordinator__r.Name, a.Status__c, a.Role__r.Name, a.Role_Title__c, a.Role_Description__c, a.Name, a.Id, a.Applicant__c From Application__c a where a.Applicant__c = :loggedInUser.ContactId];	
			}else {
				//appList = [Select a.Applicant__r.Name, a.Volunteer_Manager__r.Name, a.Volunteer_Coordinator__r.Name, a.Status__c, a.Role__r.Name, a.Role_Title__c, a.Role_Description__c, a.Name, a.Id, a.Applicant__c From Application__c a];
			}
		}
	}
	
	public PageReference save(){
		ef.Volunteer_Role__c = selectedApplication;
		
		return eController.Save();
		
	}
	
	//Save & New functionality
	public PageReference saveAndNew(){
		PageReference pageRef;
		
		eController.save();
		
		pageRef = new PageReference('/a07/e?retURL=/a07/o');
		
		pageRef.setRedirect(true);
		
		return pageRef;
		
	}

}