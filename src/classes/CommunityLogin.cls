public with sharing class CommunityLogin {
    public final String EMPTY_FIELD_VALUE_MSG = 'Please enter your Password.  ';
    public final String INVALID_EMAIL_ADDRESS = 'The Username you have provided is not valid.  ';
    public final String LOGIN_FAILED = 'Your login attempt has failed. Make sure the username and password are correct.  ';

    public String emailAddress {get; set;}
    public String password {get; set;}

    public String standardErrorMsg {get;set;}
    public String emailAddressError {get; set;}
    public String passwordError {get; set;}

    private Boolean isError = FALSE;

    public PageReference login() {
      emailAddressError = '';
        passwordError = '';  
        standardErrorMsg = '';

      if (emailAddress.length() == 0) {
        emailAddressError = INVALID_EMAIL_ADDRESS;
        isError = TRUE;
      }

      if (password.length() == 0) {
        passwordError = EMPTY_FIELD_VALUE_MSG;
        isError = TRUE;
      }
      if (isError)
        return null;
        // We need to Redirect based on the user characteristics - Friend or Champion
        PageReference pr = null;
        
        Profile applicantProfile = [select Id from Profile where Name='Community Login User - Applicants' LIMIT 1];
        Profile volunteerProfile = [select Id from Profile where Name='Community Login User - Volunteers' LIMIT 1];

        String url = '/ApplicantLandingPage';

        try {

            User usercontact = [SELECT Id, contactId, ProfileId FROM USER WHERE email = :emailAddress LIMIT 1];
            
            if (usercontact.id != null && usercontact.profileId == volunteerProfile.id){

                    url = '/VolunteerLandingPage';
                }else{
                    url = '/ApplicantLandingPage';
            }

            pr = Site.login(emailAddress, password, url);   
        } catch (Exception e) {
          // DO SOMETHING
          standardErrorMsg = e.getMessage();
        }

        if (pr == null) {
          standardErrorMsg = LOGIN_FAILED;
          return null;
        }

      return Site.login(emailAddress, password, url);       
    }

    public CommunityLogin() {  
        standardErrorMsg = '';
        emailAddressError = '';
        passwordError = '';  
    }   
    

}