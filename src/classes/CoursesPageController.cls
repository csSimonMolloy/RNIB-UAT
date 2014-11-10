public with sharing class CoursesPageController {
    
    public CoursesPageController() {
        
    }

    public List<Course_Booking__c> getCoursesBooking(){
        Id currentUserId = [select contactid from User where id = :UserInfo.getUserId()].contactid;

        List<Course_Booking__c> coursebooking = [Select c.id, c.Course__c, c.Person__c, c.Status__c, c.Course__r.id, c.course__r.Name, c.Course__r.Start_Date_Time__c, c.Course__r.End_Date_Time__c From Course_Booking__c c
                            where c.Person__r.id = :currentUserId and c.Status__c = 'Booked'];
        
        return coursebooking;
    }

    public List<Course_Booking__c> getCompleteCoursesBooking(){
        Id currentUserId = [select contactid from User where id = :UserInfo.getUserId()].contactid;

        List<Course_Booking__c> coursebooking = [Select c.id, c.Course__c, c.Person__c, c.Status__c, c.Course__r.id, c.course__r.Name, c.Course__r.Start_Date_Time__c, c.Course__r.End_Date_Time__c From Course_Booking__c c
                            where c.Person__r.id = :currentUserId and c.Status__c != 'Booked'];
        
        return coursebooking;
    }
}