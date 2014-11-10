public with sharing class CustomerRequest {

    public String Activity {get; set;}
    public String Device {get; set;}
    public String Services {get; set;}
    public String Description {get; set;}
    public String Any_other_comments {get; set;}

    public String ReferralType {get; set;}

    public Contact contact {get; private set;} 
    public String salutation {get; set;}   
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String Street {get; set;}
    public String Street2 {get; set;}    
    public String City {get; set;}
    public String County {get; set;}
    public String Postcode {get; set;}    
    public String Country {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String mobilephone {get; set;}

    public boolean isReferral {get; set;}
    
    public Contact referral {get; private set;} 
    public String referralfirstname {get; set;}
    public String referrallastname {get; set;}
    public String referralorganisation {get; set;}
    public String referralStreet {get; set;}
    public String referralStreet2 {get; set;}    
    public String referralCity {get; set;}
    public String referralCounty {get; set;}
    public String referralPostcode {get; set;}    
    public String referralCountry {get; set;}
    public String referralemail {get; set;}
    public String referralphone {get; set;}
    public boolean adviseReferrer {get; set;}
    public List<Contact> contactList {get; set;}
    public Contact theCustomer {get; set;}
    
    public Customer_Requests__c theRequest {get; set;}


    // use apex describe to build the picklist values

    public List<SelectOption> getSalutationList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.Salutation;
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }

    public List<SelectOption> getServiceList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Customer_Requests__c.Service__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }

    public List<SelectOption> getActivityList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Customer_Requests__c.Activity__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             options.add(new SelectOption('NULL','-None-'));
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }

    public List<SelectOption> getDeviceList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Customer_Requests__c.Device__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }

    public List<SelectOption> getReferralTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Customer_Requests__c.Refer_Type__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }


    public CustomerRequest(){
        contactList = new List<Contact>();
        if (email == null || email == ''){
        	contactList = [select c.LastName, c.Email from Contact c where c.LastName = :lastName and c.MailingPostalCode = :Postcode];
        }else {
        	contactList = [select c.LastName, c.Email from Contact c where c.LastName = :lastName and c.Email = :email];	
        }
        //Need to build on this to have an if statement for contacts that already exist.
        

        if (contactList.size() == 0){
            theCustomer = new Contact();

        }
            
    }


    // save button is clicked
    public PageReference save() {
        //if (ReferralCheckbox = null) isReferral = false;

        //2013-11-29 : SM : We should restrict the returned record type by Object and LIMIT 1
        //In case there are record types with the same name for different objects
        //AND there is some confusion over record types - which one is for CUSTOMER and which one is for REFERRER?
        RecordType contactRecType = [select Id from RecordType where Name='Applicant' and SObjectType = 'Contact' LIMIT 1];
        //RecordType referenceRecType = [select Id from RecordType where Name='Reference / Counter Signatory' and SObjectType = 'Contact' LIMIT 1];
        RecordType referenceRecType = [select Id from RecordType where Name='Counter signatory' and SObjectType = 'Contact' LIMIT 1];
        RecordType referrerRecType = [select Id from RecordType where Name='Referrer' and SObjectType = 'Contact' LIMIT 1];
        RecordType customerRecType = [select Id from RecordType where Name='Customer' and SObjectType = 'Contact' LIMIT 1];
        RecordType requestRecType = [select Id from RecordType where Name='Customer Requests- Internal' and SObjectType = 'Customer_Requests__c' LIMIT 1];
        List<Contact> referrerList = new List<Contact>();

        if (contactList.size() == 0){
        	theCustomer.Salutation = salutation;
            theCustomer.FirstName = firstName;
            theCustomer.LastName = lastName;
            theCustomer.Email = email;
            theCustomer.HomePhone = phone;
            theCustomer.MobilePhone = mobilephone;
            theCustomer.MailingStreet = street + '\r\n' + street2;
            theCustomer.MailingCity = city;
            theCustomer.MailingState = county;
            theCustomer.MailingPostalCode = postcode;
            theCustomer.MailingCountry = 'United Kingdom';
            theCustomer.RecordTypeId = customerRecType.id;
            insert theCustomer;
        }else {
            theCustomer = contactList[0];
        }

        Contact theReferrer;
        if (isReferral){
            //Need to Add back in once isReferral Checkbox added to form
            if (referralemail == null || referralemail == ''){
            	referrerList = [select c.LastName, c.Email from Contact c where c.LastName = :referrallastname and c.MailingPostalCode = :referralPostcode];
            }else {
            	referrerList = [select c.LastName, c.Email from Contact c where c.LastName = :referrallastname and c.Email = :referralemail];	
            }
            
            if (referrerList.size() == 0){
                theReferrer = new Contact();
                theReferrer.FirstName = referralfirstname;
                theReferrer.LastName = referrallastname;
                theReferrer.Referrer_Organisation__c = referralorganisation;
                theReferrer.Email = referralemail;
                theReferrer.HomePhone = referralphone;
                theReferrer.MailingStreet = referralstreet + '\r\n' + referralstreet2;
                theReferrer.MailingCity = referralcity;
                theReferrer.MailingState = 'United Kingdom';
                theReferrer.MailingPostalCode = referralpostcode;
                theReferrer.MailingCountry = referralcountry;
                theReferrer.RecordTypeId = referrerRecType.id;  
            
                insert theReferrer;
            
            }else {
                theReferrer = referrerList[0];
            }
        }
               
        //create Customer Reference with link to Customer and Referrer
        theRequest = new Customer_Requests__c();
        theRequest.Customer_Name__c = theCustomer.id; 
        if (isReferral){
            //Need to Add back in once isReferral Checkbox added to form
            theRequest.Referral_Contact_Name__c = theReferrer.Id;
            theRequest.Advise_Referrer_of_Outcome__c = adviseReferrer;
        }
        theRequest.Customer_Request_Origin__c = 'Web';
        theRequest.Service__c = 'Technology Support';
        theRequest.Status__c = 'New';
        theRequest.Description__c = Description;
        theRequest.Any_other_comments__c = Any_other_comments;
        theRequest.Refer_Type__c = ReferralType;
        theRequest.Activity__c = Activity;
        theRequest.Device__c = Device;
        theRequest.Referral__c = isReferral;
        theRequest.RecordTypeId = requestRecType.id;
        
        insert theRequest;

        PageReference pageRef;
        //pageRef = new PageReference('http://www.rnib.org.uk');
        pageRef = Page.CustomerRequestThankyou;
        pageRef.setRedirect(true);
        return pageRef; 
        
   }

}