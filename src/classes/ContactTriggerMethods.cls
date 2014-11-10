/*
* 2014-01-14 : SM : Class to hold methods called from the ContactTrigger
*/
public class ContactTriggerMethods {

	public static void setHolidayField(List<Contact> inContacts){
		List<Id> contactIds = new List<Id>();
		Map<Id, User> userMap = new Map<Id, User>();
		Map<Id, User> usersToSave = new Map<Id, User>();
		for (Contact c : inContacts){
			contactIds.add(c.Id);
		}
		
		for (User u : [select u.Id, u.Holiday__c, u.ContactId from User u where u.ContactId in :contactIds]){
			userMap.put(u.ContactId, u);
		}
		
		for (Contact c : inContacts){
			User conUser = userMap.get(c.Id);
			if (conUser != null){
				if (c.Holiday__c){
					conUser.Holiday__c = true;
					if (!usersToSave.containsKey(conUser.Id)){
						usersToSave.put(conUser.Id, conUser);
					}
				}else {
					conUser.Holiday__c = false;
					if (!usersToSave.containsKey(conUser.Id)){
						usersToSave.put(conUser.Id, conUser);
					}
				}
			}
			
		}
		
		update usersToSave.values();
		
	}
	
	//This method clears the Location fields and the Mapping Status fields if any parts of the contacts address has changed
	//It will also update any corresponding Customer Requests records
	public static void clearLocationFields(List<Contact> inContacts){
		Set<Id> contactIds = new Set<Id>();
		Map<Id, Customer_Requests__c> customerRequests = new Map<Id, Customer_Requests__c>();
		List<Customer_Requests__c> crToSave = new List<Customer_Requests__c>();
		for (Contact c : inContacts){
			contactIds.add(c.Id);
		}
		
		for (Customer_Requests__c cr : [select c.Customer_Name__c, c.Mapping_Status__c, c.Location__Latitude__s, c.Location__Longitude__s from Customer_Requests__c c where c.Customer_Name__c in :contactIds]){
			customerRequests.put(cr.Customer_Name__c, cr);
		}
		
		for (Contact c : inContacts){
			c.Mapping_Status__c = null;
			c.Location__Latitude__s = null;
			c.Location__Longitude__s = null;			
			Customer_Requests__c conCR = customerRequests.get(c.Id);
			if (conCR != null){
				conCR.Mapping_Status__c = null;
				conCR.Location__Latitude__s = null;
				conCR.Location__Longitude__s = null;
				crToSave.add(conCR);
			}
		}
		
		if (crToSave.size() > 0){
			update crToSave;
		}
	}
	
	public static void assignContactToAccount(List<Contact> inRecords){
		String accountName = 'Individual'; 
		Account individualAccount = [select a.Id from Account a where a.Name = :accountName LIMIT 1];
		
		if (individualAccount != null){
			for (Contact c : inRecords){
				if (c.AccountId == null){
					c.AccountId = individualAccount.Id;
				}
			}
		}
		
	}
	
	@isTest (seeAllData=true)
	private static void testClearLocation(){
		Profile saProfile = [select p.Id from Profile p where Name = 'System Administrator' LIMIT 1];
	    Profile vProfile = [select p.Id from Profile p where Name = 'Community Login User - Volunteers' LIMIT 1];
	    List<User>userList = [select u.Id from User u where u.IsActive = true and u.ProfileId = :saProfile.Id LIMIT 2];
	    List<User>volunteerList = [select u.Id, u.ContactId from User u where u.ProfileId = :vProfile.Id and IsActive = true];
	    Contact volunteerContact = TestUtilities.getContactRecord(volunteerList[0].ContactId);
	    if (volunteerContact.FirstName == null) volunteerContact.FirstName = 'Test';
	    if (volunteerContact.LastName == null) volunteerContact.LastName = 'Contact';
	    if (volunteerContact.Email == null) volunteerContact.Email = volunteerContact.FirstName.toLowerCase() + '.' + volunteerContact.LastName.toLowerCase() + '@myemail.com';
	    if (volunteerContact.MailingStreet == null) volunteerContact.MailingStreet = '123 Fake Street';
	    if (volunteerContact.MailingCity == null) volunteerContact.MailingCity = 'London';
	    if (volunteerContact.MailingState == null) volunteerContact.MailingState = 'London';
	    if (volunteerContact.MailingPostalCode == null) volunteerContact.MailingPostalCode = 'EC12 1PR';
	    if (volunteerContact.Phone == null) volunteerContact.Phone = '02071111111';
	    update volunteerContact;
	    
	    List<Contact> contactList = new List<Contact>();
	    contactList.add(volunteerContact);
	    
	    test.startTest();
	    
	    ContactTriggerMethods.assignContactToAccount(contactList);
	    
	    ContactTriggerMethods.setHolidayField(contactList);
	    
	    ContactTriggerMethods.clearLocationFields(contactList);
	    
	    test.stopTest();
	}

}