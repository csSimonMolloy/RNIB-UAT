/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 *
 * 2014-07-22 : CSL : Client requires automatic forwarding to an Application record after self registering.
 * As the code loses its session (due to validation email being sent out) we need to TEMPORARILY store 
 * the Application ID that comes in via the startURL onto the User record
 */
public with sharing class CommunitiesSelfRegController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    public String stURL {get; set {stURL = value == null ? value : value.trim();}}
    
    //2014-07-22 : CSL : Changing the constructor to get the startURL page parameter
    //public CommunitiesSelfRegController() {}
    
    public CommunitiesSelfRegController(){
        stURL = ApexPages.currentPage().getParameters().get('startURL');
    }
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        
        
        if (firstName != null && lastName != null){
            String commName = firstName.substring(0,1) + lastName.substring(0,3);
            DateTime dt = Datetime.now();
            communityNickname = commName + dt.millisecond();
        }
        
        system.debug('*** -- communityNickname = ' + communityNickname + ' -- ***');

        String profileId = '00e11000000QLM7'; //set to Community Login User - Applicants
        String roleEnum = '00Eb0000000gtOg';
        String accountId = '0011100000Bi0RN';
        
        String userName = email;

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
        u.ProfileId = profileId;
        //2014-07-22 : CSL : We now add the start URL to the User record
        //for retrieval and usage when they log in
        if (stURL != null){
        	u.Portal_Start_URL__c = stURL;
        }
        
        String userId;
        try {
            userId = Site.createPortalUser(u, accountId, password, true);
        }catch (Exception e){
            system.debug('*** -- Exception from createPortalUser = ' + e + ' -- ***');
        }
        
        system.debug('*** -- userId from createPortalUser = ' + userId + ' -- ***');
        
        
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(userName, password, null);
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}