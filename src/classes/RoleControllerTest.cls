@isTest
private class RoleControllerTest {

    static testMethod void RoleControllerTest() {

        date startdate = date.today();
        date enddate = date.today().addDays(30);

        //Create a Test Role Record
        Role_Opportunity__c Role = new Role_Opportunity__c();
            Role.Active_on_Website__c = TRUE;
            Role.Availability__c = 'Monday Mornings';
            Role.Capacity__c = 10;
            Role.DBS_Check_required__c = 'DBS Standard';
            Role.End_Date__c = startdate;
            Role.Interests__c = 'Playground';
            Role.Role_Title__c = 'Test Role';
            Role.Service__c = 'Service 1';
            Role.Skills__c = 'Attention to detail';
            Role.Start_Date__c = enddate;
            Role.Waiting_List__c = TRUE;
            Role.Location__c = 'North West';
            Role.Work_Location__c ='Home';
            Role.Number_of_References_Required__c = '2';
        insert Role;

        PageReference pg = Page.Roles;
            Test.setCurrentPage(pg);
                pg.getParameters().put('skills', 'Attention to detail');
                pg.getParameters().put('availability', 'Monday Mornings');
                pg.getParameters().put('interests', 'Playground');
                pg.getParameters().put('service', 'Service 1');  
                pg.getParameters().put('location', 'North West');   
                pg.getParameters().put('worklocation', 'Home' );

        RoleController controller=new RoleController();
            System.assertequals (controller.sortField, 'location');
            System.assert(controller.runSearch() == null);

        String testDebugSoql = controller.debugSoql;

        List<String> testlocations = new List<String>();
        testlocations = controller.locations;
        System.assertequals (testlocations[0], 'North West');

        List<String> testavailability = new List<String>();
        testavailability = controller.availability;
        System.assertequals (testavailability[0], 'Flexible');

        List<String> testinterests = new List<String>();
        testinterests = controller.interests;
        System.assertequals (testinterests[0], 'Admin');

        List<String> testservice = new List<String>();
        testservice = controller.service;
        System.assertequals (testservice[0], 'Service 1');

        List<String> testskills = new List<String>();
        testskills = controller.skills;
        System.assertequals (testskills[0], 'Ability to ask questions sensitively');
        
        List<String> testworklocation = new List<String>();
        testworklocation = controller.worklocation;
        System.assertequals (testworklocation[0], 'Home Based');        

        controller.sortField = 'Some invalid sort field';
        controller.runQuery();

    }

}