/*
* 2014-02-21 : SM : This class will process all Application__c records created today, and if they are a Corporate type
* will create any necessary Account records, and associate the corresponding Applicant with them
*/
public class AccountCreation {

	public List<Account> newAccounts = new List<Account>();
	

	public AccountCreation(){
		List<Application__c> createdApplications = new List<Application__c>();
		Set<Id> contactIds = new Set<Id>();
		List<String> accountNameList = new List<String>();
		Map<String, Account> accountMap = new Map<String, Account>();
		Map<String, Account> accountCreatedMap = new Map<String, Account>();
		Map<String, Account> currentAccountsMap = new Map<String, Account>();
		Map<Id, Contact> contactUpdatedMap = new Map<Id, Contact>();
		
		//TODO : Waiting on WHERE clause for the Application selection statement
		createdApplications = [Select a.Id, a.Corporate_Account_Phone__c, a.Corporate_Account_Name__c, a.Corporate_Account_Billing_Street__c, 
							a.Corporate_Account_Billing_State__c, a.Corporate_Account_Billing_PostalCode__c, a.Corporate_Account_Billing_Country__c, 
							a.Corporate_Account_Billing_City__c, a.Applicant__c 
							From Application__c a where a.CreatedDate = Today
							and a.Corporate_Account_Name__c != null];
							
		if (createdApplications.size() > 0){
			//Build the data we need first
			for (Application__c a : createdApplications){
				contactIds.add(a.Applicant__c);
				accountNameList.add(a.Corporate_Account_Name__c);
			}
			
			Map<Id, Contact> contactMap = new Map<Id, Contact>([select c.Id, c.AccountId from Contact c where c.Id in :contactIds]);
			
			for (Account a : [select a.Id, a.Name from Account a where a.Name in : accountNameList]){
				accountMap.put(a.Name, a);
			}
			
			//Now we can process all the applications and setup the Accounts
			for (Application__c a : createdApplications){
				Account corpAccount = accountMap.get(a.Corporate_Account_Name__c);
				
				if (corpAccount == null){
					String accountName = (a.Corporate_Account_Name__c == null ? '' : a.Corporate_Account_Name__c);
		    		String accountPhone = (a.Corporate_Account_Phone__c == null ? '' : a.Corporate_Account_Phone__c);
		    		String accountBillingStreet = (a.Corporate_Account_Billing_Street__c == null ? '' : a.Corporate_Account_Billing_Street__c);
		    		String accountBillingCity = (a.Corporate_Account_Billing_City__c == null ? '' : a.Corporate_Account_Billing_City__c);
		    		String accountBillingState = (a.Corporate_Account_Billing_State__c == null ? '' : a.Corporate_Account_Billing_State__c);
		    		String accountBillingCountry = (a.Corporate_Account_Billing_Country__c == null ? '' : a.Corporate_Account_Billing_Country__c);
		    		String accountBillingPostalCode = (a.Corporate_Account_Billing_PostalCode__c == null ? '' : a.Corporate_Account_Billing_PostalCode__c);
					
					corpAccount = new Account();
					corpAccount.Name = accountName;
		    		corpAccount.Phone = accountPhone;
		    		corpAccount.BillingStreet = accountBillingStreet;
		    		corpAccount.BillingCity = accountBillingCity;
		    		corpAccount.BillingState = accountBillingState;
		    		corpAccount.BillingCountry = accountBillingCountry;
		    		corpAccount.BillingPostalCode = accountBillingPostalCode;
		    		if (!accountCreatedMap.containsKey(corpAccount.Name)){
		    			accountCreatedMap.put(corpAccount.Name, corpAccount);
		    		}		
				}else {
					if (!currentAccountsMap.containsKey(corpAccount.Name)){
						currentAccountsMap.put(corpAccount.Name, corpAccount);
					}
				}
			}
			
			if (accountCreatedMap.size() > 0){
				insert accountCreatedMap.values();
			}
			
			//Now we've created those accounts we need, we can assign them to the Applicant record
			for (Application__c a : createdApplications){
				Account corpAccount = accountCreatedMap.get(a.Corporate_Account_Name__c);
				//Not a newly created one, so get an existing one
				if (corpAccount == null) corpAccount = currentAccountsMap.get(a.Corporate_Account_Name__c);
				
				Contact applicant = contactMap.get(a.Applicant__c);
				
				if (corpAccount != null && applicant != null){
					applicant.AccountId = corpAccount.Id;		
				}
				
				if (!contactUpdatedMap.containsKey(applicant.Id)){
					contactUpdatedMap.put(applicant.Id, applicant);
				}
			}
			
			if (contactUpdatedMap.size() > 0){
				update contactUpdatedMap.values();
			}
		}
		
		
			
	}

}