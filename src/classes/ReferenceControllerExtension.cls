public class ReferenceControllerExtension {
    
    public final String EMAIL_NON_CHILD_TEMPLATE = 'Volunteer_Recruitment_Reference_Email';
    public final String EMAIL_CHILD_TEMPLATE = 'Volunteer_Recruitment_Reference_Email_Children';
    public final String EMAIL_NON_CHILD_NO_CHECK_TEMPLATE = 'Volunteer_Recruitment_Reference_Email_No_Check';
    public final String REF_TYPE_PARAM = 'Type';
    public final String REF_ID_PARAM = 'Id';
    
    public boolean isChildRelated {get; set;}
    public boolean isCriminalCheckRequired {get; set;}
    
    public EmailTemplate nonChildTemplate {get; set;}
    public EmailTemplate childTemplate {get; set;} 
    public EmailTemplate nonChildTemplateNoCheck {get; set;}
    
    public Id referenceId {get; set;}
    
    public boolean isEmail {
        get {
            if (isEmail == null){
                isEmail = false;
            }
            return isEmail;
        }
        set;
    }
    public boolean isLetter {
        get {
            if (isLetter == null){
                isLetter = false;
            }
            return isLetter;
        }
        set;
    }
    public Reference__c ref {get; set;}
    
    public ReferenceControllerExtension(ApexPages.StandardController std){
        referenceId = std.getId();
        String refType = ApexPages.currentPage().getParameters().get(REF_TYPE_PARAM);
        if ('EMAIL'.equalsIgnoreCase(refType)) isEmail = true;
        if ('LETTER'.equalsIgnoreCase(refType)) isLetter = true;
                
        ref = [select r.Id, r.Contact__c, r.Criminal_Record_Check_Required__c, r.Role_Involves_Working_With_Children__c from Reference__c r where r.Id = :referenceId LIMIT 1];
        
        if ('YES'.equalsIgnoreCase(ref.Role_Involves_Working_With_Children__c)){
            isChildRelated = true;
        }else {
            isChildRelated = false;
        }
        
        if ('No Check Required'.equalsIgnoreCase(ref.Criminal_Record_Check_Required__c)){
            isCriminalCheckRequired = false;
        }else {
            isCriminalCheckRequired = true;
        }
        
        nonChildTemplate = [select e.Id from EmailTemplate e where e.DeveloperName = :EMAIL_NON_CHILD_TEMPLATE and e.IsActive = true LIMIT 1];
        childTemplate = [select e.Id from EmailTemplate e where e.DeveloperName = :EMAIL_CHILD_TEMPLATE and e.IsActive = true LIMIT 1];
        nonChildTemplateNoCheck = [select e.Id from EmailTemplate e where e.DeveloperName = :EMAIL_NON_CHILD_NO_CHECK_TEMPLATE and e.IsActive = true LIMIT 1];
    }
    
    public PageReference autoForward(){
        system.debug('*** -- Into autoForward -- ***');
        String pageURL = '';
        PageReference pageRef;
        
        if (isCriminalCheckRequired){
            if (isChildRelated){
                system.debug('*** -- Is Child Related -- ***');
                //IS CHILD RELATED
                if (isEmail){
                    system.debug('*** -- Is Email -- ***');
                    pageURL = '/_ui/core/email/author/EmailAuthor?p2_lkid=' + ref.Contact__c + '&p3_lkid=' + ref.Id + '&retURL=/' + ref.Id + '&template_id=' + childTemplate.Id;
                    pageRef = new PageReference(pageURL);
                    pageRef.setRedirect(true);
                    return pageRef;
                }else if (isLetter){
                    system.debug('*** -- Is Letter -- ***');
                    pageRef = Page.Character_Reference_Children;
                    pageRef.getParameters().put(REF_ID_PARAM,referenceId);
                    pageRef.setRedirect(true);
                    return pageRef;
                    
                }
            }else {
                //IS NOT CHILD RELATED
                system.debug('*** -- Is Not Child Related -- ***');
                if (isEmail){
                    system.debug('*** -- Is Email -- ***');
                    //_ui/core/email/author/EmailAuthor?p2_lkid={!Reference__c.ContactId__c}&p3_lkid={!Reference__c.Id}&retURL=/{!Reference__c.Id}&template_id=00Xb0000000d9eG
                    pageURL = '/_ui/core/email/author/EmailAuthor?p2_lkid=' + ref.Contact__c + '&p3_lkid=' + ref.Id + '&retURL=/' + ref.Id + '&template_id=' + nonChildTemplate.Id;
                    pageRef = new PageReference(pageURL);
                    pageRef.setRedirect(true);
                    return pageRef;
                }else if (isLetter){
                    system.debug('*** -- Is Letter -- ***');
                    pageRef = Page.Character_Reference;
                    pageRef.getParameters().put(REF_ID_PARAM,referenceId);
                    pageRef.setRedirect(true);
                    return pageRef;
                }
            }   
        }else {
            if (isEmail){
                system.debug('*** -- Is Email -- ***');
                //_ui/core/email/author/EmailAuthor?p2_lkid={!Reference__c.ContactId__c}&p3_lkid={!Reference__c.Id}&retURL=/{!Reference__c.Id}&template_id=00Xb0000000d9eG
                pageURL = '/_ui/core/email/author/EmailAuthor?p2_lkid=' + ref.Contact__c + '&p3_lkid=' + ref.Id + '&retURL=/' + ref.Id + '&template_id=' + nonChildTemplateNoCheck.Id;
                pageRef = new PageReference(pageURL);
                pageRef.setRedirect(true);
                return pageRef;
            }else if (isLetter){
                system.debug('*** -- Is Letter -- ***');
                pageRef = Page.Character_Reference_No_Check;
                pageRef.getParameters().put(REF_ID_PARAM,referenceId);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        
        
        
        return null;
    }
    
}