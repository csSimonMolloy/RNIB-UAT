global class CustomerRequestResponseController {
    global String whichAction {get; set;}
    global Id customerRequestId {get; set;}
    global Id volunteerId {get; set;}
    global boolean alreadyAccepted {get; set;}
    global boolean doAcceptedForward {get; set;}
    global boolean showRejected {get; set;}
    global String openRequestURL {get; set;}
    global final String ACTION_PARAM = 'ACTION';
    global final String ID_PARAM = 'CR';
    global final String VOLUNTEER_ID = 'V';
    global final String RESPONSE_ACCEPT = 'Accept';
    global final String RESPONSE_REJECT = 'Reject';
    global final String RT_CUSTOMER_REQUEST_PORTAL = 'Customer Requests - Portal';
    global final String CRN_STATUS_ACCEPTED = 'Accepted';
    global final String CRN_STATUS_ACCEPTED_NOT_AVAILABLE = 'Accepted but no longer available';
    global final String CRN_STATUS_REJECTED = 'Rejected';
    //Change this URL for TEST / LIVE as approproate
    //global final String PORTAL_URL = 'https://uat-rnib-community-uat.cs17.force.com/';
    global final String PORTAL_URL = 'https://rnib.force.com/';

    global CustomerRequestResponseController(){
        whichAction = ApexPages.currentPage().getParameters().get(ACTION_PARAM);
        customerRequestId = ApexPages.currentPage().getParameters().get(ID_PARAM);
        volunteerId = ApexPages.currentPage().getParameters().get(VOLUNTEER_ID);
        alreadyAccepted = false;
        doAcceptedForward = false;
        showRejected = false;
                
        system.debug('** -- whichAction = ' + whichAction + ' -- ***');
        system.debug('** -- CR = ' + customerRequestId + ' -- ***');
        system.debug('** -- V = ' + volunteerId + ' -- ***');
    }
    
    global PageReference doAction(){
        system.debug('*** -- into doAction function with ' + whichAction + ' and CR =  ' + customerRequestId + ' and V = ' + volunteerId + ' -- ***');
        PageReference pageRef;
        Customer_Requests__c cr = [select c.OwnerId, c.Allocated__c from Customer_Requests__c c where c.Id = :customerRequestId LIMIT 1];
        User volunteerUser = [select u.Id from User u where u.ContactId = :volunteerId and u.IsActive = true LIMIT 1];
        User gvtUser = [select u.Id from User u where u.Name = 'GVT' and u.IsActive = true LIMIT 1];
        Group gvtAdmin = [select g.Id, g.Name, g.DeveloperName from Group g where g.DeveloperName = 'GVT_Administrators' LIMIT 1];
        Contact volunteerContact = [select c.Id, c.OwnerId from Contact c where c.Id = :volunteerId LIMIT 1];
        RecordType crRT = [select r.Id from RecordType r where r.Name = :RT_CUSTOMER_REQUEST_PORTAL and r.isActive = true and r.SobjectType = 'Customer_Requests__c' LIMIT 1];
        CR_Notification__c crn = [Select c.Id, c.Volunteer__c, c.Status__c, c.Customer_Request__c, c.Date_Notification_Sent__c From CR_Notification__c c where 
                                    c.Volunteer__c = :volunteerId and
                                    c.Customer_Request__c = :customerRequestId and
                                    (c.Status__c != :CRN_STATUS_ACCEPTED or c.Status__c != :CRN_STATUS_REJECTED) ORDER BY c.Date_Notification_Sent__c DESC LIMIT 1];
        
        if (whichAction != null){
            if (RESPONSE_REJECT.equalsIgnoreCase(whichAction)){
                if (crn != null){
                    crn.Status__c = CRN_STATUS_REJECTED;
                    crn.Date_Responded__c = system.now();
                }
                showRejected = true;
                //pageRef = null;
                //What do we do on a reject?
            }else {
                system.debug('*** -- Into Accept -- ***');
                if (cr != null && volunteerUser != null){
                    system.debug('*** -- Found request and user -- ***');
                    if (!cr.Allocated__c){
                        system.debug('*** -- Request NOT Allocated yet -- ***');
                        cr.Allocated__c = true;
                        if (cr.OwnerId == gvtAdmin.Id){
                        	cr.Volunteer_Coordinator__c = gvtUser.Id;
                        }else {
                        	cr.Volunteer_Coordinator__c = cr.OwnerId;	
                        }
	                    cr.OwnerId = volunteerUser.Id;
                        if (crRT != null){
                            cr.RecordTypeId = crRT.Id;
                        }
                        cr.Assigned_Volunteer__c = volunteerContact.Id;
                        system.debug('*** -- About to update CR -- ***');
                        update cr;
                        system.debug('*** -- Set CRN status -- ***');
                        crn.Status__c = CRN_STATUS_ACCEPTED;
                        crn.Date_Responded__c = system.now();
                        doAcceptedForward = true;
                        system.debug('*** -- doAcceptedForward = ' + doAcceptedForward + ' -- ***');
                        openRequestURL = PORTAL_URL + cr.Id;
                        
                        //pageRef = new PageReference('https://uat-rnib-community-uat.cs17.force.com/' + cr.Id);
                        //pageRef.setRedirect(true);
                    }else {
                        system.debug('*** -- Request already Allocated - update CRN -- ***');
                        crn.Status__c = CRN_STATUS_ACCEPTED_NOT_AVAILABLE;
                        crn.Date_Responded__c = system.now();
                        alreadyAccepted = true;
                    }
                }
                //pageRef = new PageReference('https://uat-rnib-community-uat.cs17.force.com/' + cr.Id);        
            }
            system.debug('*** -- Update CRN -- ***');
            update crn;
        }
        
        return null;
    }
    
    @IsTest (seeAllData=true)
    private static void test1(){
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
    
        obj.save();
        
        Customer_Requests__c cr = obj.theRequest;
        
        CR_Notification__c crn = new CR_Notification__c();
        crn.Customer_Request__c = cr.Id;
        crn.Volunteer__c = volunteerContact.Id;
        insert crn;
        
        RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
        Application__c application = new Application__c(RecordTypeId = appRT.Id);
        
        application.Applicant__c = volunteerContact.Id;
        application.Role__c = roleOpp.Id;
        
        insert application;
        
        
        PageReference testPage = Page.CustomerRequestResponse;
        testPage.getParameters().put('ACTION','Accept');
        testPage.getParameters().put('CR',cr.Id);
        testPage.getParameters().put('V',volunteerContact.Id);
        
        test.setCurrentPage(testPage);
        
        test.startTest();
        
        CustomerRequestResponseController crrc = new CustomerRequestResponseController();
        crrc.doAction();
        
        test.stopTest();
        
    }

}