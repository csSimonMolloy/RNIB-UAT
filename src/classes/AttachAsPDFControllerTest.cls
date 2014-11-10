@isTest
private class AttachAsPDFControllerTest {
	
  static Expense_Form__c expenseform;
 
  static {
 
    expenseform = new Expense_Form__c();
    expenseform.Date__c = Date.today();
    insert expenseform;
 
  }
 
  public static testMethod void AttachAsPDFControllerTest() {
 
 	ApexPages.StandardController std = new ApexPages.StandardController(expenseform);
    AttachAsPDFController con = new AttachAsPDFController(std); 

    PageReference pref = Page.Expense_Form;
    pref.getParameters().put('id',expenseform.id);
    Test.setCurrentPage(pref);

    Test.startTest();
    // populate the field with values
    //con.parentId = expenseform.id;
    //con.pdfName = 'My Test PDF';
 
    // submit the record
    pref = con.attachMe();
 
    // assert that they were sent to the correct page
    System.assertEquals(pref.getUrl(),'/'+expenseform.id);
 
    // assert that an attachment exists for the record
    System.assertEquals(1,[select count() from attachment where parentId = :expenseform.id]);
 
    Test.stopTest(); 
 
  }
}