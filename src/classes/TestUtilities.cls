/**
 * This class contains test helper methods to return various objects and collections
 * to be used in test classes
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestUtilities {
    public static final String STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_INACTIVE = 'Inactive';
    public static final String RT_CORPORATE = 'Corporate';
    public static final String RT_INTERNSHIP = 'Internship';
    public static final String RT_ONE_OFF = 'One Off';
    public static final String RT_PEER_SUPPORT = 'Peer Support';
    public static final String RT_SPECIALIST = 'Specialist';
    public static final String RT_STANDARD = 'Standard';
    public static final String RT_TRUSTEE = 'Trustee';
    public static final String RT_WORK_EXPERIENCE = 'Work Experience';
    public static final String RT_WORK_PLACEMENT = 'Work Placement';    
    public static final String RT_APPLICANT = 'Applicant';
    public static final String RT_CUSTOMER = 'Customer';
    public static final String RT_REFERENCE = 'Reference';
    public static final String RT_REFERRER = 'Referrer';
    public static final String RT_STAFF = 'Staff';
    public static final String RT_VOLUNTEER = 'Volunteer';
    public static final String RT_APPLICATION = 'Application';
    public static final String RT_ROLE = 'Role';
    public static final String RT_STANDARD_REFERENCE = 'Standard Reference';
    public static final String RT_RISK_ASSESSMENT = 'Risk Assessment Reference';
    public static final String RT_CRIMINAL_RECORD_CHECK = 'Criminal Record Check';
    public static final String RT_CR_RISK_ASSESSMENT = 'CR Risk Assessment';
    public static final String RT_CUSTOMER_REQUEST_PORTAL = 'Customer Requests - Portal';
    public static final String OUTCOME_ACCEPTED = 'Accepted';
    public static final String OUTCOME_APPROVED = 'Approved';
    
    public static Map<String, RecordType> getRecordTypeMap(){
        Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
        for (RecordType r : [select r.Id, r.Name, r.SObjectType, r.DeveloperName from RecordType r where IsActive = true]){
            recordTypeMap.put(r.Name, r);
        }
        return recordTypeMap;
    }

    public static Application__c getApplication(Id volunteerContactId){
        RecordType appRT = getRecordTypeMap().get(RT_APPLICATION);
        Application__c application = new Application__c(RecordTypeId = appRT.Id);
        application.Applicant__c = volunteerContactId;
        application.Status__c = STATUS_ACTIVE;
        
        return application;
    }

    public static Customer_Requests__c getCustomerRequest(){
        RecordType portalRT = getRecordTypeMap().get(RT_CUSTOMER_REQUEST_PORTAL);
        Customer_Requests__c customerRequest = new Customer_Requests__c(RecordTypeId = portalRT.Id);
        customerRequest.Subject__c = 'Test Customer Request';
       /* customerRequest.
       __c = 'Test Customer Request';*/
        customerRequest.Status__c = 'New';
        customerRequest.Service__c = 'Technology Support';
        customerRequest.Customer_Request_Origin__c = 'Web';
        
        return customerRequest;
    } 
    
    public static Contact getCustomerContact(){
        RecordType customerRT = getRecordTypeMap().get(RT_CUSTOMER);
        Contact customerContact = new Contact(RecordTypeId = customerRT.Id);
        customerContact.FirstName = 'Customer';
        customerContact.LastName = 'Contact';
        customerContact.MailingStreet = '111 Customer Road';
        customerContact.MailingCity = 'London';
        customerContact.MailingState = 'London';
        customerContact.MailingPostalCode = 'W1 3TT';
        customerContact.Email = 'customer.contact@myemail.com';
        customerContact.Phone = '02075555555';
        
        return customerContact; 
    }

    public static Risk_Assessment__c getCriminalRecordCheck(Id rtId){
         
        Risk_Assessment__c criminalRecordCheck = new Risk_Assessment__c(RecordTypeId = rtId);
        return criminalRecordCheck;
    }

    public static Application__c getApplicationRecord(String applicationId){
        return [Select a.Convicted_of_Criminal_Offence__c, a.Criminal_Offence_Details__c, a.Why_do_you_want_to_volunteer_for_us__c, a.Why_do_work_experience_with_RNIB__c, a.Volunteer_Manager__c, a.Volunteer_Coordinator__c, 
                    a.Voluntary_or_Work_Experience__c, a.Tell_us_about_yourself__c, a.Status__c, a.Start_Date__c, a.Service__c, a.School_College__c, 
                    a.School_College_Phone__c, a.School_College_Contact__c, a.Role__c, a.Role_Title__c, a.Role_Source__c, a.Role_Description__c, a.Risk_Assessments__c, 
                    a.References_Unavailable__c, a.References_Unavailable_Explanation__c, a.RecordTypeId, a.Reason_for_leaving__c, a.Name, a.Id, a.Experience_Qualifications__c, a.End_Date__c, a.Education__c, a.ContactName__c, 
                    a.College_Univeristy_Workplace__c, a.College_Univeristy_Workplace_Phone__c, a.College_Univeristy_Workplace_Contact__c, a.Applicant__c, 
                    a.Accepted_Reference_Checks__c, a.Number_of_Corporate_Volunteers__c, (Select Daytime_Phone__c, ReferenceLastName__c, Salutation, Reference_Number__c, RecordTypeId, Phone, Name, MobilePhone, MailingStreet, 
                    MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, Id, HomePhone, FirstName, Email, Application__c From Contacts__r order by Reference_Number__c ASC),
                    (Select Contact__c, Application__c, Relationship__c, Length_of_relationship__c, Reference_Type__c From References__r)
                    from Application__c a where a.Id = :applicationId];
    }

    public static Contact getContactRecord(String contactId){
        return [Select c.Salutation, c.Phone, c.Name, 
                    c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LastName, c.HomePhone, c.FirstName, c.Email, c.Availability__c, 
                    c.Areas_of_Interest__c, c.Age__c, c.AccountId, c.Holiday__c From Contact c where c.Id = :contactId];
    }

    public static Contact getReferenceContact(String whichRef){
        RecordType rt = TestUtilities.getRecordTypeMap().get(RT_REFERENCE);
        Contact referenceContact = new Contact(RecordTypeId = rt.Id);
        if (whichRef == '1'){
            referenceContact.FirstName = 'Test';
            referenceContact.LastName = 'Reference1';
            referenceContact.MailingStreet = '456 Ref One Road';
            referenceContact.MailingCity = 'London';
            referenceContact.MailingState = 'London';
            referenceContact.MailingPostalCode = 'W1 3RR';
            referenceContact.Email = 'test.reference1@myemail.com';
            referenceContact.Phone = '02072222222';
        }else if (whichRef == '2'){
            referenceContact.FirstName = 'Test';
            referenceContact.LastName = 'Reference2';
            referenceContact.MailingStreet = '789 Ref Two Road';
            referenceContact.MailingCity = 'London';
            referenceContact.MailingState = 'London';
            referenceContact.MailingPostalCode = 'W1 4SS';
            referenceContact.Email = 'test.reference2@myemail.com';
            referenceContact.Phone = '02073333333';
        }
        return referenceContact;
    }

    public static Contact getReferenceContact1(){
        RecordType rt = TestUtilities.getRecordTypeMap().get(RT_REFERENCE);
        Contact referenceContact1 = new Contact(RecordTypeId = rt.Id);
            referenceContact1.FirstName = 'Test';
            referenceContact1.LastName = 'Reference1';
            referenceContact1.MailingStreet = '456 Ref One Road';
            referenceContact1.MailingCity = 'London';
            referenceContact1.MailingState = 'London';
            referenceContact1.MailingPostalCode = 'W1 3RR';
            referenceContact1.Email = 'test.reference1@myemail.com';
            referenceContact1.Phone = '02072222222';
        return referenceContact1;
    }

    public static Contact getReferenceContact2(){
        RecordType rt = TestUtilities.getRecordTypeMap().get(RT_REFERENCE);
        Contact referenceContact2 = new Contact(RecordTypeId = rt.Id);
            referenceContact2.FirstName = 'Test';
            referenceContact2.LastName = 'Reference1';
            referenceContact2.MailingStreet = '456 Ref One Road';
            referenceContact2.MailingCity = 'London';
            referenceContact2.MailingState = 'London';
            referenceContact2.MailingPostalCode = 'W1 3RR';
            referenceContact2.Email = 'test.reference1@myemail.com';
            referenceContact2.Phone = '02072222222';
        return referenceContact2;
    }




    public static Role_Opportunity__c getRoleOpportunity(String RTName, Id RTId){
        Role_Opportunity__c roleOpportunity = new Role_Opportunity__c(RecordTypeId = RTId);
        roleOpportunity.Opportunity_Family__c = 'Technology';
        roleOpportunity.Role_Title__c = 'Test Role';
       roleOpportunity.Role_Description__c = 'Test Role Description';
        roleOpportunity.What_will_I_be_doing__c = 'Test what will I be doing';
        roleOpportunity.What_will_I_gain_from_the_role__c ='A chance to give something back';
        roleOpportunity.What_support_will_I_be_given__c = 'Induction';
        roleOpportunity.Interests__c = 'Admin';
        roleOpportunity.Availability__c = 'Flexible';
        roleOpportunity.Start_Date__c = date.today();
        roleOpportunity.Hours_per_week__c = 40;
        roleOpportunity.Location__c = 'North West';
        roleOpportunity.Work_Location__c = 'On Site';
        roleOpportunity.DBS_Check_required__c = 'No Check Required';
        roleOpportunity.RNIB_Group__c = 'RNIB';
        roleOpportunity.Strategic_Priority__c = 'Inclusion';
        roleOpportunity.Do_you_want_your_opportunity_advertised__c = 'Yes';
        
        
        if (RT_CORPORATE.equalsIgnoreCase(RTName)){
            roleOpportunity.Capacity__c = 3;
        }else if (RT_INTERNSHIP.equalsIgnoreCase(RTName)){
            
        }else if (RT_ONE_OFF.equalsIgnoreCase(RTName)){
            
        }else if (RT_PEER_SUPPORT.equalsIgnoreCase(RTName)){
            
        }else if (RT_SPECIALIST.equalsIgnoreCase(RTName)){
            
        }else if (RT_STANDARD.equalsIgnoreCase(RTName)){
            
        }else if (RT_TRUSTEE.equalsIgnoreCase(RTName)){
            
        }else if (RT_WORK_EXPERIENCE.equalsIgnoreCase(RTName)){
            
        }else if (RT_WORK_PLACEMENT.equalsIgnoreCase(RTName)){
            
        }
        
        return roleOpportunity;
        
    }
    
    
}