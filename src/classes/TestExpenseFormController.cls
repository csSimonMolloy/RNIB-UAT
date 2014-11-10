/**
* 2014-04-04 : SM : This is the test class for ExpenseFormController
*/
@isTest(SeeAllData=true)
private class TestExpenseFormController {

    static testMethod void testController() {
    	RecordType volunteerRT = [select r.Id from RecordType r where r.DeveloperName = 'Volunteer' and r.SObjectType = 'Contact' LIMIT 1];
    	RecordType roleRT = [select r.Id from RecordType r where r.DeveloperName = 'Role' and r.SObjectType = 'Application__c' LIMIT 1];
    	RecordType tdRT = [select r.Id from RecordType r where r.DeveloperName = 'Individual_Time_Donation' and r.SObjectType = 'Time_Donation__c' LIMIT 1];
    	
        //We need to get the data we need and run as the right user
        Application__c application = [select a.Id, a.Applicant__c from Application__c a where a.RecordTypeId = :roleRT.Id and a.Status__c = 'Active' ORDER BY CreatedDate DESC LIMIT 1];
        User applicantUser = [select u.Id, u.ContactId from User u where u.ContactId = :application.Applicant__c LIMIT 1];
        
        PageReference testPage = Page.ExpenseForm;
        
        test.setCurrentPage(testPage);
        
        Expense_Form__c expenseForm = new Expense_Form__c();	
        expenseForm.Volunteer_Role__c = application.Id;
        expenseForm.Date__c = Date.today();
        
        ApexPages.StandardController std = new ApexPages.StandardController(expenseForm);
        ExpenseFormController controller = new ExpenseFormController(std);
        
        PageReference savePage = controller.saveAndNew(); 
        
        system.runAs(applicantUser){
        	PageReference testPage1 = Page.ExpenseForm;
        
	        test.setCurrentPage(testPage1);
	        
	        Expense_Form__c expenseForm1 = new Expense_Form__c();	
	        expenseForm1.Volunteer_Role__c = application.Id;
	        expenseForm1.Date__c = Date.today();
	        
	        ApexPages.StandardController std1 = new ApexPages.StandardController(expenseForm1);
	        ExpenseFormController controller1 = new ExpenseFormController(std1);
	        
	        PageReference savePage1 = controller1.saveAndNew();
        }
        
    }
}