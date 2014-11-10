<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Do Not Call</fullName>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Do Not Email</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Country to United Kindgom</fullName>
        <field>MailingCountry</field>
        <formula>&quot;United Kingdom&quot;</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contact Community User Email</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Applicant</value>
        </criteriaItems>
        <description>Set Contact Community User Email from Email to Work</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Generate Welcome Pack Task</fullName>
        <actions>
            <name>Send out a welcome pack</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Volunteer,Staff</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Person Deceased</fullName>
        <actions>
            <name>Do Not Call</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Do Not Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Status__c</field>
            <operation>equals</operation>
            <value>Deceased</value>
        </criteriaItems>
        <description>Update do not call or email when person&apos;s status is deceased</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Country to United Kindgom</fullName>
        <actions>
            <name>Update Country to United Kindgom</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.MailingCountry</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Send out a welcome pack</fullName>
        <assignedTo>sfdc@rnib.org.uat</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please send a welcome pack to this person.

You can automatically generate a welcome letter via the button on their contact record.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
