/*
* 2014-01-13 : SM : Controller to show volunteers on a Google map based on distance from the Post Code listed on a Customer Request.
*
* 2014-10-28 : SM : Adding in new code to pull in the Customer Request Assignment rule for the request
* and so find the primary AND secondary owner, because in some cases the Volunteer Roles (applications) could not be seen 
* by the secondary owner
*/
public class VolunteerMatchingController {

  public Contact coordinator {
    get {
        if (coordinator == null){
            coordinator = new Contact();
        }
        return coordinator;
    }
    set;
  }
  
  public Boolean refreshmatches {
    get {
      if (refreshmatches == null) {
        refreshmatches = false;
      }

      return refreshmatches;
    }
    set;
  }
    
    public Boolean shortlistmap {
    get {
      if (shortlistmap == null) {
        shortlistmap = false;
      }

      return shortlistmap;
    }
    set;
  }
  
  public Boolean refreshmap {
    get {
      if (refreshmap == null) {
        refreshmap = false;
      }

      return refreshmap;
    }
    set;
  }
  
  public final String GVT_GROUP_DEVELOPER_NAME = 'GVT_Administrators';  
  
  public Id coordinatorId {get; set;}
  public Id secondaryCoordinatorId {get; set;}
  public Id customerRequestId {get; set;}
  public List<ContactWrapper> listOfVolunteers {get; set;}
  public Set<Id> ownerIdSet {get; set;}
  public Set<Id> userOwnerIdSet {get; set;}
  public Contact searchContact {get; set;}
  public Customer_Requests__c theRequest {get; set;}
  public RecordType volunteerRT {get; set;}
  public EmailTemplate crEmailTemplate {get; set;}
  public String distanceFilter {get; set;}
  public String serviceFilter {get; set;}
  public String searchOrder {get; set;}
  public Group gvtGroup {get; set;}

  public List<SelectOption> distanceChoices {
        get {
            if (distanceChoices == null){
                distanceChoices = new List<SelectOption>();
                distanceChoices.add(new SelectOption('NULL','-None-'));
                distanceChoices.add(new SelectOption('1','1'));
                distanceChoices.add(new SelectOption('3','3'));
                distanceChoices.add(new SelectOption('5','5'));
                distanceChoices.add(new SelectOption('10','10'));
                distanceChoices.add(new SelectOption('15','15'));
                distanceChoices.add(new SelectOption('20','20'));
                distanceChoices.add(new SelectOption('50','50'));
                distanceChoices.add(new SelectOption('100','100'));
            }
            return distanceChoices;
        }
        set;
    }
    
    public List<SelectOption> searchOrderChoices {
        get {
            if (searchOrderChoices == null){
                searchOrderChoices = new List<SelectOption>();
                searchOrderChoices.add(new SelectOption('NULL','-None-'));
                searchOrderChoices.add(new SelectOption('Distance','Distance'));
                searchOrderChoices.add(new SelectOption('Title','Role Title'));
            }
            return searchOrderChoices;
        }
        set;
    }
    
    
    public List<SelectOption> serviceChoices {
        get {
            if (serviceChoices == null){
                serviceChoices = new List<SelectOption>();
                serviceChoices.add(new SelectOption('NULL','-None-'));
                Schema.DescribeFieldResult theField = Customer_Requests__c.Service__c.getDescribe();
                for (Schema.Picklistentry pe : theField.getPickListValues()){
                    serviceChoices.add(new SelectOption(pe.getValue(), pe.getLabel()));
                }
            }
            return serviceChoices;
        }
        set;
    }

    public VolunteerMatchingController(ApexPages.StandardController standardController) {
        //Build a list of needed record types and required records
        volunteerRT = [select r.Id from RecordType r where r.Name = 'Volunteer' and r.SobjectType = 'Contact' LIMIT 1];
        searchContact = new Contact(RecordTypeId = volunteerRT.Id);
        crEmailTemplate = [Select e.Name, e.Id From EmailTemplate e where e.Name  = 'CustomerRequestResponse' and isActive = true LIMIT 1];
        gvtGroup = [select g.Id, g.DeveloperName from Group g where g.DeveloperName = :GVT_GROUP_DEVELOPER_NAME LIMIT 1];
        listOfVolunteers = new List<ContactWrapper>();
        //Get the Customer Request parameter
        customerRequestId = ApexPages.currentPage().getParameters().get('cr');
        
        //Get the request
        theRequest = [Select c.OwnerId, c.Volunteer_Coordinator__c, c.Subject__c, c.Service__c, c.Mapping_Status__c, c.Location__Longitude__s, c.Location__Latitude__s, c.Description__c, c.Customer_Post_Code__c, c.Customer_Name__c, c.Customer_Address__c From Customer_Requests__c c where c.Id = :customerRequestId LIMIT 1];
        //New code to pull in the Customer Request Assignment Rule record
        
        String postCodeTrim;
        if (theRequest.Customer_Post_Code__c != null){           
            integer spaceInt = theRequest.Customer_Post_Code__c.indexOf(' ');
            postCodeTrim = theRequest.Customer_Post_Code__c.substring(0,spaceInt).trim().toUpperCase();
        
        
            List<Customer_Request_Assignment_Rule__c> crarList = [Select c.Service__c, c.Secondary_Owner__c, c.Primary_Owner__c, c.Post_Code__c, c.Id 
                                                                From Customer_Request_Assignment_Rule__c c where c.Post_Code__c = :postCodeTrim
                                                                and c.Service__c = :theRequest.Service__c LIMIT 1];
                                                                
            if (crarList != null && !crarList.isEmpty()){
                coordinatorId = crarList[0].Primary_Owner__c;
                secondaryCoordinatorId = crarList[0].Secondary_Owner__c;
                system.debug('*** -- coordinatorId = ' + coordinatorId + ' -- ***');
                system.debug('*** -- secondaryCoordinatorId = ' + secondaryCoordinatorId + ' -- ***');
            }else {
                coordinatorId = theRequest.OwnerId;
            }                                                        
        }else {
            coordinatorId = theRequest.OwnerId;
        }
        
        //coordinatorId = theRequest.OwnerId;
        ownerIdSet = new Set<Id>();
        Map<String, Application__c> applicationMap = new Map<String, Application__c>();
        
        if (secondaryCoordinatorId != null){
            system.debug('*** -- About to do the secondary search -- ***');
            for (Application__c a : [select a.Id, a.Applicant__c, a.Volunteer_Coordinator__c, a.Role_Title__c from Application__c a where a.Status__c = 'Active' and (a.Volunteer_Coordinator__c = :coordinatorId OR a.Volunteer_Coordinator__c = :secondaryCoordinatorId)]){
                system.debug('*** -- found ' + a.Id + ' -- ***');
                system.debug('*** -- adding applicant ' + a.Applicant__c + ' -- ***');
                system.debug('*** -- role Id ' + a.Id + ' -- ***');
                system.debug('*** -- role Name ' + a.Role_Title__c + ' -- ***');
                applicationMap.put(a.Applicant__c, a);
                ownerIdSet.add(a.Applicant__c); 
            }
        }else {
            system.debug('*** -- About to do the primary only search -- ***');
            for (Application__c a : [select a.Id, a.Applicant__c, a.Volunteer_Coordinator__c, a.Role_Title__c from Application__c a where a.Status__c = 'Active' and a.Volunteer_Coordinator__c = :coordinatorId]){
                system.debug('*** -- found ' + a.Id + ' -- ***');
                system.debug('*** -- adding applicant ' + a.Applicant__c + ' -- ***');
                system.debug('*** -- role Id ' + a.Id + ' -- ***');
                system.debug('*** -- role Name ' + a.Role_Title__c + ' -- ***');
                applicationMap.put(a.Applicant__c, a);
                ownerIdSet.add(a.Applicant__c); 
            }
        }
        
        
        
        userOwnerIdSet = new Set<Id>();
                
        for (User u : [select u.Id, u.ContactId from User u where u.ContactId in :ownerIdSet]){
            system.debug('*** -- adding ' + u.Id + ' -- ***');
            userOwnerIdSet.add(u.Id);
        }   
        
        
        for (Contact c : [Select c.Skills__c, c.Salutation, c.RecordTypeId, c.MobilePhone, c.MailingStreet, c.MailingState, c.MailingPostalCode, 
                            c.MailingCountry, c.MailingCity, c.LastName, c.Id, c.FirstName, c.Email, c.Availability__c, c.OwnerId, c.Status__c,
                            c.Holiday__c, c.Application__r.Role_Title__c, c.Application__c From Contact c 
                            where c.id in :ownerIdSet
                            and c.Status__c = 'Active'
                            and c.Holiday__c = false
                            and c.RecordTypeId = :volunteerRT.Id]){
                                ContactWrapper cw = new ContactWrapper(c);
                                cw.roleName = applicationMap.get(c.Id).Role_Title__c;
                                cw.roleId = applicationMap.get(c.Id).Id;
                                system.debug('*** -- Role Name = ' + cw.roleName + ' -- ***');
                                system.debug('*** -- Role ID = ' + c.Application__c + ' -- ***');
                                system.debug('*** -- Role Title = ' + c.Application__r.Role_Title__c + ' -- ***');
                                //listOfVolunteers.add(new ContactWrapper(c));
                                listOfVolunteers.add(cw);
                            }
        
    }

    
    public PageReference sendEmailNotification(){
        system.debug('*** -- Into sendEmailNotification with ' + matches.size() + ' matches -- ***');
        List<CR_Notification__c> notificationList = new List<CR_Notification__c>();
        List<ContactWrapper> contactsToSendTo = new List<ContactWrapper>();
        if (matches != null){
            for (ContactWrapper cw : matches){
                if (cw.isSelected){
                    system.debug('*** -- adding ' + cw.theContact.Email + ' of Id ' + cw.theContact.Id + ' -- ***');
                    contactsToSendTo.add(cw);
                }
            }
        }
        system.debug('*** -- About to send to ' + contactsToSendTo.size() + ' contacts -- ***');
        List<Id> contactIds = new List<Id>();
        List<Id> customerRequestIdList = new List<Id>();
        List<String> toAddresses = new List<String>();
        customerRequestIdList.add(customerRequestId);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (ContactWrapper cw : contactsToSendTo){
            if (cw.theContact.Email != null){
                system.debug('*** -- Send to ' + cw.theContact.Email + ' -- ***');
                contactIds.add(cw.theContact.Id);
                toAddresses.add(cw.theContact.Email);
            
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(crEmailTemplate.Id);
                mail.setTargetObjectId(cw.theContact.Id);
                mail.setWhatId(customerRequestId);
                emails.add(mail);
                
                CR_Notification__c crn = new CR_Notification__c();
                crn.Customer_Request__c = customerRequestId;
                crn.Volunteer__c = cw.theContact.Id;
                crn.Date_Notification_Sent__c = system.now();
                crn.Volunteer_Role_ID__c = cw.theApplication.Id;
                notificationList.add(crn);
                
            }
        }
        system.debug('*** -- About to send emails... -- ***');
        try {
            Messaging.sendEmail(emails, false);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Emails Successfully Sent'));
                
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Emails NOT Sent'));
        }
        system.debug('*** -- About to save Notification list -- ***');
        //Insert the notification lists
        insert notificationList;
        
        return null;
    }
    

  public List<ContactWrapper> matches {
    get {
      String labelname = 'ABCDEFGHIJLKMNOPQRSYUVWXYZ';
      if (matches == null || refreshmatches == true) {

        matches = new List<ContactWrapper>();
        Map<String, Application__c> applicationMap = new Map<String, Application__c>();
        if (secondaryCoordinatorId != null){
            for (Application__c a : [select a.Id, a.Applicant__c, a.Volunteer_Coordinator__c, a.Role_Title__c, a.Service__c from Application__c a where a.Status__c = 'Active' and (a.Volunteer_Coordinator__c = :coordinatorId OR a.Volunteer_Coordinator__c = :secondaryCoordinatorId)]){
                applicationMap.put(a.Applicant__c, a);
            }        
        }else {
            for (Application__c a : [select a.Id, a.Applicant__c, a.Volunteer_Coordinator__c, a.Role_Title__c, a.Service__c from Application__c a where a.Status__c = 'Active' and a.Volunteer_Coordinator__c = :coordinatorId]){
                applicationMap.put(a.Applicant__c, a);
            }
        }
        
        
        try {
          //List<Contact> contactmatches = Database.query('Select c.Skills__c, c.Salutation, c.RecordTypeId, c.MobilePhone, c.MailingStreet, c.MailingState, c.MailingPostalCode,   c.MailingCountry, c.MailingCity, c.LastName, c.Id, c.FirstName, c.Email, c.Availability__c, c.OwnerId, c.Location__Longitude__s, c.Location__Latitude__s FROM Contact c WHERE c.OwnerId =  \'' + animaltype + '\'' + typesearchterm + sitesearchterm + breedsearchterm + gendersearchterm + microchipsearchterm + postcodesearchterm + primarycoloursearchterm + geosearchterm + datesearchterm +
          //  'ORDER BY Lost_Found_Date__c DESC LIMIT 80');
          String requestLoc;
          String applicantLoc;
          if (theRequest.Location__Longitude__s != null && theRequest.Location__Latitude__s != null){
             requestLoc = theRequest.Location__Latitude__s + ',' + theRequest.Location__Longitude__s;
          }
          String applicationQuery = 'Select a.Applicant__c, a.Applicant__r.Skills__c, a.Applicant__r.Salutation, a.Applicant__r.RecordTypeId, a.Applicant__r.MobilePhone, a.Applicant__r.MailingStreet, a.Applicant__r.MailingState, a.Applicant__r.MailingPostalCode, a.Applicant__r.MailingCountry, ';
          applicationQuery += 'a.Applicant__r.MailingCity, a.Applicant__r.LastName, a.Applicant__r.Id, a.Applicant__r.FirstName, a.Applicant__r.Email, a.Applicant__r.Availability__c, a.Applicant__r.OwnerId, a.Applicant__r.Location__Longitude__s, a.Applicant__r.Location__Latitude__s, ';
          applicationQuery += 'a.Id, a.Role_Title__c ';
          applicationQuery += 'FROM Application__c a WHERE a.Status__c = \'Active\' AND a.Applicant__r.RecordTypeId = \'' + volunteerRT.Id + '\' AND '; 
          if (theRequest.OwnerId != gvtGroup.Id){
            //applicationQuery += 'a.Volunteer_Coordinator__c = \'' + theRequest.OwnerId + '\' AND ';
            if (secondaryCoordinatorId != null){
                applicationQuery += '(a.Volunteer_Coordinator__c = \'' + secondaryCoordinatorId + '\' OR ';
                applicationQuery += 'a.Volunteer_Coordinator__c = \'' + coordinatorId + '\') AND ';    
            }else {
                applicationQuery += 'a.Volunteer_Coordinator__c = \'' + coordinatorId + '\' AND ';
            }
          }
          applicationQuery += 'a.Applicant__r.Holiday__c = false ';
          if (distanceFilter != null && !distanceFilter.equalsIgnoreCase('NULL')){
            applicationQuery += 'and DISTANCE(a.Applicant__r.Location__c, GEOLOCATION(' + requestLoc + '), \'mi\') < ' + distanceFilter + ' ';
          }
          if (serviceFilter !=  null && !serviceFilter.equalsIgnoreCase('NULL')){
            applicationQuery += 'and a.Service__c = \'' + serviceFilter + '\' ';
          }
          
          if (searchOrder != null && !searchOrder.equalsIgnoreCase('NULL')){
            if ('TITLE'.equalsIgnoreCase(searchOrder)){
                    applicationQuery += 'ORDER BY a.Role_Title__c, DISTANCE(a.Applicant__r.Location__c, GEOLOCATION('+requestLoc+'), \'mi\')';
            }else if ('DISTANCE'.equalsIgnoreCase(searchOrder)){
                if (requestLoc != null){
                    applicationQuery += 'ORDER BY DISTANCE(a.Applicant__r.Location__c, GEOLOCATION('+requestLoc+'), \'mi\'), a.Role_Title__c';
                }   
            }        
          }
          
           
          //2014-03-03 : SM : Changed from LIMIT 10 to LIMIT 26
          if (distanceFilter == null && serviceFilter == null){
            applicationQuery += ' LIMIT 26';
          }
          system.debug('*** -- About to run query : -- ***');
          system.debug('*** -- ' + applicationQuery + ' -- ***');
          List<Application__c> applicationMatches = Database.query(applicationQuery);
          Set<Id> contactIdSet = new Set<Id>();
          for (Application__c a : applicationMatches){
            contactIdSet.add(a.Applicant__c);
            ContactWrapper cw = new ContactWrapper(a);
            
            matches.add(cw);
          }
          
          Map<Id, Contact> contactMap = new Map<Id, Contact>([select c.Id, c.Email From Contact c where c.Id in :contactIdSet]);
          
          for (ContactWrapper cw : matches){
            cw.theContact = contactMap.get(cw.theApplication.Applicant__c); 
          }
          
        } catch (Exception ex) {
          matches = null;
        }

      }

      if (matches != null) {
        for (Integer count = 0; count < 20 && count < matches.size(); count++ ) {
          matches[count].matchlabel = labelname.mid(count,1);
        }
      }

      refreshmatches = false;
      return matches;
    }
    set;
  }
    
  public String maphtml {
    get {
      if (maphtml == null || refreshmap == true) {
        List<ContactWrapper> mapContacts = new List<ContactWrapper>();
        String markers = '';
        String centermarker = '&markers=color:red%7Clabel:0%7C';
        String mapbaseurl = 'http://maps.googleapis.com/maps/api/staticmap?center=';
        String mapcenter = '+';
        String mapsizetype = '&size=600x300&maptype=roadmap';
        String mapsensor = '&sensor=false';
        String markerlocation = '+';
        String mapzoom = '&zoom=9';

        if (theRequest.Customer_Post_Code__c != null) {
          mapcenter = string.valueof(theRequest.Location__Latitude__s) + ',' + 
                      string.valueof(theRequest.Location__Longitude__s);
          //mapcenter = theRequest.Customer_Post_Code__c.replace(' ', '+');
        }else {
            //mapcenter = coordinator.MailingPostalCode.replace(' ', '+');
            mapcenter = 'SL6+1HY';
        }
        centermarker = centermarker + mapcenter + mapzoom;
        system.debug('*** -- centreMarker = ' + centermarker + ' -- ***');

        mapContacts = matches;
        
        if (mapContacts != null) {
          for (Integer count = 0; count < 20 && count < mapContacts.size(); count++ ) {
            system.debug('*** -- doing map label ' + count + ' -- ***');
            if (mapContacts[count].theApplication.Applicant__r.Location__Latitude__s != null) {
                system.debug('*** -- Found location values -- ***');
              markerlocation =  string.valueof(mapContacts[count].theApplication.Applicant__r.Location__Latitude__s) + ',' + 
                        string.valueof(mapContacts[count].theApplication.Applicant__r.Location__Longitude__s);
            } else if (mapContacts[count].theApplication.Applicant__r.MailingPostalCode != null) {
              markerlocation = mapContacts[count].theApplication.Applicant__r.MailingPostalCode.replace(' ', '+');
            } 
          
            String thismarker = '&markers=color:green%7Clabel:' + mapContacts[count].matchlabel + '%7C' + markerlocation;
            system.debug('*** -- setting marker ' + thisMarker + ' -- ***');
            markers = markers + thismarker;
          }
          maphtml = mapbaseurl + mapcenter + mapsizetype + centermarker + markers + mapsensor;
        } else {
          maphtml = mapbaseurl + mapcenter + mapsizetype + centermarker + mapsensor;
        }
      }
      //system.debug('*** -- maphtml ' + maphtml + ' -- ***');
      refreshmap = false;
      shortlistmap = false;
      return maphtml;
    }
    set;
  }
  
  public PageReference searchVolunteers() {

    refreshmatches = true;
    refreshmap = true;
    
    return null;
  }
  
  public PageReference searchClear() {

    distanceFilter = null;
    serviceFilter = null;
    refreshmatches = true;
    refreshmap = true;
    
    return null;
  }

  public PageReference searchReset() {

    refreshmatches = true;
    refreshmap = true;
    
    return null;
  }
  
  public class ContactWrapper {
        public Contact theContact {get; set;}
        public Application__c theApplication {get; set;}
        public boolean isSelected {get; set;}
        public string matchlabel {get; set;}
        public string roleName {get; set;}
        public Id roleId {get; set;}
        public ContactWrapper(Contact inContact){
            theContact = inContact;
            isSelected = false;
        }
        public ContactWrapper(Application__c inApp){
            theApplication = inApp;
            isSelected = false;
        }
    }
    
    @IsTest(SeeAllData=true)
    private static void testController(){
        Profile saProfile = [select p.Id from Profile p where Name = 'System Administrator' LIMIT 1];
        Profile vProfile = [select p.Id from Profile p where Name = 'Community Login User - Volunteers' LIMIT 1];
        List<User>userList = [select u.Id from User u where u.IsActive = true and u.ProfileId = :saProfile.Id LIMIT 2];
        RecordType volunteerRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_VOLUNTEER);
        List<User>volunteerList = [select u.Id, u.ContactId from User u where u.ProfileId = :vProfile.Id and IsActive = true and u.Contact.RecordTypeId = :volunteerRT.Id];
        Contact volunteerContact = TestUtilities.getContactRecord(volunteerList[0].ContactId);
        if (volunteerContact.FirstName == null) volunteerContact.FirstName = 'Test';
        if (volunteerContact.LastName == null) volunteerContact.LastName = 'Contact';
        if (volunteerContact.Email == null) volunteerContact.Email = volunteerContact.FirstName.toLowerCase() + '.' + volunteerContact.LastName.toLowerCase() + '@myemail.com';
        if (volunteerContact.MailingStreet == null) volunteerContact.MailingStreet = '123 Fake Street';
        if (volunteerContact.MailingCity == null) volunteerContact.MailingCity = 'London';
        if (volunteerContact.MailingState == null) volunteerContact.MailingState = 'London';
        if (volunteerContact.MailingPostalCode == null) volunteerContact.MailingPostalCode = 'EC12 1PR';
        if (volunteerContact.Phone == null) volunteerContact.Phone = '02071111111';
        volunteerContact.Status__c = 'Active';
        if (volunteerContact.RecordTypeId == null) volunteerContact.RecordTypeId = volunteerRT.Id;
        volunteerContact.Holiday__c = false;
        update volunteerContact;
        
        User volunteerMgr = userList[0];
        User volunteerCoord = userList[1];
        //Create the Customer Request
        Contact customerContact = TestUtilities.getCustomerContact();
        insert customerContact;
        
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
            
        Customer_Requests__c customerRequest = TestUtilities.getCustomerRequest();
        customerRequest.Customer_Name__c = customerContact.Id;
        customerRequest.OwnerId = volunteerCoord.Id;
        insert customerRequest;
        
        Application__c application = TestUtilities.getApplication(volunteerContact.Id);
        application.Volunteer_Coordinator__c = volunteerCoord.Id;
        application.Volunteer_Manager__c = volunteerMgr.Id;
        application.Role__c = roleOpp.Id; 
        application.Applicant__c = volunteerContact.Id;
        
        insert application;
        
        application = [Select a.Applicant__c, a.Applicant__r.Skills__c, a.Applicant__r.Salutation, a.Applicant__r.RecordTypeId, a.Applicant__r.MobilePhone, a.Applicant__r.MailingStreet, a.Applicant__r.MailingState, a.Applicant__r.MailingPostalCode, a.Applicant__r.MailingCountry, 
                        a.Applicant__r.MailingCity, a.Applicant__r.LastName, a.Applicant__r.Id, a.Applicant__r.FirstName, a.Applicant__r.Holiday__c, a.Applicant__r.Email, a.Applicant__r.Availability__c, a.Applicant__r.OwnerId, a.Applicant__r.Location__Longitude__s, a.Applicant__r.Location__Latitude__s, 
                        a.Id, a.Role_Title__c FROM Application__c a WHERE a.Id = :application.Id]; 
        
        ApexPages.standardController std = new ApexPages.StandardController(customerRequest);
        PageReference testPage = Page.VolunteerMatching;
        testPage.getParameters().put('cr',customerRequest.Id);
        test.setCurrentPage(testPage);
        
        system.debug('*** -- Volunteer Contact RecordID = ' + volunteerContact.RecordTypeId + ' -- ***');
        system.debug('*** -- Applicant__r.RecordTypeId = ' + application.Applicant__r.RecordTypeId + ' -- ***');
        system.debug('*** -- Applicant__r.RecordTypeId = ' + application.Applicant__r.Holiday__c + ' -- ***');
        system.debug('*** -- Volunteer Coordinator = ' + volunteerCoord.Id + ' -- ***');
          
        
        test.startTest();
        List<Application__c> appList = [select a.Applicant__c, a.Applicant__r.Skills__c, a.Applicant__r.Salutation, a.Applicant__r.RecordTypeId, a.Applicant__r.MobilePhone, a.Applicant__r.MailingStreet, 
                                        a.Applicant__r.MailingState, a.Applicant__r.MailingPostalCode, a.Applicant__r.MailingCountry, a.Applicant__r.MailingCity, a.Applicant__r.LastName, a.Applicant__r.Id, a.Applicant__r.FirstName, 
                                        a.Applicant__r.Email, a.Applicant__r.Availability__c, a.Applicant__r.OwnerId, a.Applicant__r.Location__Longitude__s, a.Applicant__r.Location__Latitude__s, a.Id, 
                                        a.Role_Title__c FROM Application__c a 
                                        WHERE a.Status__c = 'Active' AND a.Applicant__r.RecordTypeId = :application.Applicant__r.RecordTypeId AND a.Volunteer_Coordinator__c = :volunteerCoord.Id AND a.Applicant__r.Holiday__c = false LIMIT 26];
                                        
        system.debug('*** -- appList = ' + appList.size() + ' -- ***');                                             
                                        
        system.debug('*** -- Into Test - about to create controller -- ***');
        VolunteerMatchingController vmc = new VolunteerMatchingController(std);
        List<SelectOption> distanceChoices = vmc.distanceChoices;
        List<SelectOption> serviceChoices = vmc.serviceChoices;
        boolean refreshMatches = vmc.refreshmatches;
        boolean refreshMap = vmc.refreshmap;
        boolean shortListMap = vmc.shortlistmap;
        List<VolunteerMatchingController.ContactWrapper> matches = vmc.matches;
        system.debug('*** -- vmc.matches.size = ' + vmc.matches.size() + ' -- ***');
        system.debug('*** -- matches.size = ' + matches.size() + ' -- ***');
        
        for (VolunteerMatchingController.ContactWrapper cw : matches){
            cw.isSelected = true;
        }
        vmc.matches = matches;
        vmc.sendEmailNotification();
        String mapHTML = vmc.maphtml;
        
            
        test.stopTest();
                
    }

}