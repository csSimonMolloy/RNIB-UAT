/**
* 2014-04-04 : SM : This is the test class for TimeDonationController
*/
@isTest(SeeAllData=true)
private class TestTimeDonationController {

    static testMethod void testController() {
    	RecordType volunteerRT = [select r.Id from RecordType r where r.DeveloperName = 'Volunteer' and r.SObjectType = 'Contact' LIMIT 1];
    	RecordType roleRT = [select r.Id from RecordType r where r.DeveloperName = 'Role' and r.SObjectType = 'Application__c' LIMIT 1];
    	RecordType tdRT = [select r.Id from RecordType r where r.DeveloperName = 'Individual_Time_Donation' and r.SObjectType = 'Time_Donation__c' LIMIT 1];
    	
        //We need to get the data we need and run as the right user
        Application__c application = [select a.Id, a.Applicant__c from Application__c a where a.RecordTypeId = :roleRT.Id and a.Status__c = 'Active' ORDER BY CreatedDate DESC LIMIT 1];
        User applicantUser = [select u.Id, u.ContactId from User u where u.ContactId = :application.Applicant__c LIMIT 1];
        
        PageReference testPage = Page.TimeDonation;
        
        test.setCurrentPage(testPage);
        
        Time_Donation__c timeDonation = new Time_Donation__c();
        timeDonation.Volunteer_Name__c = application.Applicant__c;
        timeDonation.Volunteer_Role__c = application.Id;
        timeDonation.Name = 'Test Donation';
        timeDonation.RecordTypeId = tdRT.Id;
        
        ApexPages.StandardController std = new ApexPages.StandardController(timeDonation);
        TimeDonationController controller = new TimeDonationController(std);
        
        PageReference savePage = controller.saveAndNew(); 
        
        system.runAs(applicantUser){
        	PageReference testPage1 = Page.TimeDonation;
        
	        test.setCurrentPage(testPage1);
	        
	        Time_Donation__c timeDonation1 = new Time_Donation__c();
	        timeDonation1.Volunteer_Name__c = application.Applicant__c;
	        timeDonation1.Volunteer_Role__c = application.Id;
	        timeDonation1.Name = 'Test Donation';
	        timeDonation1.RecordTypeId = tdRT.Id;
	        
	        ApexPages.StandardController std1 = new ApexPages.StandardController(timeDonation1);
	        TimeDonationController controller1 = new TimeDonationController(std1);
	        
	        PageReference savePage1 = controller1.saveAndNew();
        }
        
    }
}