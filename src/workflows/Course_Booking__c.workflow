<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Notification to VM to investigate why the volunteer hasn%27t attended the course</fullName>
        <actions>
            <name>Task to investigate why the volunteer hasn%27t attended the course</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Course_Booking__c.Status__c</field>
            <operation>equals</operation>
            <value>Booked</value>
        </criteriaItems>
        <criteriaItems>
            <field>Course__c.End_Date_Time__c</field>
            <operation>equals</operation>
            <value>NEXT WEEK</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Task to investigate why the volunteer hasn%27t attended the course</fullName>
        <assignedTo>Volunteer Manager / Coordinator</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Course__c.End_Date_Time__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
