public class ReferenceFormController {
	public final String REF_ID_PARAM = 'id';
	public final String CHILD_FLAG_PARAM = 'c';
	public final String MESSAGE_PARAM = 'm';
	public final String THANKYOU_MESSAGE = 'THANKYOU';
	public final String ALREADY_SUBMITTED_MESSAGE = 'ALREADYSUBMITTED';
	public Reference__c theReference {get; set;}
	public Role_Opportunity__c theRole {get; set;}
	public PageReference thankyouPage {get; set;}
	public boolean showAlreadySubmitted {get; set;}
	public boolean showThankyou {get; set;}
	public boolean showChildQuestion {get; set;}
	

	public ReferenceFormController(ApexPages.StandardController std){
		String whichMessage = ApexPages.currentPage().getParameters().get(MESSAGE_PARAM);
		String forChildren = ApexPages.currentPage().getParameters().get(CHILD_FLAG_PARAM);
		
		if (whichMessage != null){
			if (THANKYOU_MESSAGE.equalsIgnoreCase(whichMessage)){
				showThankyou = true;
				showAlreadySubmitted = false;
			}else if (ALREADY_SUBMITTED_MESSAGE.equalsIgnoreCase(whichMessage)){
				showThankyou = false;
				showAlreadySubmitted = true;
			}
		}
		
		if ('NO'.equalsIgnoreCase(forChildren)){
			showChildQuestion = false;
		}else {
			showChildQuestion = true;
		}
		
		Id refId = ApexPages.currentPage().getParameters().get(REF_ID_PARAM);
		
		if (refId != null){
			
			theReference = [Select r.Reference_Received__c, r.Application__r.Applicant__r.FirstName, r.Application__r.Applicant__r.LastName, r.Contact__r.Name, r.Contact__r.FirstName, r.Contact__r.LastName, 
							r.Contact__r.MailingStreet, r.Contact__r.MailingCity, r.Contact__r.MailingState, 
							r.Contact__r.MailingPostalCode,	r.Recommend_To_RNIB__c, r.Contact__r.Email, r.Contact__r.Phone, 
							r.Recommend_To_RNIB_Comments__c, r.Further_Comments__c, r.Reliability__c, r.Relationships_with_others__c, r.In_what_capacity_do_you_know_this_person__c, 
							r.How_long_have_you_known_the_above_named__c, r.Honesty_integrity_Ability_to_maintain_co__c, r.Ability_to_perform_role__c, 
							r.Ability_to_follow_policies_and_procedure__c, r.Suitable_to_Volunteer_with_Children__c,
							r.Application__r.Role_Title__c, r.Application__r.Role_Description__c, r.Application__r.Role__r.What_will_I_be_doing2__c,
							r.Application__r.Role__r.What_will_I_be_doing__c, r.Application__r.Role__r.Skills__c From Reference__c r where r.Id = :refId];
							
		}			
	
				
	}
	
	public PageReference doSubmit(){
		PageReference returnPage;
		if (theReference != null){
			theReference.Reference_Received__c = true;
			update theReference;
		}
		returnPage = Page.ReferenceThankyou;
		returnPage.getParameters().put(MESSAGE_PARAM, THANKYOU_MESSAGE);
		returnPage.setRedirect(true);
		return returnPage;
	}
	
	public PageReference checkForSubmitted(){
		PageReference thankyouPage = Page.ReferenceThankyou;
		if (theReference != null){
			if (theReference.Reference_Received__c){
				thankyouPage.getParameters().put(MESSAGE_PARAM, ALREADY_SUBMITTED_MESSAGE);
				thankyouPage.setRedirect(true);
				return thankyouPage;		
			}else{
				return null;	
			}
		}
		return null;
		
	}

}