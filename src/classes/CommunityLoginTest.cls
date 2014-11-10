/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class CommunityLoginTest {
    @IsTest(SeeAllData=false) global static void loginTest () {
        // Instantiate a new controller with all parameters in the page
        CommunityLogin controller = new CommunityLogin ();
        controller.emailAddress = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null); 
        
        CommunityLogin controller2 = new CommunityLogin ();
        controller2.emailAddress = '';
        controller2.password = ''; 
                
        System.assertEquals(controller2.login(),null);                           
    }    
}