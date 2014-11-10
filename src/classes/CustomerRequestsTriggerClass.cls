/*
* 2014-01-14 : SM : New class to hold methods called from the CustomerRequestsTrigger
*/
public class CustomerRequestsTriggerClass {
    public static final String GVT_QUEUE_NAME = 'GVT Administrators';
    public static final String RT_INDIVIDUAL = 'Individual_Time_Donation';
    public static final String ACCEPTED_STATUS = 'Accepted';
    

    //This method will create a new Time Donation record, and an associated Time Donation Entry record if the Customer Request
    //Total_Number_of_Hours_Donated_to_Resolve__c is greater than 0 and the Customer Request is set to Closed - Approved
    public static void createTimeDonation(List<Customer_Requests__c> inRecords){
        
        RecordType timeDonationRT = [select r.Id, r.DeveloperName from RecordType r where r.SobjectType = 'Time_Donation__c' and r.DeveloperName = :RT_INDIVIDUAL and IsActive = true LIMIT 1];
        List<Time_Donation__c> newTDs = new List<Time_Donation__c>();
        Map<Id, Time_Donation__c> tdMap = new Map<Id, Time_Donation__c>();
        List<Time_Donation_Entry__c> newTDEs = new List<Time_Donation_Entry__c>();
        List<Time_Donation_Entry__c> updatedTDEs = new List<Time_Donation_Entry__c>();
        Map<String, Time_Donation__c> currentTDMap = new Map<String, Time_Donation__c>();
        Map<String, CR_Notification__c> crnMap = new Map<String, CR_Notification__c>();
        Set<String> tdNameList = new Set<String>();
        Set<Id> crIdSet = new Set<Id>();
        
        for (Customer_Requests__c cr : inRecords){
            String customerName = cr.Customer_Name__c;
            String tdName = cr.Name + ' ' + customerName.substring(0,15);
            crIdSet.add(cr.Id);
            tdNameList.add(tdName);
        }
        
        for (CR_Notification__c crn : [Select c.Volunteer_Role_ID__c, c.Status__c, c.Id, c.Customer_Request__c 
                                        From CR_Notification__c c where c.Customer_Request__c in :crIdSet and c.Status__c = :ACCEPTED_STATUS]){
            crnMap.put(crn.Customer_Request__c, crn);
        }
        
        for (Time_Donation__c td : [Select t.Customer_Request__c, t.Id, t.Name, (Select TIme_Donation__c, Date_Time_Donated__c, Time_Donated_in_Hours__c From Time_Donation_Entries__r) From Time_Donation__c t where t.Name in :tdNameList]){
            currentTDMap.put(td.Name, td);
        }
        
        for (Customer_Requests__c cr : inRecords){
            Time_Donation__c td;
            String customerName = cr.Customer_Name__c;
            String tdName = cr.Name + ' ' + customerName.substring(0,15);
            td = currentTDMap.get(tdName);
            if (td != null){
                tdMap.put(td.Customer_Request__c, td);
                Time_Donation_Entry__c tde = td.Time_Donation_Entries__r[0];
                if (tde.Time_Donated_in_Hours__c != cr.Total_Number_of_Hours_Donated_to_Resolve__c){
                    tde.Time_Donated_in_Hours__c = cr.Total_Number_of_Hours_Donated_to_Resolve__c;
                    updatedTDEs.add(tde);
                }
            }else {
                td = new Time_Donation__c(RecordTypeId = timeDonationRT.Id);
                td.Customer_Request__c = cr.Id;
                td.Name = cr.Name + ' ' + customerName.substring(0,15);
                td.Customer_Name__c = cr.Customer_Name__r.Name;
                td.Volunteer_Name__c = cr.Assigned_Volunteer__c;
                CR_Notification__c crn = crnMap.get(cr.Id);
                if (crn != null){
                    td.Volunteer_Role__c = crn.Volunteer_Role_ID__c;
                } 
                newTDs.add(td); 
            }
            
        }
        
        insert newTDs;
        
        for (Time_Donation__c td : newTDs){
            tdMap.put(td.Customer_Request__c, td);
        }
        
        //2014-09-11 : CSL : Changing this code slightly, to avoid the 'Null Pointer Exception' error
        for (Customer_Requests__c cr : inRecords){
            Time_Donation_Entry__c tde = new Time_Donation_Entry__c();
            Time_Donation__c td = tdMap.get(cr.Id);
            if (td != null){
                tde.Time_Donation__c = td.Id;
            }
            //tde.Time_Donation__c = tdMap.get(cr.Id).Id;
            tde.Time_Donated_in_Hours__c = cr.Total_Number_of_Hours_Donated_to_Resolve__c;
            newTDEs.add(tde);
        }
        
        insert newTDEs;
        
    }

    //This method will automatically assign the incoming Customer Request to the right Owner, based on Customer Request Assignment Rules
    public static void autoAssignCustomerRequest(List<Customer_Requests__c> inRequests){
        List<Id> primaryOwnerIdList = new List<Id>();
        List<Id> secondaryOwnerIdList = new List<Id>();
        Map<Id, User> primaryOwners = new Map<Id,User>();
        Map<Id, User> secondaryOwners = new Map<Id,User>();
        Id assignedUserId;
                
        Map<String, Customer_Request_Assignment_Rule__c> assignmentRulesMap = new Map<String, Customer_Request_Assignment_Rule__c>();
        for (Customer_Request_Assignment_Rule__c crar : [Select c.Service__c, c.Secondary_Owner__c, c.Primary_Owner__c, c.Post_Code__c, c.Id 
                                                            From Customer_Request_Assignment_Rule__c c]){
                                                                primaryOwnerIdList.add(crar.Primary_Owner__c);
                                                                secondaryOwnerIdList.add(crar.Secondary_Owner__c);
                                                                assignmentRulesMap.put(crar.Post_Code__c + '~' + crar.Service__c, crar);
                                                            }
        
        primaryOwners = new Map<Id, User>([select u.Id, u.Holiday__c from User u where u.Id in :primaryOwnerIdList]);
        secondaryOwners = new Map<Id, User>([select u.Id, u.Holiday__c from User u where u.Id in :secondaryOwnerIdList]);
        Group gvtQueue = [select g.Id, g.Name, g.Type from Group g where g.Name = :GVT_QUEUE_NAME and g.Type = 'Queue' LIMIT 1];    
        
        for (Customer_Requests__c cr : inRequests){
            String assignmentKey;
            if (cr.Customer_Post_Code__c != null){
                integer spaceInt = cr.Customer_Post_Code__c.indexOf(' ');
                String postCodeTrim = cr.Customer_Post_Code__c.substring(0,spaceInt).trim().toUpperCase();
                assignmentKey = postCodeTrim + '~' + cr.Service__c;
            }
            system.debug('*** -- assignmentKey = ' + assignmentKey + ' -- ***');
            if (assignmentKey != null){
                Customer_Request_Assignment_Rule__c crar = assignmentRulesMap.get(assignmentKey);
                if (crar != null){
                    User primaryUser = primaryOwners.get(crar.Primary_Owner__c);
                    User secondaryUser = secondaryOwners.get(crar.Secondary_Owner__c);
                    if (primaryUser != null){
                        if (!primaryUser.Holiday__c){
                            assignedUserId = primaryUser.Id;
                        }else {
                            if (secondaryUser != null){
                                if (!secondaryUser.Holiday__c){
                                    assignedUserId = secondaryUser.Id;
                                }
                            }
                        }
                    }else {
                        assignedUserId = gvtQueue.Id;
                    }
                    
                }else {
                    if (assignedUserId != null){
                        assignedUserId = gvtQueue.Id;
                    }
                }
                if (assignedUserId != null){
                    cr.OwnerId = assignedUserId;
                }
            }else {
                assignedUserId = gvtQueue.Id;
                cr.OwnerId = assignedUserId;
            }
            
        }   
        
            
    }       
    
}