<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approved notification for a new request - Safeguarding</fullName>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Approval_Process_Notifications/New_Request_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Approved notification for an existing request - Safeguarding</fullName>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Approval_Process_Notifications/Existing_Request_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Rejection notification for a new request - Safeguarding</fullName>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Approval_Process_Notifications/New_Request_Rejection_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Date Approved</fullName>
        <field>Date_Approved_Rejected__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date Rejected</fullName>
        <field>Date_Approved_Rejected__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date submitted for approval</fullName>
        <field>Date_Submitted_for_Approval__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exist Check - Update App Status Approved</fullName>
        <field>Status__c</field>
        <literalValue>Certificate Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exist Check - Update App Status Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Certificate Rejected</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Existing Check - Recall reset Status</fullName>
        <field>Status__c</field>
        <literalValue>DBS Letter Sent</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Existing Date Approved</fullName>
        <field>Date_Approved_Rejected__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Existing Date Rejected</fullName>
        <field>Date_Approved_Rejected__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Existing Date submitted for approval</fullName>
        <field>Date_Submitted_for_Approval__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New Check - Recall reset Status</fullName>
        <field>Status__c</field>
        <literalValue>New Application</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New Check - Update App Status Approved</fullName>
        <field>Status__c</field>
        <literalValue>Application Request Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New Check - Update App Status Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Application Request Rejected</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New Check Date Submitted for Approval</fullName>
        <field>New_Check_Date_Submitted_for_Approval__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New Date Approved</fullName>
        <field>New_Check_Date_Approved_Rejected__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New Date Rejected</fullName>
        <field>New_Check_Date_Submitted_for_Approval__c</field>
        <formula>NOW()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Status to Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Status to Declined</fullName>
        <field>Status__c</field>
        <literalValue>Declined</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Status to Pending Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update status to %27Cert Pending for App%27</fullName>
        <field>Status__c</field>
        <literalValue>Certificate Checked - Pending Approval</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update status to Pending App Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Application Approval</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update the field status to %27Approved%27</fullName>
        <field>Status__c</field>
        <literalValue>Application Request Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update the field status to %27Approved%27</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update the field status to %27Rejected%27</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update the field status to %27Rejected%27</fullName>
        <field>Status__c</field>
        <literalValue>Application Request Rejected</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <tasks>
        <fullName>Approval Request for New Request - Safeguarding has been recalled</fullName>
        <assignedTo>GVT</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
    <tasks>
        <fullName>Approval Request for an Existing Request - Safeguarding has been recalled</fullName>
        <assignedTo>GVT</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
