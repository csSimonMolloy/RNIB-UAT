@isTest(SeeAllData=true)
private class CustomerRequestTest {
	
	static testMethod void testCustomerRequest(){

 	Test.startTest();

 	PageReference ref = new PageReference('/apex/customerquest'); 
 	test.setCurrentPage(ref);
 	
 	// Create a individual account based on the queried account.
 	
 		Account a = new Account(Name='Individual');
        insert a; 

 	//create CustomerRequest

 	CustomerRequest obj = new CustomerRequest();
        obj.FirstName = 'Test';
        obj.LastName = 'LastName';
        obj.Phone = '013141';
        obj.MobilePhone = '013141';
        obj.Email = 'test@salesforce.com';
        obj.Street = 'Street1';
        obj.Street2 = 'Street2';
        obj.City = 'City';
        obj.Postcode = 'WD13 8DS';
        obj.Country = 'Test';

        obj.Activity = 'To Be Defined';
        obj.Description = 'Test';

        obj.isReferral = true;

        obj.referrallastname = 'Test';
        obj.referrallastname = 'LastNameReferrer';
        obj.referralorganisation = 'TestCompany';
        obj.adviseReferrer = true;
        obj.referralphone = '0189279';
        obj.referralemail = 'testreferral@salesforce.com';
        obj.referralstreet = 'Street1';
        obj.referralstreet2 = 'Street2';
        obj.referralcity = 'City';
        obj.referralpostcode = 'WD13 8DS';
        obj.referralcounty = 'Test';
    
        system.assert(obj.save()!=null);

     	CustomerRequest controller = new CustomerRequest();
     	
     	List<SelectOption> salutationList = controller.getSalutationList();
     	List<SelectOption> serviceList = controller.getServiceList();
     	List<SelectOption> activityList = controller.getActivityList();
     	List<SelectOption> deviceList = controller.getDeviceList();
     	List<SelectOption> referralTypeList = controller.getReferralTypeList();
     	
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
     	
     	Customer_Requests__c cr = TestUtilities.getCustomerRequest();
     	Contact customer = TestUtilities.getCustomerContact();
     	
     	insert customer;
     	
     	cr.Customer_Name__c = customer.Id;
     	insert cr;
		cr.Status__c = 'Closed - Approved';
		cr.Total_Number_of_Hours_Donated_to_Resolve__c = 10;
		cr.Assigned_Volunteer__c = volunteerContact.Id;
     	update cr;
     	

 	Test.stopTest();

	}
	
}