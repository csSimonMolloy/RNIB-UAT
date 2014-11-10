<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Opportunity Email Alert - Send Rejection notification to Volunter Manager</fullName>
        <protected>false</protected>
        <recipients>
            <field>Volunteer_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Approval_Process_Notifications/Opportunity_Request_Rejection_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Date approved</fullName>
        <field>Date_Approved__c</field>
        <formula>Now()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date submitted</fullName>
        <field>Date_Submitted_for_Approval__c</field>
        <formula>Now()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Publish to Website</fullName>
        <field>Active_on_Website__c</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck Active on Website</fullName>
        <field>Active_on_Website__c</field>
        <literalValue>0</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Status to Pending Approval</fullName>
        <field>Status__c</field>
        <literalValue>Sent for approval</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Remove from Web if inactive</fullName>
        <actions>
            <name>Uncheck Active on Website</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Role_Opportunity__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected,Withdrawn,Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
