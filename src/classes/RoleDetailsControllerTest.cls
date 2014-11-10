@isTest (seeAllData=true)
private class RoleDetailsControllerTest {

   static testMethod void testgetRoleDetails(){
   
   date enddate = date.today().addDays(30);
      
      Role_Opportunity__c testRole = new Role_Opportunity__c();
      testRole.Role_Title__c = 'firstname';
      testRole.Location__c = 'lastname';
      testRole.End_Date__c = enddate;
     testRole.Role_Description__c = 'Role Description';
      testRole.What_will_I_be_doing__c ='Doing Something';
      testRole.Hours_per_week__c = 10;
    //  testRole.What_will_I_gain_from_the_role__c = 'Gain';
      testRole.What_support_will_I_be_given__c ='Induction';
      testRole.DBS_Check_required__c = 'DBS Standard';
      testRole.Number_of_References_Required__c = '2';
      
      insert testRole;
    
     PageReference ref = new PageReference('/apex/Role_Details?id=' + testRole.id); 
     test.setCurrentPage(ref);

      RoleDetailsController controller = new RoleDetailsController();
     controller.getRoleDetails();
      
 
  }


static testMethod void testgetRoleDetailsWithApplications(){
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
    roleOpp.Risk_Assessment__c = true; 
    insert roleOpp;
    
    
    RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
    Application__c application = new Application__c(RecordTypeId = appRT.Id);
    
    application.Applicant__c = volunteerContact.Id;
    application.Role__c = roleOpp.Id;
    
    insert application;
   
        
    test.startTest();
    
    system.runAs(volunteerList[0]){
    
	    PageReference ref = new PageReference('/apex/Role_Details?id=' + roleOpp.id); 
    	test.setCurrentPage(ref);

	    RoleDetailsController controller = new RoleDetailsController();
    	controller.getRoleDetails();
    	
    }
    
    test.stopTest();
 
  }


   static testMethod void testgetRoleDetailsNull(){
  
   
     PageReference ref = new PageReference('/apex/Role_Details'); 
     test.setCurrentPage(ref);

     RoleDetailsController controller = new RoleDetailsController();
     controller.getRoleDetails();

  }

}