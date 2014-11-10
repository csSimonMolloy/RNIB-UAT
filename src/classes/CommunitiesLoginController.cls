/**
 * An apex page controller that exposes the site login functionality
 * 2014-07-22 : CSL : We need to check the current user record for a Portal Start URL
 * If it has one, we need to forward to that startURL as it means we've come from 
 * a Self Registration
 */
global with sharing class CommunitiesLoginController {
    global User loggedInUser {get; set;} 

    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        Id userId = UserInfo.getUserId();
        if (userId != null){
            loggedInUser = [select u.Portal_Start_URL__c from User u where u.Id = :userId LIMIT 1];
        }
        
        String startURL;
        if (loggedInUser != null && loggedInUser.Portal_Start_URL__c != null){
            startURL = loggedInUser.Portal_Start_URL__c;
        }else {
            startUrl = System.currentPageReference().getParameters().get('startURL');
        }
        
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}