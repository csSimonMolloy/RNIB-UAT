public class CorporateAccountTriggerMethods {

	public static void processAccount(List<Corporate_Account__c> inRecords){
		List<String> accountNameList = new List<String>();
		
		for (Corporate_Account__c ca : inRecords){
			accountNameList.add(ca.Name);
		}
		
		Map<String, Account> accountMap = new Map<String, Account>();
		Map<String, Account> newAccountMap = new Map<String, Account>();
		
		for (Account a : [select a.Id, a.Name from Account a where a.Name in :accountNameList]){
			accountMap.put(a.Name, a);
		}
		
		for (Corporate_Account__c ca : inRecords){
			Account theAccount = accountMap.get(ca.Name);
			
			if (theAccount != null){
				ca.Account__c = theAccount.Id;
			}else {
				Account newAccount = new Account();
				newAccount.Name = ca.Name;
				newAccount.Phone = ca.Phone__c;
				newAccount.BillingStreet = ca.Billing_Street__c;
				newAccount.BillingCity = ca.Billing_City__c;
				newAccount.BillingState = ca.Billing_State__c;
				newAccount.BillingCountry = ca.Billing_Country__c;
				newAccount.BillingPostalCode = ca.Billing_PostalCode__c;
				if (!newAccountMap.containsKey(newAccount.Name)){
					newAccountMap.put(newAccount.Name, newAccount);
				} 
			}
		}
		
		insert newAccountMap.values();
	}

}