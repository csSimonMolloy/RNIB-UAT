/*
* 2014-01-31 : KS : Test class for the CourseBookingController
 */
@isTest(SeeAllData=true)
public class TestCoursesPageController {

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
        
        
        
        //insert Course1
        Course__c course1 = new Course__c(
        Name='Test Course 1'        
        );
        insert course1; 
        
        //insert Course2
        Course__c course2 = new Course__c(
        Name='Test Course 2'        
        );
        insert course2; 
        
        //insert Course Booking Booked
        Course_Booking__c coursebook = new Course_Booking__c(
        Person__c = volunteerContact.id,
        Course__c = course1.id,
        Status__c = 'Booked');
        insert coursebook;
        
        //insert Course Booking Attended
        Course_Booking__c courseatt = new Course_Booking__c(
        Person__c = volunteerContact.id,
        Course__c = course2.id,
        Status__c = 'Attended');
        insert courseatt;
        
        test.startTest();
        
        system.runAs(volunteerList[0]){
            CoursesPageController cbc = new CoursesPageController();
            //Course Booking Attending
            List<Course_Booking__c> coursebooking = cbc.getCoursesBooking();
            
            //Course Booking Attended
            List<Course_Booking__c> completecoursebooking = cbc.getCompleteCoursesBooking();
        }
        
        
        
        test.stopTest();
    }

}