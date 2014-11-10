@isTest
private class CustomerRequestHelplineTest {
  
  static testMethod void testCustomerRequestHelpline(){

   Test.startTest();

   PageReference ref = new PageReference('/apex/CustomerRequest_Helpline'); 
   test.setCurrentPage(ref);
   
   // Create a individual account based on the queried account.
   
     Account a = new Account(Name='Individual');
        insert a; 

   //create CustomerRequest

   CustomerRequest_Helpline obj = new CustomerRequest_Helpline();
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
    
        system.assert(obj.save()!=null);

        CustomerRequest_Helpline controller = new CustomerRequest_Helpline();
        
        List<SelectOption> salutationList = controller.getSalutationList();
     	List<SelectOption> serviceList = controller.getServiceList();
     	List<SelectOption> activityList = controller.getActivityList();
     	List<SelectOption> deviceList = controller.getDeviceList();
     	List<SelectOption> referralTypeList = controller.getReferralTypeList();

   Test.stopTest();

  }
  
}