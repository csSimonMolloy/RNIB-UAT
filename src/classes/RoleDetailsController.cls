/*
* 2014-02-05 : SM : Updating this class so that we also bring back applications against the role
* so we can only show the Apply button if they haven't applied already.
*/
public class RoleDetailsController{


    public final String STATUS_WITHDRAWN = 'Withdrawn';
    private Role_Opportunity__c role;
    
    /*
    public boolean showApply {
        get {
            if (showApply == null){
                showApply = true;
            }
            return showApply;
        }
        set;
    }
    */
    public boolean showApply {get; set;}
    public String appliedDate {get; set;}
    
    public Role_Opportunity__c getRoleDetails(){
    User currentUser = [select u.Id, u.ContactId from User u where u.Id = :UserInfo.getUserId() LIMIT 1];
    

        if(role != null)
            return role;
            
        String id = ApexPages.currentPage().getParameters().get('id');
        if( id == null)
            return new Role_Opportunity__c();
    

        List<Role_Opportunity__c> roles = [Select r.Work_Location__c, r.Withdrawn_Reason__c, r.What_will_I_gain_from_the_role__c,r.What_will_I_be_doing__c, r.What_will_I_be_doing2__c,
                                        r.What_support_will_I_be_given__c, r.What_skills_and_qualities_required__c, r.Welcome_Pack__c, r.Waiting_List__c, r.Volunteer_Manager__c, 
                                        r.Volunteer_Coordinator__c, r.Vehicle_Training_Required__c, r.Vehicle_Check_Required__c, r.Status__c, r.Start_Date__c, r.Skills__c, r.Strategic_Priority__c,
                                        r.Service__c, r.Role_Type__c, r.Role_Title__c, r.Role_Description__c, r.Risk_Assessment__c, r.RecordTypeId, r.RNIB_Group__c, r.OwnerId, r.Other_Sources__c, 
                                        r.Opportunity_Family__c, r.Number_of_Successful_Applicants__c, r.Number_of_Spaces_Left__c, r.Number_of_Applications__c, r.Name, r.Location__c, 
                                        r.Interests__c, r.Induction_Call_Required__c, r.If_not_why_not__c, r.Id, r.Hours_per_week__c, r.End_Date__c, r.End_Date_Minus_7_Days__c, 
                                        r.Do_you_want_your_opportunity_advertised__c, r.Date_Submitted_for_Approval__c, r.Date_Approved__c, r.DBS_Check_required__c, r.Criminal_Record_Check_advertised__c, 
                                        r.Capacity__c, r.Budget_Available__c, r.Availability__c, r.Advertise_Role__c, r.Additional_Location_Information__c, 
                                        r.Active_on_Website__c, (Select Id, Applicant__c, CreatedDate From Applications__r where Status__c != :STATUS_WITHDRAWN) 
                                        From Role_Opportunity__c r where r.Role_Title__c != null AND r.Active_on_Website__c= true AND Id = :id];
        if(roles.isEmpty())
            return new Role_Opportunity__c();
            
        role = roles[0];
        showApply = true;
        for (Application__c a : role.Applications__r){
            if (a.Applicant__c == currentUser.ContactId){
            	system.debug('*** -- This person has already applied -- ***');
                showApply = false;
                appliedDate = a.CreatedDate.format();
                break;
            }
        }
        system.debug('*** -- showApply = ' + showApply + ' -- ***');
        return role;

    }
       
    

}