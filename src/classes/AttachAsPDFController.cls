public with sharing class AttachAsPDFController {

        public static Expense_Form__c obj;
        public string ParentId {get; set;}
        public string pdfName {get; set;}

        public AttachAsPDFController(ApexPages.StandardController stdController){
                obj = (Expense_Form__c)stdController.getRecord();
        }

        public PageReference attachMe(){
                
                if(ApexPages.currentPage().getParameters().containsKey('attachme'))
                        return null;

                PageReference prPDF = ApexPages.currentPage();
                prPDF.getParameters().put('attachme', '1');
        
                Blob b = Blob.valueOf('test');
                
                if(!Test.isRunningTest())
                   b = prPDF.getContentAsPDF();
                
                Attachment attach = new Attachment(Name=obj.Name +'.pdf', body=b, IsPrivate=false, ParentId=obj.Id);
                insert attach;
                
                PageReference pr = new pageReference('/' + obj.id);
                pr.setRedirect(true);
                return pr;
        }

}