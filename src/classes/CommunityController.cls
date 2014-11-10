/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : Main APEX class for all Community* classes
 *        
 *  Author  : KS
 *  Date    : 03-04-2014
 *  Version : 1.0
 *
 *  Description:    CommunityController holds all methods / functionality that is common
 *          for all Community* classes.  Includes 'register' method which will 
 *          call out to the standard Site functionality  
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
global abstract class CommunityController {
  public static final String pageId_PARAM = 'pageId';
  public static final String USER_TYPE_CHAMPION = 'Champion';
  public static final String USER_TYPE_FRIEND = 'Friend';
  
  public static String pageId {
    get {
      return ApexPages.currentPage().getParameters().get(pageId_PARAM);
    }
  }

  public static final String showPreview_PARAM = 'preview';
  public static Boolean showPreview {
    get {
      Boolean showPreview = false;

      if (ApexPages.currentPage().getParameters().get(showPreview_PARAM) != null
        && ApexPages.currentPage().getParameters().get(showPreview_PARAM).equalsIgnoreCase('true')) {

        showPreview = true;
      }

      return showPreview;
    }
  }


  public static Boolean isLoggedIn {
    get {
      return (UserInfo.getUserType() == 'Guest' ? false : true);
    }
  }

  public static Boolean userAlreadyExists {
    get {
      if (userAlreadyExists == null){
        userAlreadyExists = false;
      }
      return userAlreadyExists;
    }
    set;
  }

  public static User thisUser {
    get {
      if (thisUser == null
          && isLoggedIn) {

        thisUser = [SELECT Id, Email, Username, AccountId, ContactId, firstName, lastName, title
                FROM User
                WHERE Id = :UserInfo.getUserId()];

      }

      return thisUser;
    }
    private set;
  }

  public static Id userAccountId {
    get {
      return (thisUser == null ? null : thisUser.AccountId);
    }
  }

  //public DF_Contact__c dfContact {get; set;}

  private static final String XUACompatible_PARAM = 'X-UA-Compatible';
  private static final String XUACompatible_VALUE = 'IE=edge';
  //Constructor
  public CommunityController() {
    //isChampion = false;
    system.debug('*** -- Into WEBController constructor -- ***');
    ApexPages.currentPage().getHeaders().put(XUACompatible_PARAM, XUACompatible_VALUE);

  }

  public PageReference loginRedirect() {
    PageReference returnReference;

    if (isLoggedIn == false) {
      returnReference = loginReference;
    }

    return returnReference;
  }

  public PageReference loginReference {
    get {
      PageReference loginReference = Page.CommunityLogin;
      loginReference.setRedirect(true);

      return loginReference;
    }
  }

  public String loginUrl {
    get {
      return loginReference.getUrl();
    }
  }

  public String homepageUrl {
    get {
      return Page.VolunteerLandingPage.getUrl();
    }
  }

  public static Boolean checkUserExists(String emailAddress) {
    List<User> users = [SELECT UserType
                FROM User
                WHERE Email = :emailAddress
                    AND IsActive = true];

    return (users.size() > 0);
  }

  //Registration method
  public static PageReference registerUser(String title, String firstName, String lastName, String telephone, String emailAddress, String password, String password2, String userType) {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!(password == password2)) {
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
          ApexPages.addMessage(msg);
            return null;
        }    
        //2014-03-28 : SM : We need to make sure that the user does not already exist before trying to create it
        
        List<User> checkUserList = new List<User>();
        checkUserList = [select u.Id from User u where u.Email = :emailAddress];
        if (checkUserList.size() > 0){
          //We already have this user
          userAlreadyExists = true;
          return null;
        }
        
        User u = new User();
        u.Username = emailAddress;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email = emailAddress;
        u.CommunityNickname = firstName+lastName;
        
        String accountId = '001b000000N8Loo';

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        //2014-03-27 : SM : We need to change the below code to 
        String userId = Site.createPortalUser(u, accountId, password, TRUE);
        //So that we send the user email
        //String userId = Site.createPortalUser(u, accountId, password);

        System.debug('*** User Created - ' + userId);

        if (userId != null) {
          String returnPageUrl; 
            if (password != null && password.length() > 1) {
              //We need to check which User Type, so we know which Dashboard to send the user back to
              if (USER_TYPE_FRIEND.equalsIgnoreCase(userType)){
                returnPageUrl = '/WEBFriend';
              }else if (USER_TYPE_CHAMPION.equalsIgnoreCase(userType)){
                returnPageUrl = '/WEBChampion';
              }
                return Site.login(emailAddress, password, returnPageURL);
            }
            else {
                //PageReference page = System.Page.SiteRegisterConfirm;
                //PageReference page = System.Page.WEBSiteRegisterConfirm;
                //2014-01-04 : SM : Request to redirect to Login screen on successful registration
                PageReference page = System.Page.CommunityLogin;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}