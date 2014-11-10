/*
* 2014-01-31 : SM : Utility class for any code needed on the Application object
* not covered in ApplicationTriggerMethods or ApplicationFormController
*/
global class ApplicationMethods {
	public static final String DBS_NO_CHECK_REQUIRED = 'No Check Required';
	public static final String STATUS_INACTIVE = 'Inactive';
	public static final String STATUS_ACTIVE = 'Active';
	public static final String STATUS_SUBMITTED = 'Submitted';
	public static final String STATUS_RECRUITMENT_CHECKS_COMPLETE = 'Recruitment Checks Complete';
	public static final String RT_ROLE = 'Role';
	public static final String RT_VOLUNTEER = 'Volunteer';
	public static final String RT_APPLICANT = 'Applicant';
	public static final String PROFILE_APPLICANT = 'Community Login User - Applicants';
	public static final String PROFILE_VOLUNTEER = 'Community Login User - Volunteers';
	public static boolean canContinue {get; set;}
	
	global ApplicationMethods(){
		//Constructor
	}
	
	//This method is a web service as it is called from a button on a standard layout
	//and will clone the passed in Application, plus any associated References 
	webservice static void cloneApplication(String applicationId){
		List<Application__c> originalAppList = new List<Application__c>();
		originalAppList = [Select a.Why_do_you_want_to_volunteer_for_us__c, a.Why_do_work_experience_with_RNIB__c, a.Volunteer_Manager__c, a.Volunteer_Coordinator__c, 
							a.Voluntary_or_Work_Experience__c, a.Vehicle_Check_OK__c, a.Vehicle_Check_Image__c, a.Tell_us_about_yourself__c, a.Suspension_Ended__c, 
							a.Subjects__c, a.Subjects3__c, a.Subjects2__c, a.Status__c, a.Start_Date__c, a.Service__c, a.School_University_HE_Institution__c, 
							a.School_University_HE_Institution3__c, a.School_University_HE_Institution2__c, a.School_College__c, a.School_College_Phone__c, 
							a.School_College_Contact__c, a.Role__c, a.Role_Title__c, a.Role_Source__c, a.Role_Description__c, a.Risk_Assessments__c, 
							a.References_Unavailable__c, a.References_Unavailable_Explanation__c, a.References_OK__c, a.Reference_Check__c, a.RecordTypeId, 
							a.Reason_for_leaving__c, a.Reason_Suspended__c, a.Qualification__c, a.Qualification3__c, a.Qualification2__c, 
							a.Present_Recent_Employment_Voluntary_Work__c, a.Present_Recent_Employment_VoluntaryWork3__c, a.Present_Recent_Employment_VoluntaryWork2__c, 
							a.Number_of_Corporate_Volunteers__c, a.Name_Address_Dates_to_and_from__c, a.Name_Address_Dates_to_and_from3__c, 
							a.Name_Address_Dates_to_and_from2__c, a.Name, a.Membership_of_professional_bodies__c, a.Membership_of_professional_bodies3__c, 
							a.Membership_of_professional_bodies2__c, a.Membership_No__c, a.Membership_No3__c, a.Membership_No2__c, a.Legal_Declariation__c,
							a.Legacy_Volunteer_Role_ID__c, a.Id, a.How_did_you_hear_about_this_Opportunity__c, a.Group_Induction__c, a.Grades__c, a.Grades3__c, 
							a.Grades2__c, a.Experience_Qualifications__c, a.End_Date__c, a.Employer_s_name_address_From_To__c, a.Employer_s_name_address_From_To3__c, 
							a.Employer_s_name_address_From_To2__c, a.Education__c, a.Duties_and_Main_Achievements__c, a.Duties_and_Main_Achievements3__c, 
							a.Duties_and_Main_Achievements2__c, a.Date_of_Suspension__c, a.Criminal_Record_Check__c, a.Criminal_Offence_Details__c, 
							a.Criminal_Check_OK__c, a.Corporate_Account_Phone__c, a.Corporate_Account_Name__c, a.Corporate_Account_Billing_Street__c, 
							a.Corporate_Account_Billing_State__c, a.Corporate_Account_Billing_PostalCode__c, a.Corporate_Account_Billing_Country__c, 
							a.Corporate_Account_Billing_City__c, a.Convicted_of_Criminal_Offence__c, a.Contact_Informed_of_Application_Outcome__c, a.ContactName__c, 
							a.College_Univeristy_Workplace__c, a.College_Univeristy_Workplace_Phone__c, a.College_Univeristy_Workplace_Contact__c, 
							a.Can_Activate_Vehicle__c, a.Can_Activate_References__c, a.Can_Activate_Criminal_Check__c, a.Application_Status__c, a.Applicant__c, 
							a.Accepted_Reference_Checks__c, 
							(Select Id, OwnerId, Name, RecordTypeId, Contact__c, Application__c, Relationship__c, Length_of_relationship__c, 
								Outcome__c, Reference_Type__c, Safeguarding_Issue_Note__c, Role_Title__c, Role_Description__c, How_long_have_you_known_the_above_named__c, 
								In_what_capacity_do_you_know_this_person__c, Ability_to_perform_role__c, Relationships_with_others__c, 
								Honesty_integrity_Ability_to_maintain_co__c, Reliability__c, Ability_to_follow_policies_and_procedure__c, Risk_to_RNIB__c, 
								How_will_be_this_Risk_be_managed__c, Evidence_of_need_for_bringing_person_int__c, Details_of_previous_DBS_Country_checks__c, 
								Previous_Country_Checks__c, Date_of_Previous_Check__c, Recommend_To_RNIB__c, Recommend_To_RNIB_Comments__c, Further_Comments__c, 
								Reference_Received__c, Applicant_Name__c, Role_Involves_Working_With_Children__c, Legacy_Reference_ID__c, Date_Reference_Sent__c, 
								Referee_Email__c, Referee_Work_Phone__c, Referee_Address__c, Date_Reference_Received__c, Suitable_to_Volunteer_with_Children__c, 
								Date_Reference_Return__c, Volunteer_Email1__c, Volunteer_Email__c, Volunteer_Manager_Email__c, Copy_Volunteer_Manager_Email__c 
								From References__r) From Application__c a where a.Id = :applicationId];
		Application__c originalApp;
		Application__c clonedApp;
		List<Reference__c> referenceList;
		List<Reference__c> newReferences = new List<Reference__c>();
		if (originalAppList.size() > 0){
			originalApp = originalAppList[0];
			referenceList = originalApp.References__r;
			
			clonedApp = originalApp.clone(false, true, false, false);
			clonedApp.Status__c = STATUS_SUBMITTED;
			clonedApp.References_OK__c = false;
			clonedApp.Vehicle_Check_OK__c = false;
			clonedApp.Criminal_Check_OK__c = false;
			
			insert clonedApp;
			
			if (referenceList != null){
				for (Reference__c r : referenceList){
					Reference__c clonedReference = r.clone(false, true, false, false);
					clonedReference.Application__c = clonedApp.Id;
					newReferences.add(clonedReference);
				}
				
				insert newReferences;
			}
			
		}
		
		
	}
	
	//This method is a web service as it is called from a button on a standard layout
	//and will clone the passed in Application, plus any associated References 
	public PageReference cloneApplicationFromPage(){
		String applicationId = ApexPages.currentPage().getParameters().get('Id');
		
		List<Application__c> originalAppList = new List<Application__c>();
		originalAppList = [Select a.Why_do_you_want_to_volunteer_for_us__c, a.Why_do_work_experience_with_RNIB__c, a.Volunteer_Manager__c, a.Volunteer_Coordinator__c, 
							a.Voluntary_or_Work_Experience__c, a.Vehicle_Check_OK__c, a.Vehicle_Check_Image__c, a.Tell_us_about_yourself__c, a.Suspension_Ended__c, 
							a.Subjects__c, a.Subjects3__c, a.Subjects2__c, a.Status__c, a.Start_Date__c, a.Service__c, a.School_University_HE_Institution__c, 
							a.School_University_HE_Institution3__c, a.School_University_HE_Institution2__c, a.School_College__c, a.School_College_Phone__c, 
							a.School_College_Contact__c, a.Role__c, a.Role_Title__c, a.Role_Source__c, a.Role_Description__c, a.Risk_Assessments__c, 
							a.References_Unavailable__c, a.References_Unavailable_Explanation__c, a.References_OK__c, a.Reference_Check__c, a.RecordTypeId, 
							a.Reason_for_leaving__c, a.Reason_Suspended__c, a.Qualification__c, a.Qualification3__c, a.Qualification2__c, 
							a.Present_Recent_Employment_Voluntary_Work__c, a.Present_Recent_Employment_VoluntaryWork3__c, a.Present_Recent_Employment_VoluntaryWork2__c, 
							a.Number_of_Corporate_Volunteers__c, a.Name_Address_Dates_to_and_from__c, a.Name_Address_Dates_to_and_from3__c, 
							a.Name_Address_Dates_to_and_from2__c, a.Name, a.Membership_of_professional_bodies__c, a.Membership_of_professional_bodies3__c, 
							a.Membership_of_professional_bodies2__c, a.Membership_No__c, a.Membership_No3__c, a.Membership_No2__c, a.Legal_Declariation__c, 
							a.Legacy_Volunteer_Role_ID__c, a.Id, a.How_did_you_hear_about_this_Opportunity__c, a.Group_Induction__c, a.Grades__c, a.Grades3__c, 
							a.Grades2__c, a.Experience_Qualifications__c, a.End_Date__c, a.Employer_s_name_address_From_To__c, a.Employer_s_name_address_From_To3__c, 
							a.Employer_s_name_address_From_To2__c, a.Education__c, a.Duties_and_Main_Achievements__c, a.Duties_and_Main_Achievements3__c, 
							a.Duties_and_Main_Achievements2__c, a.Date_of_Suspension__c, a.Criminal_Record_Check__c, a.Criminal_Offence_Details__c, 
							a.Criminal_Check_OK__c, a.Corporate_Account_Phone__c, a.Corporate_Account_Name__c, a.Corporate_Account_Billing_Street__c, 
							a.Corporate_Account_Billing_State__c, a.Corporate_Account_Billing_PostalCode__c, a.Corporate_Account_Billing_Country__c, 
							a.Corporate_Account_Billing_City__c, a.Convicted_of_Criminal_Offence__c, a.Contact_Informed_of_Application_Outcome__c, a.ContactName__c, 
							a.College_Univeristy_Workplace__c, a.College_Univeristy_Workplace_Phone__c, a.College_Univeristy_Workplace_Contact__c, 
							a.Can_Activate_Vehicle__c, a.Can_Activate_References__c, a.Can_Activate_Criminal_Check__c, a.Application_Status__c, a.Applicant__c, 
							a.Accepted_Reference_Checks__c, 
							(Select Id, OwnerId, Name, RecordTypeId, Contact__c, Application__c, Relationship__c, Length_of_relationship__c, 
								Outcome__c, Reference_Type__c, Safeguarding_Issue_Note__c, Role_Title__c, Role_Description__c, How_long_have_you_known_the_above_named__c, 
								In_what_capacity_do_you_know_this_person__c, Ability_to_perform_role__c, Relationships_with_others__c, 
								Honesty_integrity_Ability_to_maintain_co__c, Reliability__c, Ability_to_follow_policies_and_procedure__c, Risk_to_RNIB__c, 
								How_will_be_this_Risk_be_managed__c, Evidence_of_need_for_bringing_person_int__c, Details_of_previous_DBS_Country_checks__c, 
								Previous_Country_Checks__c, Date_of_Previous_Check__c, Recommend_To_RNIB__c, Recommend_To_RNIB_Comments__c, Further_Comments__c, 
								Reference_Received__c, Applicant_Name__c, Role_Involves_Working_With_Children__c, Legacy_Reference_ID__c, Date_Reference_Sent__c, 
								Referee_Email__c, Referee_Work_Phone__c, Referee_Address__c, Date_Reference_Received__c, Suitable_to_Volunteer_with_Children__c, 
								Date_Reference_Return__c, Volunteer_Email1__c, Volunteer_Email__c, Volunteer_Manager_Email__c, Copy_Volunteer_Manager_Email__c 
								From References__r) From Application__c a where a.Id = :applicationId];
		Application__c originalApp;
		Application__c clonedApp;
		List<Reference__c> referenceList;
		List<Reference__c> newReferences = new List<Reference__c>();
		if (originalAppList.size() > 0){
			originalApp = originalAppList[0];
			referenceList = originalApp.References__r;
			
			clonedApp = originalApp.clone(false, true, false, false);
			clonedApp.Status__c = STATUS_SUBMITTED;
			clonedApp.References_OK__c = false;
			clonedApp.Vehicle_Check_OK__c = false;
			clonedApp.Criminal_Check_OK__c = false;
			
			insert clonedApp;
			
			if (referenceList != null){
				for (Reference__c r : referenceList){
					Reference__c clonedReference = r.clone(false, true, false, false);
					clonedReference.Application__c = clonedApp.Id;
					newReferences.add(clonedReference);
				}
				
				insert newReferences;
			}
			
		}
		
		PageReference pageRef = new PageReference('/' + clonedApp.Id);
		pageRef.setRedirect(true);
		
		return pageRef;
		
	}
	
	//This method is a web service as it is called from a button on a standard layout
	//and will Activate an application
	webservice static void activateApplication(String applicationId){
		//Get a map of RecordTypes
		Map<String, RecordType> rtMap = new Map<String, RecordType>();
		Map<String, Profile> profileMapByName = new Map<String, Profile>();
		Map<Id, Profile> profileMapById = new Map<Id, Profile>();
		
		for (RecordType r : [select r.Name, r.Id, r.DeveloperName from RecordType r where r.IsActive = true and (r.SObjectType = 'Contact' or r.SObjectType = 'Application__c')]){
			rtMap.put(r.DeveloperName, r);
		}
		
		for (Profile p : [select p.Id, p.Name from Profile p]){
			profileMapByName.put(p.Name, p);
			profileMapById.put(p.Id, p);
		}
		//Make sure we can continue at the end, if all conditions are met
		canContinue = true;
		Application__c theApplication = [Select a.Status__c, a.Vehicle_Check_OK__c, a.Role__c, a.Role__r.Vehicle_Check_Required__c, a.Role__r.DBS_Check_required__c, a.Role__r.Number_of_References_Required__c, 
											a.References_OK__c, a.RecordTypeId, a.Criminal_Check_OK__c, a.Applicant__c From Application__c a where a.Id = :applicationId LIMIT 1];
											
		
		
		if (theApplication != null){
			
			if (STATUS_RECRUITMENT_CHECKS_COMPLETE.equalsIgnoreCase(theApplication.Status__c)){
			
				User userRecord = [select u.Id, u.ProfileId from User u where u.ContactId = :theApplication.Applicant__c LIMIT 1];
				
				system.debug('*** -- Vehicle Checks -- ***');
				//Does this role need a vehicle check, and if so, do we have one?											
				if (theApplication.Role__r.Vehicle_Check_Required__c){
					if (!theApplication.Vehicle_Check_OK__c){
						canContinue = false;
					}
				}
				system.debug('*** -- Can Continue after Vehicle Checks = ' + canContinue + ' -- ***');
				system.debug('*** -- DBS Check -- ***');
				//Does this role need a DBS Check, and if so, do we have one?			
				if (!DBS_NO_CHECK_REQUIRED.equalsIgnoreCase(theApplication.Role__r.DBS_Check_required__c)){
					if (!theApplication.Criminal_Check_OK__c){
						canContinue = false;
					}
				}
				system.debug('*** -- Can Continue after DBS Checks = ' + canContinue + ' -- ***');
				system.debug('*** -- Reference Check -- ***');
				//Are the references all OK?
				integer refsRequired = (theApplication.Role__r.Number_of_References_Required__c == null ? 0 : integer.valueOf(theApplication.Role__r.Number_of_References_Required__c));
				if (refsRequired > 0){
					if (!theApplication.References_OK__c){
						canContinue = false;
					}
				}
				system.debug('*** -- Can Continue after Reference Checks = ' + canContinue + ' -- ***');
				//Get the contact record so we can update the Record Type
				Contact theApplicant = [select c.RecordTypeId, c.Status__c from Contact c where c.Id = :theApplication.Applicant__c LIMIT 1];
				
				//Only update the contact if it's INACTIVE at present (change status and change record type)
				//2014-02-11 : SM : Changing this - we don't need to check the status after all
				//if (STATUS_INACTIVE.equalsIgnoreCase(theApplicant.Status__c)){
				theApplicant.Status__c = STATUS_ACTIVE;
				if (theApplicant.RecordTypeId == rtMap.get(RT_APPLICANT).Id){
					theApplicant.RecordTypeId = rtMap.get(RT_VOLUNTEER).Id;
				}
				//}//else {
				//	canContinue = false;				
					//We can't continue, as the contact ISN'T Inactive
				//}
				
				//Update the application record type and status
				theApplication.RecordTypeId = rtMap.get(RT_ROLE).Id;
				theApplication.Status__c = STATUS_ACTIVE;
				if (PROFILE_APPLICANT.equalsIgnoreCase(profileMapById.get(userRecord.ProfileId).Name)){
					userRecord.ProfileId = profileMapByName.get(PROFILE_VOLUNTEER).Id;
				}
				
				//If we can continue, update the records
				if (canContinue){
					//update userRecord;
					update theApplicant;
					update theApplication;
					ApplicationMethods.updateUserRecord(userRecord.Id, profileMapByName.get(PROFILE_VOLUNTEER).Id);
				}else {
					//Do we need to return anything if it hasn't worked?
				}
			}
			
		}
	}
	
	@future
	public static void updateUserRecord(String userId, String profileId){
		User userRecord = [select u.Id, u.ProfileId from User u where u.Id = :userId LIMIT 1];
		userRecord.ProfileId = profileId;
		update userRecord;
	}
	
	@IsTest(SeeAllData=true)
	private static void testButton(){
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
	 	volunteerContact.Status__c = TestUtilities.STATUS_INACTIVE;
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
		roleOpp.Status__c = TestUtilities.STATUS_APPROVED;
		roleOpp.Risk_Assessment__c = true;
		roleOpp.What_will_I_be_doing2__c = 'Assist with a variety of admin tasks';
		insert roleOpp;
		
		
		RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
		Application__c application = new Application__c(RecordTypeId = appRT.Id);
		
		application.Applicant__c = volunteerContact.Id;
		
		
		application.Role__c = roleOpp.Id;
		application.Vehicle_Check_OK__c = true;
		application.Criminal_Check_OK__c = true;
		application.References_OK__c = true;
		application.Status__c = ApplicationMethods.STATUS_RECRUITMENT_CHECKS_COMPLETE;
		insert application;
		
    	Contact referenceContact1 = new Contact();
            referenceContact1.FirstName = 'Test';
            referenceContact1.LastName = 'Reference1';
            referenceContact1.MailingStreet = '456 Ref One Road';
            referenceContact1.MailingCity = 'London';
            referenceContact1.MailingState = 'London';
            referenceContact1.MailingPostalCode = 'W1 3RR';
            referenceContact1.Email = 'test.reference1@myemail.com';
            referenceContact1.Phone = '02072222222';
        insert referenceContact1;
    
        Contact referenceContact2 = new Contact();
            referenceContact2.FirstName = 'Test';
            referenceContact2.LastName = 'Reference1';
            referenceContact2.MailingStreet = '456 Ref One Road';
            referenceContact2.MailingCity = 'London';
            referenceContact2.MailingState = 'London';
            referenceContact2.MailingPostalCode = 'W1 3RR';
            referenceContact2.Email = 'test.reference1@myemail.com';
            referenceContact2.Phone = '02072222222';
        insert referenceContact2;
    //Contact r1 = TestUtilities.getReferenceContact1();
    //insert r1;

    //Contact r2 = TestUtilities.getReferenceContact2();
    //insert r2;
		
		RecordType standardRef = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_STANDARD_REFERENCE);
		Reference__c ref1 = new Reference__c(RecordTypeId = standardRef.Id);
		ref1.Contact__c = referenceContact1.Id;
		ref1.Application__c = application.Id;
		insert ref1;
		Reference__c ref2 = new Reference__c(RecordTypeId = standardRef.Id);
		ref2.Contact__c = referenceContact2.Id;
		ref2.Application__c = application.Id;
		insert ref2;
		
		system.debug('*** -- finished inserting all records - about to start test -- ***');
		
		test.startTest();
		
		ApplicationMethods.activateApplication(application.Id);
				
		
		test.stopTest();
		
		
	}
	
	@IsTest(SeeAllData=true)
	private static void testClone(){
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
	 	volunteerContact.Status__c = TestUtilities.STATUS_INACTIVE;
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
		roleOpp.Status__c = TestUtilities.STATUS_APPROVED;
		roleOpp.Risk_Assessment__c = true;
		roleOpp.What_will_I_be_doing2__c = 'Assist with a variety of admin tasks';
		insert roleOpp;
		
		
		RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
		Application__c application = new Application__c(RecordTypeId = appRT.Id);
		
		application.Applicant__c = volunteerContact.Id;
		
		
		application.Role__c = roleOpp.Id;
		application.Vehicle_Check_OK__c = true;
		application.Criminal_Check_OK__c = true;
		application.References_OK__c = true;
		insert application;
		
    	Contact referenceContact1 = new Contact();
            referenceContact1.FirstName = 'Test';
            referenceContact1.LastName = 'Reference1';
            referenceContact1.MailingStreet = '456 Ref One Road';
            referenceContact1.MailingCity = 'London';
            referenceContact1.MailingState = 'London';
            referenceContact1.MailingPostalCode = 'W1 3RR';
            referenceContact1.Email = 'test.reference1@myemail.com';
            referenceContact1.Phone = '02072222222';
        insert referenceContact1;
    
        Contact referenceContact2 = new Contact();
            referenceContact2.FirstName = 'Test';
            referenceContact2.LastName = 'Reference1';
            referenceContact2.MailingStreet = '456 Ref One Road';
            referenceContact2.MailingCity = 'London';
            referenceContact2.MailingState = 'London';
            referenceContact2.MailingPostalCode = 'W1 3RR';
            referenceContact2.Email = 'test.reference1@myemail.com';
            referenceContact2.Phone = '02072222222';
        insert referenceContact2;
    //Contact r1 = TestUtilities.getReferenceContact1();
    //insert r1;

    //Contact r2 = TestUtilities.getReferenceContact2();
    //insert r2;
		
		RecordType standardRef = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_STANDARD_REFERENCE);
		Reference__c ref1 = new Reference__c(RecordTypeId = standardRef.Id);
		ref1.Contact__c = referenceContact1.Id;
		ref1.Application__c = application.Id;
		insert ref1;
		Reference__c ref2 = new Reference__c(RecordTypeId = standardRef.Id);
		ref2.Contact__c = referenceContact2.Id;
		ref2.Application__c = application.Id;
		insert ref2;
		
		system.debug('*** -- finished inserting all records - about to start test -- ***');
		
		test.startTest();
		
		ApplicationMethods.cloneApplication(application.Id);
				
		
		test.stopTest();
		
		
	}
	
	@IsTest(SeeAllData=true)
	private static void testCloneFromPage(){
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
	 	volunteerContact.Status__c = TestUtilities.STATUS_INACTIVE;
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
		roleOpp.Status__c = TestUtilities.STATUS_APPROVED;
		roleOpp.Vehicle_Check_Required__c = true;
		roleOpp.Risk_Assessment__c = true;
		roleOpp.What_will_I_be_doing2__c = 'Assist with a variety of admin tasks';
		insert roleOpp;
		
		
		RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
		Application__c application = new Application__c(RecordTypeId = appRT.Id);
		
		application.Applicant__c = volunteerContact.Id;
		
		
		application.Role__c = roleOpp.Id;
		application.Vehicle_Check_OK__c = true;
		application.Criminal_Check_OK__c = true;
		application.References_OK__c = true;
		insert application;
		
    	Contact referenceContact1 = new Contact();
            referenceContact1.FirstName = 'Test';
            referenceContact1.LastName = 'Reference1';
            referenceContact1.MailingStreet = '456 Ref One Road';
            referenceContact1.MailingCity = 'London';
            referenceContact1.MailingState = 'London';
            referenceContact1.MailingPostalCode = 'W1 3RR';
            referenceContact1.Email = 'test.reference1@myemail.com';
            referenceContact1.Phone = '02072222222';
        insert referenceContact1;
    
        Contact referenceContact2 = new Contact();
            referenceContact2.FirstName = 'Test';
            referenceContact2.LastName = 'Reference1';
            referenceContact2.MailingStreet = '456 Ref One Road';
            referenceContact2.MailingCity = 'London';
            referenceContact2.MailingState = 'London';
            referenceContact2.MailingPostalCode = 'W1 3RR';
            referenceContact2.Email = 'test.reference1@myemail.com';
            referenceContact2.Phone = '02072222222';
        insert referenceContact2;
    //Contact r1 = TestUtilities.getReferenceContact1();
    //insert r1;

    //Contact r2 = TestUtilities.getReferenceContact2();
    //insert r2;
		
		RecordType standardRef = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_STANDARD_REFERENCE);
		Reference__c ref1 = new Reference__c(RecordTypeId = standardRef.Id);
		ref1.Contact__c = referenceContact1.Id;
		ref1.Application__c = application.Id;
		insert ref1;
		Reference__c ref2 = new Reference__c(RecordTypeId = standardRef.Id);
		ref2.Contact__c = referenceContact2.Id;
		ref2.Application__c = application.Id;
		insert ref2;
		
		system.debug('*** -- finished inserting all records - about to start test -- ***');
		
		test.startTest();
		
		PageReference testPage = Page.ApplicationClone;
		testPage.getParameters().put('Id',application.Id);
		test.setCurrentPage(testPage);
		
		ApplicationMethods am = new ApplicationMethods();
		PageReference pr = am.cloneApplicationFromPage();
				
		
		test.stopTest();
		
		
	}

}