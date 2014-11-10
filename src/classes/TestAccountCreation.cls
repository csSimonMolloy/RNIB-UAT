/**
* 2014-03-03 : SM : Test class to test the AccountCreation class
 */
@isTest (seeAllData=true)
private class TestAccountCreation {

    static testMethod void Test1() {
        //Test Data
        Profile saProfile = [select p.Id from Profile p where Name = 'System Administrator' LIMIT 1];
	 	Profile vProfile = [select p.Id from Profile p where Name = 'Community Login User - Volunteers' LIMIT 1];
	 	List<User>userList = [select u.Id from User u where u.IsActive = true and u.ProfileId = :saProfile.Id LIMIT 2];
	 	List<User>volunteerList = [select u.Id, u.ContactId from User u where u.ProfileId = :vProfile.Id and IsActive = true and u.ContactId != null];
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
	 	
	 	User volunteerMgr = userList[0];
	 	User volunteerCoord = userList[1];
	 	RecordType standardRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_STANDARD);
		Role_Opportunity__c roleOpp = TestUtilities.getRoleOpportunity(TestUtilities.RT_STANDARD, standardRT.Id);
		roleOpp.Volunteer_Manager__c = volunteerMgr.Id;
		roleOpp.Volunteer_Coordinator__c = volunteerCoord.Id;
		roleOpp.Role_involve_working_with_Children__c = 'No';
		roleOpp.Number_of_References_Required__c = '2';
		roleOpp.Active_on_Website__c = true;
		roleOpp.Status__c = 'Approved';
		roleOpp.DBS_Check_required__c = 'DBS Standard';
		roleOpp.Vehicle_Check_Required__c = true; 
		insert roleOpp;
		
		
		RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
		Application__c application = new Application__c(RecordTypeId = appRT.Id);
		
		application.Applicant__c = volunteerContact.Id;
		application.Role__c = roleOpp.Id;
		
		//Corporate Account information
		application.Corporate_Account_Name__c = 'Test Corporate Account';
		application.Corporate_Account_Phone__c = '01616161616';
		application.Corporate_Account_Billing_Street__c = '123 Fake Street';
		application.Corporate_Account_Billing_City__c = 'London';
		application.Corporate_Account_Billing_State__c = 'London';
		application.Corporate_Account_Billing_PostalCode__c = 'E12 4RR';
		application.Corporate_Account_Billing_Country__c = 'UK';
		
		
		insert application;
			
		system.debug('*** -- finished inserting all records - about to start test -- ***');
		test.startTest();
		
		AccountCreation ac = new AccountCreation();
		
		test.stopTest();
    }
}