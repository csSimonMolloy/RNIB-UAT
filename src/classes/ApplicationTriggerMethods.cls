/*
* 2014-01-27 : SM : ApplicationTriggerMethods class - holds methods called by the Application Trigger
*/
    
public class ApplicationTriggerMethods {
    //Constants
    public static final String RISK_ASSESSMENT_RT_DEVNAME = 'Risk_Assessment_Reference';
    public static final String STANDARD_REFERENCES_RT_DEVNAME = 'Standard_Reference';
    public static final String STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_CERTIFICATE_APPROVED = 'Certificate Approved';
    public static final String DBS_NO_CHECK_REQUIRED = 'No Check Required';
    public static final String RT_CORPORATE = 'Corporate';
    public static List<Application__c> processList {get; set;}
    public static Map<Id, Role_Opportunity__c> roleMap {get; set;}
    public static Map<String, RecordType> recordTypeMap {get; set;}
    
    //2014-09-11 : CSL : This method will take all Application__c records and delete them if the field Automatic_Deletion_Required__c = TRUE
    @future(callout=false)
    public static void autoDeleteApplications(List<Id> inIds){
        
        List<Application__c> recordsToDelete = [select a.Id from Application__c a where a.Id in :inIds];
        
        try {
            delete recordsToDelete;
        }catch (DMLException dmlEx){
            system.debug('*** -- Error in ApplicationTriggerMethods.autoDeleteApplications -- ***');
            system.debug('*** -- Error : ' + DMLEx + ' -- ***');
        }
        
    }
    
    
    //2014-03-07 : SM : This method will update the User record linked to each Application__c, with the Group_Induction__c value
    
    public static void updateGroupInduction(List<Application__c> inRecords){
        Set<Id> contactIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        
        for (Application__c a : inRecords){
            contactIds.add(a.Applicant__c);
        }
        
        for (User u : [select u.Id, u.ContactId, u.Group_Induction__c from User u where u.ContactId in :contactIds]){
            userMap.put(u.ContactId, u);
        }
        
        for (Application__c a : inRecords){
            User u = userMap.get(a.Applicant__c);
            if (u != null){
                u.Group_Induction__c = a.Group_Induction__c;
            }
        }
        
        update userMap.values();
        
    }
    
    public static void markApplicationCheckboxesOnInsert(List<Application__c> inRecords){
        //This method is called only on Insert of new applications, and sets the documentation checkboxes
        recordTypeMap = new Map<String, RecordType>();
        for (RecordType r : [select r.DeveloperName, r.Name, r.Id, r.SobjectType from RecordType r where r.IsActive = true]){
            recordTypeMap.put(r.DeveloperName, r);
        }
        Set<Id> oppIdList = new Set<Id>();
        for (Application__c a : inRecords){
            oppIdList.add(a.Role__c);
        }
        roleMap = new Map<Id, Role_Opportunity__c>();
        for (Role_Opportunity__c r : [select r.Id, r.DBS_Check_required__c, r.Vehicle_Check_Required__c, r.Number_of_References_Required__c from Role_Opportunity__c r where r.Id in :oppIdList]){
            roleMap.put(r.Id, r);
        }
        
        for (Application__c a : inRecords){
            Role_Opportunity__c ro = roleMap.get(a.Role__c);
            integer refsRequired = (ro.Number_of_References_Required__c == null ? 0 : integer.valueOf(ro.Number_of_References_Required__c));
            system.debug('*** -- refs required = ' + refsRequired + ' -- ***');
            if (ro != null){
                //Criminal Record Checks
                if (DBS_NO_CHECK_REQUIRED.equalsIgnoreCase(ro.DBS_Check_required__c)){
                    a.Criminal_Check_OK__c = true;
                }
                //References
                system.debug('*** -- References section -- ***');
                if (refsRequired <= 0){
                    system.debug('*** -- references NOT required -- ***');
                    a.References_OK__c = true;
                }
                
                //Vehicle Check
                if (!ro.Vehicle_Check_Required__c){
                    a.Vehicle_Check_OK__c = true;
                }
                
            }   
            
        }
        
    }

    public static void markApplicationCheckboxes(List<Application__c> inRecords){
        system.debug('*** -- Into markApplicationCheckboxes method -- ***');
        //This method will update incoming Application__c records in preparation for 
        //a validation rule
        recordTypeMap = new Map<String, RecordType>();
        for (RecordType r : [select r.DeveloperName, r.Name, r.Id, r.SobjectType from RecordType r where r.IsActive = true]){
            recordTypeMap.put(r.DeveloperName, r);
        }
        Set<Id> appIdList = new Set<Id>();
        Set<Id> oppIdList = new Set<Id>();
        for (Application__c a : inRecords){
            appIdList.add(a.Id);
            oppIdList.add(a.Role__c);
        }
        roleMap = new Map<Id, Role_Opportunity__c>();
        for (Role_Opportunity__c r : [select r.Id, r.DBS_Check_required__c, r.Vehicle_Check_Required__c, r.Number_of_References_Required__c from Role_Opportunity__c r where r.Id in :oppIdList]){
            roleMap.put(r.Id, r);
        }
        processList = new List<Application__c>();
        processList = [Select a.Id, a.Role__c, References_OK__c, a.Criminal_Check_OK__c, Vehicle_Check_OK__c, 
                        (Select Id, Status__c From Vehicle_Checks__r), 
                        (Select Id, Status__c From Risk_Assessments__r), 
                        (Select Id, Outcome__c, RecordTypeId From References__r where Outcome__c = :STATUS_APPROVED or Outcome__c = :STATUS_ACCEPTED)
                         From Application__c a where a.Id in :appIdList];
        
        system.debug('*** -- Start processing loop -- ***');
        for (Application__c a : processList){
            Role_Opportunity__c ro = roleMap.get(a.Role__c);
            integer refsRequired;
            if (ro != null){
                refsRequired = (ro.Number_of_References_Required__c == null ? 0 : integer.valueOf(ro.Number_of_References_Required__c));
            }
            system.debug('*** -- refs required = ' + refsRequired + ' -- ***');
            if (ro != null){
                //Criminal Record Checks
                if (!DBS_NO_CHECK_REQUIRED.equalsIgnoreCase(ro.DBS_Check_required__c)){
                    for (Risk_Assessment__c ra : a.Risk_Assessments__r){
                        if (STATUS_APPROVED.equalsIgnoreCase(ra.Status__c) || STATUS_CERTIFICATE_APPROVED.equalsIgnoreCase(ra.Status__c)){
                            a.Criminal_Check_OK__c = true;
                            break;
                        }
                    }
                }else {
                    a.Criminal_Check_OK__c = true;
                }
                //References
                system.debug('*** -- References section -- ***');
                boolean referencesOK = false;
                integer referenceCount = 0;
                if (refsRequired > 0){
                    system.debug('*** -- references are required -- ***');
                    for (Reference__c r : a.References__r){
                        if (r.RecordTypeId == recordTypeMap.get(RISK_ASSESSMENT_RT_DEVNAME).Id){
                            if (STATUS_APPROVED.equalsIgnoreCase(r.Outcome__c)){
                                referencesOK = true;
                                break;
                            }
                        }
                    }
                    if (!referencesOK){
                        for (Reference__c r : a.References__r){
                            if (r.RecordTypeId == recordTypeMap.get(STANDARD_REFERENCES_RT_DEVNAME).Id){
                                if (STATUS_ACCEPTED.equalsIgnoreCase(r.Outcome__c)){
                                    referenceCount ++;
                                }
                            }
                        }
                        if (referenceCount == refsRequired){
                            referencesOK = true;
                        }
                    }
                }else {
                    system.debug('*** -- references NOT required -- ***');
                    referencesOK = true;
                }
                system.debug('*** -- Set the application References OK field with ' + referencesOK + ' -- ***');
                a.References_OK__c = referencesOK;
                //Vehicle Check
                if (ro.Vehicle_Check_Required__c){
                    for (Vehicle_Check__c vc : a.Vehicle_Checks__r){
                        if (STATUS_ACTIVE.equalsIgnoreCase(vc.Status__c)){
                            a.Vehicle_Check_OK__c = true;
                            break;
                        }
                    }
                }else {
                    a.Vehicle_Check_OK__c = true;
                }
                
            }   
            
        }
        
        
    }
    
 @IsTest(SeeAllData=true)
 private static void test_ApplicationTriggerMethods() {
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
    insert ref1;
    Reference__c ref2 = new Reference__c(RecordTypeId = standardRef.Id);
    ref2.Contact__c = referenceContact2.Id;
    ref2.Application__c = application.Id;
    insert ref2;
    
    RecordType crcRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_CRIMINAL_RECORD_CHECK);
    Risk_Assessment__c crCheck = TestUtilities.getCriminalRecordCheck(crcRt.Id);
    crCheck.Application__c = application.Id;
    crCheck.Volunteer__c = volunteerContact.Id;
    crCheck.Status__c = TestUtilities.STATUS_ACCEPTED;
    insert crCheck;
    
    //Update the CRCheck to fire the trigger
    
    update crCheck;
    
    system.debug('*** -- finished inserting all records - about to start test -- ***');
    test.startTest();
    
    Vehicle_Check__c vc = new Vehicle_Check__c();
    vc.Registration__c = 'AB12 CDE';
    vc.Role__c = application.Id;
    vc.Volunteer__c = volunteerContact.Id;
    vc.Status__c = 'Active';
    insert vc;
    
    Application__c updateApp = TestUtilities.getApplicationRecord(application.Id);
    updateApp.Status__c = 'Successful';
    updateApp.Group_Induction__c = Date.today().addDays(2);
    update updateApp;
    
    ref1.Outcome__c = 'Accepted';
    update ref1;
    
    ref2.RecordTypeId = riskAssessment.Id;
    ref2.Outcome__c = 'Approved';
    update ref2;
    
    test.stopTest();
 }  
}