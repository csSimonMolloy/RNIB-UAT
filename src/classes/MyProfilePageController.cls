/* An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private boolean isEdit = false;

    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email, contact.firstName, contact.lastName,
                contact.MailingCity, contact.MailingCountry, contact.MailingPostalCode, contact.MailingState, contact.MailingStreet, contact.Phone, contact.HomePhone,
                contact.Preferred_reading_correspondence_format__c, contact.Preferred_communications_channel__c, contact.Reasons_for_Wishing_to_Retire__c, contact.Data_Protection__c, contact.Request_to_Retire__c,contact.Holiday__c, contact.Region__c, contact.MobilePhone, contact.OtherPhone, contact.Areas_of_Interest__c,
                contact.Is_Access_Technology_Required__c , contact.If_Yes_Contact__c, contact.If_Other__c
                FROM User
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }

    public Boolean getIsEdit() {
        return isEdit;
    }

    public void edit() {
        isEdit=true;
    }

    public void save() {
        if (user.contact != null) {
            //setContactFields(user.contact, user);
            setUserFields(user.contact, user);
        }

        try {
            if (user.contact != null){
                update user.contact;
            }
            
            update user;

            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference contactOnHoliday(){
        if (user.contact != null){
            user.contact.Holiday__c = true;
            update user.contact;
             user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email, contact.firstName, contact.lastName,
                contact.MailingCity, contact.MailingCountry, contact.MailingPostalCode, contact.MailingState, contact.MailingStreet, contact.Phone, contact.HomePhone,
                contact.Preferred_reading_correspondence_format__c, contact.Preferred_communications_channel__c, contact.Reasons_for_Wishing_to_Retire__c, contact.Data_Protection__c, contact.Request_to_Retire__c,contact.Holiday__c, contact.Region__c, contact.MobilePhone, contact.OtherPhone, contact.Areas_of_Interest__c,
                contact.Is_Access_Technology_Required__c , contact.If_Yes_Contact__c, contact.If_Other__c
                FROM User
                WHERE id = :UserInfo.getUserId()];
        }
        return null;
    }
    
    public PageReference contactNotOnHoliday(){
        if (user.contact != null){
            user.contact.Holiday__c = false;
            update user.contact;
             user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email, contact.firstName, contact.lastName,
                contact.MailingCity, contact.MailingCountry, contact.MailingPostalCode, contact.MailingState, contact.MailingStreet, contact.Phone, contact.HomePhone,
                contact.Preferred_reading_correspondence_format__c, contact.Preferred_communications_channel__c, contact.Reasons_for_Wishing_to_Retire__c, contact.Data_Protection__c, contact.Request_to_Retire__c,contact.Holiday__c, contact.Region__c, contact.MobilePhone, contact.OtherPhone, contact.Areas_of_Interest__c,
                contact.Is_Access_Technology_Required__c , contact.If_Yes_Contact__c, contact.If_Other__c
                FROM User
                WHERE id = :UserInfo.getUserId()];
        }
        return null;
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public void cancel() {
        isEdit=false;
         user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email, contact.firstName, contact.lastName,
                contact.MailingCity, contact.MailingCountry, contact.MailingPostalCode, contact.MailingState, contact.MailingStreet, contact.Phone, contact.HomePhone,
                contact.Preferred_reading_correspondence_format__c, contact.Preferred_communications_channel__c, contact.Reasons_for_Wishing_to_Retire__c, contact.Data_Protection__c, contact.Request_to_Retire__c,contact.Holiday__c, contact.Region__c, contact.MobilePhone, contact.OtherPhone, contact.Areas_of_Interest__c,
                contact.Is_Access_Technology_Required__c , contact.If_Yes_Contact__c, contact.If_Other__c
                
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }

    public static void setContactFields(Contact c, User u) {
        c.title = u.title;
        c.firstname = u.firstname;
        c.lastname = u.lastname;
        c.email = u.email;
        c.phone = u.phone;
        c.mobilephone = u.mobilephone;
        c.fax = u.fax;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;
    }
    
    public static void setUserFields(Contact c, User u) {
        u.firstname = c.firstname;
        u.lastname = c.lastname;
        u.phone = c.phone;
        u.street = c.mailingstreet;
        u.city = c.mailingcity;
        u.state = c.mailingstate;
        u.postalcode = c.mailingpostalcode;
        u.country = c.mailingcountry;
    }
}