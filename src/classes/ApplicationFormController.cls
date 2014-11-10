/*
* 2013-12-23 : SM : Controller for the Application Form visualforce page
*/
public class ApplicationFormController {
    //Constants
    
    public final String ID_PARAM = 'Id';
    public final String APP_ID_PARAM = 'AppId';
    public final String RT_CORPORATE = 'Corporate';
    public final String RT_INTERNSHIP = 'Internship';
    public final String RT_ONE_OFF = 'One Off';
    public final String RT_PEER_SUPPORT = 'Peer Support';
    public final String RT_SPECIALIST = 'Specialist';
    public final String RT_STANDARD = 'Standard';
    public final String RT_TRUSTEE = 'Trustee';
    public final String RT_WORK_EXPERIENCE = 'Work Experience';
    public final String RT_WORK_PLACEMENT = 'Work Placement';
    public final String RT_APPLICANT = 'Applicant';
    public final String RT_REFERENCE = 'Reference';
    public final String RT_APPLICATION = 'Application';
    public final String RT_STANDARD_REFERENCE = 'Reference';
    public final String APP_STATUS_DRAFT = 'Draft';
    public final String APP_STATUS_SUBMITTED = 'Submitted';
    public final String APP_STATUS_WITHDRAWN = 'Withdrawn';
    public final String PROFILE_VOLUNTEER = 'Community Login User - Volunteers';
    public final String PROFILE_APPLICANT = 'Community Login User - Applicants';
    public final String PICKLIST_ANSWER_YES = ' Yes';
    public final String PICKLIST_ANSWER_NO = 'No';
    public final String REFERENCE_TYPE_CHILD_RELATED = 'Child related';
    public final String REFERENCE_TYPE_CHARACTER = 'Character';
    //boolean values to determine which 'type' of application
    public boolean showStandard {get; set;}
    public boolean showOneOff {get; set;}
    public boolean showSpecialist {get; set;}
    public boolean showWorkExperience {get; set;}
    public boolean showWorkPlacement {get; set;}
    public boolean showIntern {get; set;}
    public boolean showPeerSupport {get; set;}
    public boolean showCorporate {get; set;}
    public boolean showTrustee {get; set;}
    public boolean dbsCheckRequired {get; set;}
    //Objects used
    public Role_Opportunity__c theRole {get; set;}
    public Account corpAccount {get; set;}
    public Contact theApplicant {get; set;}
    public Contact ref_contact_one {get; set;}
    public Contact ref_contact_two {get; set;}
    public Reference__c reference_one {get; set;}
    public Reference__c reference_two {get; set;}
    public Application__c theApplication {get; set;}
    public Map<Id, Profile> profileMap {get; set;}
    public integer numberOfRefsRequired {get; set;}
    //Corporate Account information
    public String accountName {get; set;}
    public String accountPhone {get; set;}
    public String accountBillingStreet {get; set;}
    public String accountBillingCity {get; set;}
    public String accountBillingState {get; set;}
    public String accountBillingCountry {get; set;}
    public String accountBillingPostalCode {get; set;}
    public String applicantId {get; set;}
    
    public boolean isNewApplication {get; set;}
    //Collections
    public Map<Id, String> recordTypeMap {get; set;} 
    
        
    public ApplicationFormController(ApexPages.StandardController std){
        //Get a map of all profiles
        profileMap = new Map<Id, Profile>([select p.Id, p.Name from Profile p]);
        //Get the current logged in user, so we can get their Contact record
        User currentUser = [select u.ContactId from User u where u.Id = :UserInfo.getUserId()];
        
        if (!test.isRunningTest()){
        	if (currentUser != null){
            	applicantId = currentUser.ContactId;
        	}	
        }
        
        system.debug('*** -- applicantId = ' + applicantId + ' -- ***');
        
        //Map of Record Types for Role_Opportunities
        recordTypeMap = new Map<Id, String>();
        for (RecordType r : [select r.Id, r.Name from RecordType r where SobjectType = 'Role_Opportunity__c' and IsActive = true]){
            recordTypeMap.put(r.Id, r.Name);
        }
        
        //Contact record types
        system.debug('*** -- Get contact record types -- ***');
        RecordType applicantRecordType = [select r.Id, r.DeveloperName from RecordType r where r.DeveloperName = :RT_APPLICANT and r.SObjectType = 'Contact' and IsActive = true LIMIT 1];
        RecordType referenceRecordType = [select r.Id, r.DeveloperName from RecordType r where r.DeveloperName = :RT_REFERENCE and r.SObjectType = 'Contact' and IsActive = true LIMIT 1];
        RecordType applicationRecordType = [select r.Id from RecordType r where r.Name = :RT_APPLICATION and r.SObjectType = 'Application__c' and isActive = true LIMIT 1];
        
        system.debug('*** -- Get ID Param -- ***');
        //ID parameter of the Role_Opportunity__c
        Id roleOppId = ApexPages.currentPage().getParameters().get(ID_PARAM);
        if (roleOppId != null){
            system.debug('*** -- Get the Role -- ***');
            theRole = [Select r.Role_involve_working_with_Children__c, r.Number_Of_References_Required__c, r.Role_Title__c, r.Location__c, r.Id, r.RecordTypeId, r.DBS_Check_required__c, r.Volunteer_Coordinator__c, r.Volunteer_Manager__c, Service__c From Role_Opportunity__c r where r.Id = :roleOppId];
        }
        
        //If this param is in the URL, then this application is being edited
        Id appId = ApexPages.currentPage().getParameters().get(APP_ID_PARAM);

        String rtName;
        if (theRole != null){
            system.debug('*** -- Get record type map value -- ***');
            rtName = recordTypeMap.get(theRole.RecordTypeId);
            numberOfRefsRequired = (theRole.Number_of_References_Required__c == null ? 0 : integer.valueOf(theRole.Number_of_References_Required__c));
        }
        //Which type of Role_Opportunity is it, and what sections do we need to show?
        system.debug('*** -- Do boolean -- ***');
        showCorporate = (RT_CORPORATE.equalsIgnoreCase(rtName) ? true : false);
        showIntern = (RT_INTERNSHIP.equalsIgnoreCase(rtName) ? true : false);
        showOneOff = (RT_ONE_OFF.equalsIgnoreCase(rtName) ? true : false);
        showPeerSupport = (RT_PEER_SUPPORT.equalsIgnoreCase(rtName) ? true : false);
        showSpecialist = (RT_SPECIALIST.equalsIgnoreCase(rtName) ? true : false);
        showStandard = (RT_STANDARD.equalsIgnoreCase(rtName) ? true : false);
        showTrustee = (RT_TRUSTEE.equalsIgnoreCase(rtName) ? true : false);
        showWorkExperience = (RT_WORK_EXPERIENCE.equalsIgnoreCase(rtName) ? true : false);
        showWorkPlacement = (RT_WORK_PLACEMENT.equalsIgnoreCase(rtName) ? true : false);
        dbsCheckRequired = (theRole.DBS_Check_required__c == null ? false : true);
        
        //As a user will only get to here after they've logged into the portal
        //we need to pull in their contact information etc.
            
        //Now create the necessary objects for capturing the data on the form
        if (showCorporate){
            corpAccount  = new Account();
        }
        
        if (applicantId != null){
            system.debug('*** -- Found an applicant record -- ***');
            theApplicant = [Select c.If_Yes_Contact__c, c.Is_Access_Technology_Required__c, c.OtherPhone,   
            c.Title, c.Status__c, c.Skills__c, c.Sight_Status__c, c.Salutation, c.ReportsToId, c.Religion__c, c.Registration_Status__c, c.Region__c, 
            c.Reference_Number__c, c.RecordTypeId, c.Preferred_reading_correspondence_format__c, c.Preferred_communications_channel__c, c.PostCode__c, c.Phone, c.Over_18__c, 
            c.Name__c, c.Name, c.MobilePhone, c.Marital_Status__c, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.If_Other__c, c.Id, c.ID_Returned__c, c.ID_Number__c, c.ID_Card_Expiry_Date__c, c.How_did_you_hear_about_RNIB__c, c.HomePhone, 
            c.Holiday__c, c.HasOptedOutOfEmail, c.Gender__c, c.FirstName, c.Fax, c.Ethnicity_list__c, c.Emergency_Contact_Relationship__c, c.Emergency_Contact_Phone__c, 
            c.Emergency_Contact_Name__c, c.Emergency_Contact_Mobile__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Driving_License_Next_Check__c, c.Driving_License_Checked__c, 
            c.Disability__c, c.Description, c.Department, c.Date_of_birth__c, c.Data_Protection__c, c.Criminal_Convictions__c, c.Confirmation__c, c.Birthdate, 
            c.Available_for_other_roles__c, c.Availability__c, c.AssistantPhone, c.AssistantName, c.Areas_of_Interest__c, c.Application__c, c.Age__c, c.Active_Roles__c, c.Disability_Notes__c,
            c.AccountId From Contact c where c.Id = :applicantId];
        }else {
            theApplicant = new Contact(RecordTypeId = applicantRecordType.Id);  
        }
        
        if (appId != null){
            isNewApplication = false;
            system.debug('*** -- Found an Application Record -- ***');
            theApplication = [Select a.Corporate_Account_Phone__c, a.Corporate_Account_Name__c, a.Corporate_Account_Billing_Street__c, a.Corporate_Account_Billing_State__c, a.Corporate_Account_Billing_PostalCode__c, a.Corporate_Account_Billing_Country__c, a.Corporate_Account_Billing_City__c, 
            					a.Convicted_of_Criminal_Offence__c, a.Criminal_Offence_Details__c, a.Why_do_you_want_to_volunteer_for_us__c, a.Why_do_work_experience_with_RNIB__c, a.Volunteer_Manager__c, a.Volunteer_Coordinator__c, 
                                a.Voluntary_or_Work_Experience__c, a.Tell_us_about_yourself__c, a.Status__c, a.Start_Date__c, a.Service__c, a.School_College__c, 
                                a.School_College_Phone__c, a.School_College_Contact__c, a.Role__c, a.Role_Title__c, a.Role_Source__c, a.Role_Description__c, a.Risk_Assessments__c, 
                                a.References_Unavailable__c, a.References_Unavailable_Explanation__c, a.RecordTypeId, a.Reason_for_leaving__c, a.Name, a.Id, a.Experience_Qualifications__c, a.End_Date__c, a.Education__c, a.ContactName__c, 
                                a.College_Univeristy_Workplace__c, a.College_Univeristy_Workplace_Phone__c, a.College_Univeristy_Workplace_Contact__c, a.Applicant__c, a.School_University_HE_Institution__c, a.School_University_HE_Institution2__c, a.School_University_HE_Institution3__c, a.Name_Address_Dates_to_and_from__c, 
                                a.Name_Address_Dates_to_and_from2__c, a.Name_Address_Dates_to_and_from3__c, a.Subjects__c, a.Subjects2__c, a.Subjects3__c, a.Qualification__c, a.Qualification2__c, a.Qualification3__c, a.Grades__c, a.Grades2__c, a.Grades3__c, a.Membership_of_professional_bodies__c, a.Membership_of_professional_bodies2__c, 
                                a.Membership_of_professional_bodies3__c, a.Membership_No__c, a.Membership_No2__c, a.Membership_No3__c, a.Present_Recent_Employment_Voluntary_Work__c, a.Present_Recent_Employment_VoluntaryWork2__c, a.Present_Recent_Employment_VoluntaryWork3__c, a.Employer_s_name_address_From_To__c, a.Employer_s_name_address_From_To2__c,
                                a.Employer_s_name_address_From_To3__c, a.Duties_and_Main_Achievements__c, a.Duties_and_Main_Achievements2__c, a.Duties_and_Main_Achievements3__c, a.Legal_Declariation__c,
                                a.Accepted_Reference_Checks__c, a.Number_of_Corporate_Volunteers__c, (Select Daytime_Phone__c, ReferenceLastName__c, Salutation, Reference_Number__c, RecordTypeId, Phone, Name, MobilePhone, MailingStreet, 
                                MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, Id, HomePhone, FirstName, Email, Application__c From Contacts__r order by Reference_Number__c ASC),
                                (Select Contact__c, Application__c, Relationship__c, Length_of_relationship__c, Reference_Type__c From References__r)
                                from Application__c a where a.Id = :appId];  
        }else {
            system.debug('*** -- Its a new Application -- ***');
            isNewApplication = true;
            theApplication = new Application__c();
            theApplication.RecordTypeId = applicationRecordType.Id;
            theApplication.Role_Source__c = 'Web';
            theApplication.Volunteer_Coordinator__c = theRole.Volunteer_Coordinator__c;
            theApplication.Volunteer_Manager__c = theRole.Volunteer_Manager__c;
            theApplication.Service__c = theRole.Service__c;
        }
        
        //2014-01-10 : SM : We need to use a temporary object for the Reference, to avoid the LastName mandatory flag on save
        if (showStandard || showIntern || showSpecialist){
            system.debug('*** -- Show the referees -- ***');
            if (!isNewApplication){
                Set<Id> contactIdSet = new Set<Id>();
                for (Reference__c r : theApplication.References__r){
                    contactIdSet.add(r.Contact__c);
                } 
                
                List<Contact> referenceList = [Select Daytime_Phone__c, 
                                                ReferenceLastName__c, Salutation, Reference_Number__c, RecordTypeId, Phone, Name, MobilePhone, MailingStreet, 
                                                MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, Id, HomePhone, FirstName, Email, 
                                                Application__c From Contact where Id in :contactIdSet order by Reference_Number__c ASC];
                                                
                system.debug('*** -- referenceListSize = ' + referenceList.size() + ' -- ***');
                system.debug('*** -- theApplication.References__r.size = ' + theApplication.References__r.size() + ' -- ***');
                Map<Id, Reference__c> refMap = new Map<Id, Reference__c>();
                for (Reference__c r : theApplication.References__r){
                    refMap.put(r.Contact__c, r);
                }
                if (referenceList.size() > 0){
                    ref_contact_one = referenceList[0];
                }
                if (referenceList.size() > 1){
                    ref_contact_two = referenceList[1];
                }       
                
                if (ref_contact_one != null){
                	system.debug('*** -- We have a ref_contact_one ' + ref_contact_one.Name + ' -- ***');
                    //2014-01-29 : SM : I don't think this code would ever run, so I'm removing it - 
                    //2014-02-25 : SM : Some of it runs!
                    reference_one = refMap.get(ref_contact_one.Id);
                    //if (reference_one == null){
                    //    reference_one = new Reference__c();
                    //    reference_one.Contact__c = ref_contact_one.Id;
                    //    if (PICKLIST_ANSWER_YES.equalsIgnoreCase(theRole.Role_involve_working_with_Children__c)){
                    //      reference_one.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
                    //    }else {
                    //      reference_one.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
                    //    }
                    //}
                    ref_contact_one.Phone = ref_contact_one.Daytime_Phone__c;
                }else {
                	ref_contact_one = new Contact(RecordTypeId = referenceRecordType.Id);
	                ref_contact_one.Phone = ref_contact_one.Daytime_Phone__c;
	                
	                reference_one = new Reference__c();
	                if (PICKLIST_ANSWER_YES.equalsIgnoreCase(theRole.Role_involve_working_with_Children__c)){
	                    reference_one.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
	                }else {
	                    reference_one.Reference_Type__c = REFERENCE_TYPE_CHARACTER;
	                }
                }
                
                if (ref_contact_two != null){
                	system.debug('*** -- We have a ref_contact_two ' + ref_contact_two.Name + ' -- ***');
                    //2014-01-29 : SM : I don't think this code would ever run, so I'm removing it
                    //2014-02-25 : SM : Some of it runs!
                    reference_two = refMap.get(ref_contact_two.Id);
                    //if (reference_two == null){
                    //    reference_two = new Reference__c();
                    //    reference_two.Contact__c = ref_contact_two.Id;
                    //    if (PICKLIST_ANSWER_YES.equalsIgnoreCase(theRole.Role_involve_working_with_Children__c)){
                    //      reference_two.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
                    //    }else {
                    //      reference_two.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
                    //    }
                    //}
                    ref_contact_two.Phone = ref_contact_two.Daytime_Phone__c;
                }else {
	                ref_contact_two = new Contact(RecordTypeId = referenceRecordType.Id);
	                ref_contact_two.Phone = ref_contact_two.Daytime_Phone__c;
	                
	                reference_two = new Reference__c();
	                if (PICKLIST_ANSWER_YES.equalsIgnoreCase(theRole.Role_involve_working_with_Children__c)){
	                    reference_two.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
	                }else {
	                    reference_two.Reference_Type__c = REFERENCE_TYPE_CHARACTER;
	                }                	
                }
                
                
            }else {
                ref_contact_one = new Contact(RecordTypeId = referenceRecordType.Id);
                ref_contact_two = new Contact(RecordTypeId = referenceRecordType.Id);
                ref_contact_one.Phone = ref_contact_one.Daytime_Phone__c;
                ref_contact_two.Phone = ref_contact_two.Daytime_Phone__c;
                
                reference_one = new Reference__c();
                if (PICKLIST_ANSWER_YES.equalsIgnoreCase(theRole.Role_involve_working_with_Children__c)){
                    reference_one.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
                }else {
                    reference_one.Reference_Type__c = REFERENCE_TYPE_CHARACTER;
                }
                reference_two = new Reference__c();
                if (PICKLIST_ANSWER_YES.equalsIgnoreCase(theRole.Role_involve_working_with_Children__c)){
                    reference_two.Reference_Type__c = REFERENCE_TYPE_CHILD_RELATED;
                }else {
                    reference_two.Reference_Type__c = REFERENCE_TYPE_CHARACTER;
                }
                
            }
        }
        
        system.debug('*** -- Is New Application = ' + isNewApplication + ' -- ***');
        
    }
    
    public PageReference withdrawApplication(){
        PageReference returnPageRef;
        String profileName = profileMap.get(UserInfo.getProfileId()).Name;
        if (PROFILE_VOLUNTEER.equalsIgnoreCase(profileName)){
            returnPageRef = Page.VolunteerLandingPage;  
        }else {
            returnPageRef = Page.ApplicantLandingPage;
        }
        
        theApplication.Status__c = APP_STATUS_WITHDRAWN;
        update theApplication;
        
        return returnPageRef;
    }
    
    public PageReference doSave(){
        system.debug('*** -- About to upsert theApplicant with ' + theApplicant.MobilePhone + ' -- ***');
        PageReference returnPageRef;
        String profileName = profileMap.get(UserInfo.getProfileId()).Name;
        if (PROFILE_VOLUNTEER.equalsIgnoreCase(profileName)){
            returnPageRef = Page.VolunteerLandingPage;  
        }else {
            returnPageRef = Page.ApplicantLandingPage;
        }
        //We need to make sure all the records are linked
        //then Upsert
        system.debug('*** -- About to upsert theApplicant with ' + theApplicant.MobilePhone + ' -- ***');
        try {
            upsert theApplicant;
        }catch (Exception e){
            system.debug('*** -- Error upserting theApplicant : ' + e + ' -- ***');
        }
        if (isNewApplication){
            theApplication.Applicant__c = theApplicant.Id;
            theApplication.Status__c = APP_STATUS_DRAFT;
            theApplication.Role__c = theRole.Id;
            insert theApplication;  
        }else {
            update theApplication;
        }
        
        system.debug('*** -- Application Education after Save = ' + theApplication.Education__c + ' -- ***');
        if (showStandard || showIntern || showSpecialist){
            system.debug('*** -- Saving references -- ***');
            
            if (ref_contact_one != null){
            	system.debug('*** -- about to save one ' + ref_contact_one.Name + ' -- ***');
	            if (ref_contact_one.ReferenceLastName__c != null){
	                system.debug('*** -- saving reference one -- ***');
	                ref_contact_one.LastName = ref_contact_one.ReferenceLastName__c;
	                ref_contact_one.Application__c = theApplication.Id;
	                upsert ref_contact_one; 
	                system.debug('*** -- upserted reference contact ' + ref_contact_one.Id + ' -- ***');
	                system.debug('*** -- reference contact owner =  ' + ref_contact_one.OwnerId + ' -- ***');
	                reference_one.Contact__c = ref_contact_one.Id;
	                reference_one.Application__c = theApplication.Id;
	                upsert reference_one;
	            }
            } /*else if (ref_contact_one.ReferenceLastName__c != null){
            	system.debug('*** -- saving reference one -- ***');
                ref_contact_one.LastName = ref_contact_one.ReferenceLastName__c;
                ref_contact_one.Application__c = theApplication.Id;
                upsert ref_contact_one; 
                reference_one.Contact__c = ref_contact_one.Id;
                reference_one.Application__c = theApplication.Id;
                upsert reference_one;
            }
            */
            if (ref_contact_two != null){
            	system.debug('*** -- about to save two ' + ref_contact_two.Name + ' -- ***');
	            if (ref_contact_two.ReferenceLastName__c != null){
	                system.debug('*** -- saving reference two -- ***');
	                ref_contact_two.LastName = ref_contact_two.ReferenceLastName__c;
	                ref_contact_two.Application__c = theApplication.Id;
	                upsert ref_contact_two;
	                reference_two.Contact__c = ref_contact_two.Id;
	                reference_two.Application__c = theApplication.Id;
	                upsert reference_two;
	            }
            }/* else if (ref_contact_two.ReferenceLastName__c != null){
            	system.debug('*** -- saving reference two -- ***');
                ref_contact_two.LastName = ref_contact_two.ReferenceLastName__c;
                ref_contact_two.Application__c = theApplication.Id;
                upsert ref_contact_two;
                reference_two.Contact__c = ref_contact_two.Id;
                reference_two.Application__c = theApplication.Id;
                upsert reference_two;
            }
            */
        }
    
        return returnPageRef;       
    }
    
    public PageReference doSubmit(){
        //We need to make sure all the records are linked
        //We then need to save AND set a status to say it's submitted
        PageReference returnPageRef;
        String profileName = profileMap.get(UserInfo.getProfileId()).Name;
        if (PROFILE_VOLUNTEER.equalsIgnoreCase(profileName)){
            returnPageRef = Page.VolunteerLandingPage;  
        }else {
            returnPageRef = Page.ApplicantLandingPage;
        }
        
        //We need to make sure all the records are linked
        //then Upsert
        system.debug('*** -- About to upsert theApplicant with ' + theApplicant.MobilePhone + ' -- ***');
        try {
            upsert theApplicant;
        }catch (Exception e){
            system.debug('*** -- Error upserting theApplicant : ' + e + ' -- ***');
        }
        Contact testContact = [select c.Date_of_Birth__c from Contact c where c.Id = :theApplicant.Id];
        system.debug('*** -- Applicant date of birth after Save = ' + testContact.Date_of_birth__c + ' -- ***');
        
       if (isNewApplication){
            theApplication.Applicant__c = theApplicant.Id;
            theApplication.Status__c = APP_STATUS_SUBMITTED;
            theApplication.Role__c = theRole.Id;
            insert theApplication;  
        }else {
            theApplication.Status__c = APP_STATUS_SUBMITTED;
            update theApplication;
        }
        system.debug('*** -- Application Education after Save = ' + theApplication.Education__c + ' -- ***');
        if (showStandard || showIntern || showSpecialist){
             if (ref_contact_one != null){
            	system.debug('*** -- about to save one ' + ref_contact_one.Name + ' -- ***');
	            if (ref_contact_one.ReferenceLastName__c != null){
	                system.debug('*** -- saving reference one -- ***');
	                ref_contact_one.LastName = ref_contact_one.ReferenceLastName__c;
	                ref_contact_one.Application__c = theApplication.Id;
	                upsert ref_contact_one; 
	                reference_one.Contact__c = ref_contact_one.Id;
	                reference_one.Application__c = theApplication.Id;
	                upsert reference_one;
	            }
            }else if (ref_contact_one.ReferenceLastName__c != null){
            	system.debug('*** -- saving reference one -- ***');
                ref_contact_one.LastName = ref_contact_one.ReferenceLastName__c;
                ref_contact_one.Application__c = theApplication.Id;
                upsert ref_contact_one; 
                reference_one.Contact__c = ref_contact_one.Id;
                reference_one.Application__c = theApplication.Id;
                upsert reference_one;
            }
            if (ref_contact_two != null){
            	system.debug('*** -- about to save two ' + ref_contact_two.Name + ' -- ***');
	            if (ref_contact_two.ReferenceLastName__c != null){
	                system.debug('*** -- saving reference two -- ***');
	                ref_contact_two.LastName = ref_contact_two.ReferenceLastName__c;
	                ref_contact_two.Application__c = theApplication.Id;
	                upsert ref_contact_two;
	                reference_two.Contact__c = ref_contact_two.Id;
	                reference_two.Application__c = theApplication.Id;
	                upsert reference_two;
	            }
            }else if (ref_contact_two.ReferenceLastName__c != null){
            	system.debug('*** -- saving reference two -- ***');
                ref_contact_two.LastName = ref_contact_two.ReferenceLastName__c;
                ref_contact_two.Application__c = theApplication.Id;
                upsert ref_contact_two;
                reference_two.Contact__c = ref_contact_two.Id;
                reference_two.Application__c = theApplication.Id;
                upsert reference_two;
            }
        }
    
        return returnPageRef;
    }
    
    public PageReference doClose(){
        PageReference returnPageRef;
        String profileName = profileMap.get(UserInfo.getProfileId()).Name;
        if (PROFILE_VOLUNTEER.equalsIgnoreCase(profileName)){
            returnPageRef = Page.VolunteerLandingPage;  
        }else {
            returnPageRef = Page.ApplicantLandingPage;
        }
        //We just need to close, without saving
        return returnPageRef;
    }
    
    @future(callout=false)
    public static void createAccount(String aName, String aPhone, String aStreet, String aCity, String aState, String aCountry, String aPostalCode, String contactId){
    	List<Account> checkAccountList;
    	List<Contact> applicantList;
    	Account corpAccount = new Account();
    	checkAccountList = [select a.Id from Account a where a.Name = :aName LIMIT 1];
    	applicantList = [select c.Id, c.AccountId from Contact c where c.Id = :contactId LIMIT 1];
    	if (checkAccountList.size() == 0){
    		corpAccount.Name = aName;
    		corpAccount.Phone = aPhone;
    		corpAccount.BillingStreet = aStreet;
    		corpAccount.BillingCity = aCity;
    		corpAccount.BillingState = aState;
    		corpAccount.BillingCountry = aCountry;
    		corpAccount.BillingPostalCode = aPostalCode;
    		
    		insert corpAccount;
    	}else {
    		corpAccount = checkAccountList[0];
    	}
    	
    	if (applicantList.size() > 0 ){
    		applicantList[0].AccountId = corpAccount.Id;
    		update applicantList[0];
    	}
    }


@IsTest(SeeAllData=true)
 private static void test_ApplicationFormControllerStandardNEW() {
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
    system.debug('*** -- update volunteerContact with email of ' + volunteerContact.Email + ' and Phone of ' + volunteerContact.Phone + ' -- ***');
    update volunteerContact;

    
    system.debug('*** -- volunteerContactId = ' + volunteerContact.Id + ' -- ***');
    
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
    insert roleOpp;
    
    ApexPages.StandardController std = new ApexPages.StandardController(roleOpp);
    test.startTest();
    system.debug('*** -- About to run as ' + volunteerList[0] + ' -- ***');
    system.debug('*** -- with contact ID = ' + volunteerList[0].ContactId + ' -- ***');
    
    //system.runAs(volunteerList[0]){
        PageReference testPage = Page.Application;
        testPage.getParameters().put('Id',roleOpp.Id);
        test.setCurrentPage(testPage);
        ApplicationFormController afc = new ApplicationFormController(std);
        afc.applicantId = volunteerContact.Id;
        
        afc.theApplicant = [Select c.If_Yes_Contact__c, c.Is_Access_Technology_Required__c, c.OtherPhone,   
            c.Title, c.Status__c, c.Skills__c, c.Sight_Status__c, c.Salutation, c.ReportsToId, c.Religion__c, c.Registration_Status__c, c.Region__c, 
            c.Reference_Number__c, c.RecordTypeId, c.Preferred_reading_correspondence_format__c, c.Preferred_communications_channel__c, c.PostCode__c, c.Phone, c.Over_18__c, 
            c.Name__c, c.Name, c.MobilePhone, c.Marital_Status__c, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.If_Other__c, c.Id, c.ID_Returned__c, c.ID_Number__c, c.ID_Card_Expiry_Date__c, c.How_did_you_hear_about_RNIB__c, c.HomePhone, 
            c.Holiday__c, c.HasOptedOutOfEmail, c.Gender__c, c.FirstName, c.Fax, c.Ethnicity_list__c, c.Emergency_Contact_Relationship__c, c.Emergency_Contact_Phone__c, 
            c.Emergency_Contact_Name__c, c.Emergency_Contact_Mobile__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Driving_License_Next_Check__c, c.Driving_License_Checked__c, 
            c.Disability__c, c.Description, c.Department, c.Date_of_birth__c, c.Data_Protection__c, c.Criminal_Convictions__c, c.Confirmation__c, c.Birthdate, 
            c.Available_for_other_roles__c, c.Availability__c, c.AssistantPhone, c.AssistantName, c.Areas_of_Interest__c, c.Application__c, c.Age__c, c.Active_Roles__c, c.Disability_Notes__c,
            c.AccountId From Contact c where c.Id = :volunteerContact.Id];
            
        afc.ref_contact_one.ReferenceLastName__c = 'Ref1';
        afc.ref_contact_one.FirstName = 'Test';
        afc.ref_contact_one.Daytime_Phone__c = '01616161616';
        afc.ref_contact_one.Email = 'test.ref1@myemail.com';
        afc.ref_contact_two.ReferenceLastName__c = 'Ref2';
        afc.ref_contact_two.FirstName = 'Test';
        afc.ref_contact_two.Daytime_Phone__c = '01617177171';
        afc.ref_contact_two.Email = 'test.ref2@myemail.com';
        PageReference savePage = afc.doSave();
    //}
    
    test.stopTest();
    
 }
 
 
 @IsTest(SeeAllData=true)
 private static void test_ApplicationFormControllerStandardEXISTING() {
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
    //system.runAs(volunteerList[0]){
        PageReference testPage = Page.Application;
        testPage.getParameters().put('Id',roleOpp.Id);
        testPage.getParameters().put('AppId',application.Id);
        test.setCurrentPage(testPage);
        ApplicationFormController afc = new ApplicationFormController(std);
        afc.applicantId = volunteerContact.Id;
        
        afc.theApplicant = [Select c.If_Yes_Contact__c, c.Is_Access_Technology_Required__c, c.OtherPhone,   
            c.Title, c.Status__c, c.Skills__c, c.Sight_Status__c, c.Salutation, c.ReportsToId, c.Religion__c, c.Registration_Status__c, c.Region__c, 
            c.Reference_Number__c, c.RecordTypeId, c.Preferred_reading_correspondence_format__c, c.Preferred_communications_channel__c, c.PostCode__c, c.Phone, c.Over_18__c, 
            c.Name__c, c.Name, c.MobilePhone, c.Marital_Status__c, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.If_Other__c, c.Id, c.ID_Returned__c, c.ID_Number__c, c.ID_Card_Expiry_Date__c, c.How_did_you_hear_about_RNIB__c, c.HomePhone, 
            c.Holiday__c, c.HasOptedOutOfEmail, c.Gender__c, c.FirstName, c.Fax, c.Ethnicity_list__c, c.Emergency_Contact_Relationship__c, c.Emergency_Contact_Phone__c, 
            c.Emergency_Contact_Name__c, c.Emergency_Contact_Mobile__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Driving_License_Next_Check__c, c.Driving_License_Checked__c, 
            c.Disability__c, c.Description, c.Department, c.Date_of_birth__c, c.Data_Protection__c, c.Criminal_Convictions__c, c.Confirmation__c, c.Birthdate, 
            c.Available_for_other_roles__c, c.Availability__c, c.AssistantPhone, c.AssistantName, c.Areas_of_Interest__c, c.Application__c, c.Age__c, c.Active_Roles__c, c.Disability_Notes__c,
            c.AccountId From Contact c where c.Id = :volunteerContact.Id];
            
    //}
    
    test.stopTest();
    
    
 }
 
  @IsTest(SeeAllData=true)
 private static void test_ApplicationFormControllerTestSubmit() {
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
    //system.runAs(volunteerList[0]){
        PageReference testPage = Page.Application;
        testPage.getParameters().put('Id',roleOpp.Id);
        testPage.getParameters().put('AppId',application.Id);
        test.setCurrentPage(testPage);
        ApplicationFormController afc = new ApplicationFormController(std);
        afc.applicantId = volunteerContact.Id;

        afc.theApplicant = [Select c.If_Yes_Contact__c, c.Is_Access_Technology_Required__c, c.OtherPhone,   
            c.Title, c.Status__c, c.Skills__c, c.Sight_Status__c, c.Salutation, c.ReportsToId, c.Religion__c, c.Registration_Status__c, c.Region__c, 
            c.Reference_Number__c, c.RecordTypeId, c.Preferred_reading_correspondence_format__c, c.Preferred_communications_channel__c, c.PostCode__c, c.Phone, c.Over_18__c, 
            c.Name__c, c.Name, c.MobilePhone, c.Marital_Status__c, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.If_Other__c, c.Id, c.ID_Returned__c, c.ID_Number__c, c.ID_Card_Expiry_Date__c, c.How_did_you_hear_about_RNIB__c, c.HomePhone, 
            c.Holiday__c, c.HasOptedOutOfEmail, c.Gender__c, c.FirstName, c.Fax, c.Ethnicity_list__c, c.Emergency_Contact_Relationship__c, c.Emergency_Contact_Phone__c, 
            c.Emergency_Contact_Name__c, c.Emergency_Contact_Mobile__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Driving_License_Next_Check__c, c.Driving_License_Checked__c, 
            c.Disability__c, c.Description, c.Department, c.Date_of_birth__c, c.Data_Protection__c, c.Criminal_Convictions__c, c.Confirmation__c, c.Birthdate, 
            c.Available_for_other_roles__c, c.Availability__c, c.AssistantPhone, c.AssistantName, c.Areas_of_Interest__c, c.Application__c, c.Age__c, c.Active_Roles__c, c.Disability_Notes__c,
            c.AccountId From Contact c where c.Id = :volunteerContact.Id];
            
        afc.ref_contact_one.ReferenceLastName__c = 'Reference1';
        afc.ref_contact_one.FirstName = 'Test';
        afc.ref_contact_one.Daytime_Phone__c = '02072222222';
        afc.ref_contact_one.Email = 'test.reference1@myemail.com';
        afc.ref_contact_two.ReferenceLastName__c = 'Reference2';
        afc.ref_contact_two.FirstName = 'Test';
        afc.ref_contact_two.Daytime_Phone__c = '02072222222';
        afc.ref_contact_two.Email = 'test.reference2@myemail.com';
        PageReference savePage = afc.doSubmit();
    //}
    
    test.stopTest();
    
    
 }
 
  @IsTest(SeeAllData=true)
 private static void test_ApplicationFormControllerTestWithdraw() {
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
    //system.runAs(volunteerList[0]){
        PageReference testPage = Page.Application;
        testPage.getParameters().put('Id',roleOpp.Id);
        testPage.getParameters().put('AppId',application.Id);
        test.setCurrentPage(testPage);
        ApplicationFormController afc = new ApplicationFormController(std);
        afc.applicantId = volunteerContact.Id;
        
        afc.theApplicant = [Select c.If_Yes_Contact__c, c.Is_Access_Technology_Required__c, c.OtherPhone,   
            c.Title, c.Status__c, c.Skills__c, c.Sight_Status__c, c.Salutation, c.ReportsToId, c.Religion__c, c.Registration_Status__c, c.Region__c, 
            c.Reference_Number__c, c.RecordTypeId, c.Preferred_reading_correspondence_format__c, c.Preferred_communications_channel__c, c.PostCode__c, c.Phone, c.Over_18__c, 
            c.Name__c, c.Name, c.MobilePhone, c.Marital_Status__c, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.If_Other__c, c.Id, c.ID_Returned__c, c.ID_Number__c, c.ID_Card_Expiry_Date__c, c.How_did_you_hear_about_RNIB__c, c.HomePhone, 
            c.Holiday__c, c.HasOptedOutOfEmail, c.Gender__c, c.FirstName, c.Fax, c.Ethnicity_list__c, c.Emergency_Contact_Relationship__c, c.Emergency_Contact_Phone__c, 
            c.Emergency_Contact_Name__c, c.Emergency_Contact_Mobile__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Driving_License_Next_Check__c, c.Driving_License_Checked__c, 
            c.Disability__c, c.Description, c.Department, c.Date_of_birth__c, c.Data_Protection__c, c.Criminal_Convictions__c, c.Confirmation__c, c.Birthdate, 
            c.Available_for_other_roles__c, c.Availability__c, c.AssistantPhone, c.AssistantName, c.Areas_of_Interest__c, c.Application__c, c.Age__c, c.Active_Roles__c, c.Disability_Notes__c,
            c.AccountId From Contact c where c.Id = :volunteerContact.Id];
            
        afc.withdrawApplication();
    //}
    
    test.stopTest();
    
    
 }
 
  @IsTest(SeeAllData=true)
 private static void test_ApplicationFormControllerTestDoClose() {
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
    RecordType riskAssessment = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_RISK_ASSESSMENT);
    Reference__c ref1 = new Reference__c(RecordTypeId = standardRef.Id);
    ref1.Contact__c = referenceContact1.Id;
    ref1.Application__c = application.Id;
    ref1.Outcome__c = TestUtilities.OUTCOME_ACCEPTED;
    insert ref1;
    Reference__c ref2 = new Reference__c(RecordTypeId = riskAssessment.Id);
    ref2.Contact__c = referenceContact2.Id;
    ref2.Application__c = application.Id;
    ref2.Outcome__c = TestUtilities.OUTCOME_APPROVED;
    insert ref2;
    
    system.debug('*** -- finished inserting all records - about to start test -- ***');
    
    ApexPages.StandardController std = new ApexPages.StandardController(roleOpp);
    test.startTest();
    //system.runAs(volunteerList[0]){
        PageReference testPage = Page.Application;
        testPage.getParameters().put('Id',roleOpp.Id);
        testPage.getParameters().put('AppId',application.Id);
        test.setCurrentPage(testPage);
        ApplicationFormController afc = new ApplicationFormController(std);
        afc.applicantId = volunteerContact.Id;
        
        afc.theApplicant = [Select c.If_Yes_Contact__c, c.Is_Access_Technology_Required__c, c.OtherPhone,   
            c.Title, c.Status__c, c.Skills__c, c.Sight_Status__c, c.Salutation, c.ReportsToId, c.Religion__c, c.Registration_Status__c, c.Region__c, 
            c.Reference_Number__c, c.RecordTypeId, c.Preferred_reading_correspondence_format__c, c.Preferred_communications_channel__c, c.PostCode__c, c.Phone, c.Over_18__c, 
            c.Name__c, c.Name, c.MobilePhone, c.Marital_Status__c, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, 
            c.LastCUUpdateDate, c.LastCURequestDate, c.If_Other__c, c.Id, c.ID_Returned__c, c.ID_Number__c, c.ID_Card_Expiry_Date__c, c.How_did_you_hear_about_RNIB__c, c.HomePhone, 
            c.Holiday__c, c.HasOptedOutOfEmail, c.Gender__c, c.FirstName, c.Fax, c.Ethnicity_list__c, c.Emergency_Contact_Relationship__c, c.Emergency_Contact_Phone__c, 
            c.Emergency_Contact_Name__c, c.Emergency_Contact_Mobile__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Driving_License_Next_Check__c, c.Driving_License_Checked__c, 
            c.Disability__c, c.Description, c.Department, c.Date_of_birth__c, c.Data_Protection__c, c.Criminal_Convictions__c, c.Confirmation__c, c.Birthdate, 
            c.Available_for_other_roles__c, c.Availability__c, c.AssistantPhone, c.AssistantName, c.Areas_of_Interest__c, c.Application__c, c.Age__c, c.Active_Roles__c, c.Disability_Notes__c,
            c.AccountId From Contact c where c.Id = :volunteerContact.Id];
            
        afc.doClose();
   //}
    
    test.stopTest();
    
    
 }
 
@IsTest(SeeAllData=true)
 private static void test_ApplicationFormControllerCorporate() {
    Profile saProfile = [select p.Id from Profile p where Name = 'System Administrator' LIMIT 1];
    Profile vProfile = [select p.Id from Profile p where Name = 'Community Login User - Volunteers' LIMIT 1];
    List<User>userList = [select u.Id from User u where u.IsActive = true and u.ProfileId = :saProfile.Id LIMIT 2];
    List<User>volunteerList = [select u.Id from User u where u.ProfileId = :vProfile.Id and IsActive = true];
    User volunteerMgr = userList[0];
    User volunteerCoord = userList[1];
    RecordType corpRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_CORPORATE);
    Role_Opportunity__c roleOpp = TestUtilities.getRoleOpportunity(TestUtilities.RT_CORPORATE, corpRT.Id);
    roleOpp.Volunteer_Manager__c = volunteerMgr.Id;
    roleOpp.Volunteer_Coordinator__c = volunteerCoord.Id;
    roleOpp.Role_involve_working_with_Children__c = 'No';
    roleOpp.Number_of_References_Required__c = '0';
    insert roleOpp;
    
    ApexPages.StandardController std = new ApexPages.StandardController(roleOpp);
    test.startTest();
    PageReference testPage = Page.Application;
    testPage.getParameters().put('Id',roleOpp.Id);
    test.setCurrentPage(testPage);
    ApplicationFormController afc = new ApplicationFormController(std);
    
    test.stopTest();
    
 }
    
}