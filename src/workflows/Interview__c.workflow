<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Task - Succesful Interview Relevant Details</fullName>
        <actions>
            <name>Applicant - Relevant Details</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Interview__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Interview__c.Outcome__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>On Successful Interview set Task to Interview Record Owner to gather relevant details</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Applicant - Relevant Details</fullName>
        <assignedToType>owner</assignedToType>
        <description>Gather the relevant details needed to process the application (i.e. CRB form ID Photograph etc)</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
