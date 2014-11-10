/*
* 2014-01-31 : SM : Role_Opportunities class, used to hold methods that run on the Role_Opportunity record
* class defined as Global so that buttons can be called from standard Salesforce pages
*/
global class Role_Opportunities {
    global final static String DRAFT_STATUS = 'Draft';
    global final static String SUBMITTED_STATUS = 'Submitted';
    global final static String PENDING_REFEREE_STATUS = 'Pending Referee Checks';
    global final static String PENDING_INTERVIEWS_STATUS = 'Pending Interviews';
    global final static String REFERENCES_SUCCESSFUL_STATUS = 'References Successful';
    global final static String RECRUITMENT_CHECKS_COMPLETE_STATUS = 'Recruitment Checks Complete';
    global final static String UNSUCCESSFUL_ROLE_FILLED_STATUS = 'Unsuccessful - Role Filled';
    global final static String PENDING_REFEREE_DBS_CHECKS_STATUS = 'Pending Referee/CR Checks';
    global final static String OPP_CLOSED_STATUS = 'Closed';
    global final static String OPP_DRAFT_STATUS = 'Draft';
    
    //Webservice method to be called from a standard Salesforce layout, to CLONE a Role_Opportunity
    //and set the status to 'Draft' and the Active On Website to FALSE
    webservice static void cloneOpportunity(String oppId) {
        Role_Opportunity__c clonedRole;
        Role_Opportunity__c originalRole = [Select r.Work_Location__c, r.Withdrawn_Reason__c, r.What_will_I_gain_from_the_role__c,r.What_will_I_be_doing__c, r.What_will_I_be_doing2__c, 
                                        r.What_support_will_I_be_given__c, r.What_skills_and_qualities_required__c, r.Welcome_Pack__c, r.Waiting_List__c, r.Volunteer_Manager__c, 
                                        r.Volunteer_Coordinator__c, r.Vehicle_Training_Required__c, r.Vehicle_Check_Required__c, r.SystemModstamp, r.Strategic_Targets__c, r.Strategic_Priority__c,    
                                        r.Strategic_Outcomes__c, r.Strategic_Area__c, r.Status__c, r.Start_Date__c, r.Skills__c, r.Service__c, r.Role_involve_working_with_Children__c, r.Role_Type__c, 
                                        r.Role_Title__c,r.Role_Description__c, r.Risk_Assessment__c, r.RecordTypeId, r.RNIB_Group__c, r.OwnerId, r.Other_Sources__c, r.Opportunity_Family__c, 
                                        r.Number_of_Successful_Applicants__c, r.Number_of_Spaces_Left__c, r.Number_of_References_Required__c, r.Number_of_Applications__c, r.Name, r.Location__c, 
                                        r.Legacy_Role_ID__c, r.Interests__c, 
                                        r.Induction_Call_Required__c, r.If_not_why_not__c, r.Id, r.Hours_per_week__c, r.End_Date__c, r.End_Date_Minus_7_Days__c, 
                                        r.Do_you_want_your_opportunity_advertised__c, r.Date_Submitted_for_Approval__c, r.Date_Approved__c, r.DBS_Check_required__c, r.Criminal_Record_Check_advertised__c, 
                                        r.CreatedDate, r.CreatedById, r.Capacity__c, r.Budget_Available__c, r.Availability__c, r.Advertise_Role__c, r.Additional_Location_Information__c, 
                                        r.Active_on_Website__c, r.Number_Of_Times_Cloned__c From Role_Opportunity__c r where r.Id = :oppId LIMIT 1];
                                        
        if (originalRole != null){
            clonedRole = originalRole.Clone(false, true, false, false);
            clonedRole.Status__c = OPP_DRAFT_STATUS;
            clonedRole.Active_on_Website__c = false;
            
            insert clonedRole;
            
            System.debug('####-----DEBUG-----####');
            
            //We can't return a page reference as this is a webservice method
            //Do we need to change the CLONED opp in any way to identify it after the save - i.e. change the name etc.
            integer numOfTimesCloned = (originalRole.Number_Of_Times_Cloned__c == null ? 0 : integer.valueOf(originalRole.Number_Of_Times_Cloned__c));
            originalRole.Number_Of_Times_Cloned__c = numOfTimesCloned + 1;
            
            update originalRole; 
        }
    }
    
    //Webservice method to be called from a standard Salesforce layout, to mark a Role_Opportunity as 'Closed'
    webservice static void closeOpportunity(String oppId) {
        List<Contact> contactList = new List<Contact>();
        List<Contact> contactsToSave = new List<Contact>();
        List<Application__c> appListToSave = new List<Application__c>();
        Set<Id> contactIdSet = new Set<Id>();
        Role_Opportunity__c theOpp = [Select r.Status__c, r.Id, (Select Applicant__c, Status__c From Applications__r) 
                                    From Role_Opportunity__c r where r.Id = :oppId];
                                    
        if (theOpp != null){
            theOpp.Status__c = OPP_CLOSED_STATUS;
            if (theOpp.Active_on_Website__c){
                theOpp.Active_on_Website__c = false;
            }
            for (Application__c a : theOpp.Applications__r){
                if (SUBMITTED_STATUS.equalsIgnoreCase(a.Status__c) || 
                    PENDING_REFEREE_STATUS.equalsIgnoreCase(a.Status__c) ||
                    PENDING_INTERVIEWS_STATUS.equalsIgnoreCase(a.Status__c) ||
                    REFERENCES_SUCCESSFUL_STATUS.equalsIgnoreCase(a.Status__c) ||
                    DRAFT_STATUS.equalsIgnoreCase(a.Status__c) || 
                    RECRUITMENT_CHECKS_COMPLETE_STATUS.equalsIgnoreCase(a.Status__c) || 
                    UNSUCCESSFUL_ROLE_FILLED_STATUS.equalsIgnoreCase(a.Status__c) || 
                    PENDING_REFEREE_DBS_CHECKS_STATUS.equalsIgnoreCase(a.Status__c)){
                        a.Status__c = UNSUCCESSFUL_ROLE_FILLED_STATUS;
                        appListToSave.add(a);
                        contactIdSet.add(a.Applicant__c);
                    }
                
            }
            contactList = [select c.Waitlist_Opportunity__c, c.On_Waitlist__c from Contact c where c.Id in :contactIdSet];
            for (Contact c : contactList){
                if (!c.On_Waitlist__c){
                    c.On_Waitlist__c = true;
                    c.Waitlist_Opportunity__c = theOpp.Id;
                    contactsToSave.add(c);
                }
            }
            
            if (appListToSave.size() > 0){
                update appListToSave;
            }
            if (contactsToSave.size() > 0){
                update contactsToSave;
            }
            
            update theOpp;
            
        }
    }
    
    @IsTest(SeeAllData=true)
    private static void testCloseOpp(){
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
        roleOpp.Risk_Assessment__c = true;
        insert roleOpp;
        
        
        RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
        Application__c application = new Application__c(RecordTypeId = appRT.Id);
        
        application.Applicant__c = volunteerContact.Id;
        
        
        application.Role__c = roleOpp.Id;
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
        
        ApexPages.StandardController std = new ApexPages.StandardController(roleOpp);
        test.startTest();
        
        Role_Opportunities.cloneOpportunity(roleOpp.Id);
        
        Role_Opportunities.closeOpportunity(roleOpp.Id);
        
        test.stopTest();
        
        
    }
}