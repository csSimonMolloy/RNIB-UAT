/*
* 2014-01-31 : SM : Test class for the VolunteerLandingPageController
 */
@isTest(SeeAllData=true)
public class TestVolunteerLandingPageController {

    static testMethod void testController() {
        Profile saProfile = [select p.Id from Profile p where Name = 'System Administrator' LIMIT 1];
        Profile vProfile = [select p.Id from Profile p where Name = 'Community Login User - Volunteers' LIMIT 1];
        List<User>userList = [select u.Id from User u where u.IsActive = true and u.ProfileId = :saProfile.Id LIMIT 2];
        List<User>volunteerList = [select u.Id, u.ContactId from User u where u.ProfileId = :vProfile.Id and IsActive = true];
        Contact volunteerContact = TestUtilities.getContactRecord(volunteerList[0].ContactId);
        if (volunteerContact.FirstName == null) volunteerContact.FirstName = 'Test';
        if (volunteerContact.LastName == null) volunteerContact.LastName = 'Contact';
        if (volunteerContact.Email == null) volunteerContact.Email = volunteerContact.FirstName.toLowerCase() + '.' + volunteerContact.LastName.toLowerCase() + '@myemail.com';
        if (volunteerContact.MailingStreet == null) volunteerContact.MailingStreet = '123 Fake Street';
        if (volunteerContact.MailingCity == null) volunteerContact.MailingCity = 'London';
        if (volunteerContact.MailingState == null) volunteerContact.MailingState = 'London';
        if (volunteerContact.MailingPostalCode == null) volunteerContact.MailingPostalCode = 'EC12 1PR';
        if (volunteerContact.Phone == null) volunteerContact.Phone = '02071111111';
        volunteerContact.Areas_of_Interest__c = 'Admin';
        volunteerContact.Region__c = 'North West';
        update volunteerContact;
        
        User volunteerMgr = userList[0];
        User volunteerCoord = userList[1];
        RecordType standardRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_STANDARD);
        Role_Opportunity__c roleOpp = TestUtilities.getRoleOpportunity(TestUtilities.RT_STANDARD, standardRT.Id);
        roleOpp.Volunteer_Manager__c = volunteerMgr.Id;
        roleOpp.Volunteer_Coordinator__c = volunteerCoord.Id;
        roleOpp.Role_involve_working_with_Children__c = 'No';
        roleOpp.Number_of_References_Required__c = '2';
        roleOpp.Active_on_Website__c = true;
        roleOpp.Status__c = 'Approved';
        roleOpp.Risk_Assessment__c = true;
        insert roleOpp;
        
        
        RecordType appRT = TestUtilities.getRecordTypeMap().get(TestUtilities.RT_APPLICATION);
        Application__c application = new Application__c(RecordTypeId = appRT.Id);
        
        application.Applicant__c = volunteerContact.Id;
        
        
        application.Role__c = roleOpp.Id;
        insert application;
        
        test.startTest();
        
        system.runAs(volunteerList[0]){
            VolunteerLandingPageController vlpc = new VolunteerLandingPageController();
            String COMMUNITY_ID = vlpc.COMMUNITY_ID;
            String GROUP_ID = vlpc.GROUP_ID;
            list<CollaborationGroup> cg = [select c.Id from CollaborationGroup c where c.Name = 'Volunteer Community' LIMIT 1];
            //System.debug('@@@@ Collaboration Group Id'+cg.id);
            String groupId = (cg.size() == 0 ? GROUP_ID : cg[0].Id);
            ConnectAPI.FeedItemPage result = new ConnectAPI.FeedItemPage();
            //ConnectAPI.ChatterFeeds.getFeedItemsFromFeed(COMMUNITY_ID, ConnectApi.FeedType.Record, groupId, 0, ConnectApi.FeedDensity.AllUpdates, null, 1, ConnectApi.FeedSortOrder.CreatedDateDesc)
            ConnectAPI.ChatterFeeds.setTestGetFeedItemsFromFeed(COMMUNITY_ID, ConnectApi.FeedType.Record, groupId, 0, ConnectApi.FeedDensity.AllUpdates, null, 1, ConnectApi.FeedSortOrder.CreatedDateDesc, result);
            List<ConnectAPI.FeedItem> feedItemsTest = vlpc.getNewsFeedItems();
            
            List<Customer_Requests__c> customerRequests = vlpc.getCustomerRequests();
            
            List<VolunteerLandingPageController.ApplicationWrapper> applicationList = vlpc.getApplications();
            
            List<Application__c> currentRoles = vlpc.getCurrentRoles();
            
            List<Role_Opportunity__c> availableOpportunities = vlpc.getAvaliableOpportunities();
        }
        
        
        
        test.stopTest();
    }

}