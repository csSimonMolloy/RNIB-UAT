<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Acknowledgement</fullName>
        <protected>false</protected>
        <recipients>
            <field>Customer_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>Acknowledgement_Emails/Acknowledgementemail</template>
    </alerts>
    <alerts>
        <fullName>Acknowledgement - Referrer</fullName>
        <protected>false</protected>
        <recipients>
            <field>Referral_Contact_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>Acknowledgement_Emails/AcknowledgementemailReferrer</template>
    </alerts>
    <alerts>
        <fullName>Acknowledgement email to Co-ordinator for new customer request</fullName>
        <protected>false</protected>
        <recipients>
            <field>Volunteer_Coordinator__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Acknowledgement_Emails/Acknowledgement_email_to_Co_ordinator_for_new_customer_request</template>
    </alerts>
    <alerts>
        <fullName>Acknowledgement email to allocated TSS volunteer</fullName>
        <protected>false</protected>
        <recipients>
            <recipient>Volunteers</recipient>
            <type>role</type>
        </recipients>
        <template>Acknowledgement_Emails/Acknowledgement_email_to_allocated_TSS_volunteer</template>
    </alerts>
    <alerts>
        <fullName>Email Sent to Volunteer when a customer request is accepted</fullName>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <template>Acknowledgement_Emails/Confirmation_of_Acceptance_of_Customer_Request</template>
    </alerts>
    <alerts>
        <fullName>Email TSC to notify of New Customer Request Assignment</fullName>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <template>All_templates/TSS_Customer_Request_Assignment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign to GVT Manager Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>GVT Managers</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close Case</fullName>
        <field>Closed__c</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closed Time</fullName>
        <field>Date_Time_Closed__c</field>
        <formula>Now()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Flip RT To Internal</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer_Requests_Internal</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Flip RT to Portal</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer_Requests_Portal</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set to Closed</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status change</fullName>
        <field>Status__c</field>
        <literalValue>Closed pending approval</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status change2</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Closed Status to Closed -Approved</fullName>
        <description>Updates the Customer Request to Closed Approved on Approval</description>
        <field>Status__c</field>
        <literalValue>Closed - Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Customer Request Subject</fullName>
        <field>Subject__c</field>
        <formula>Name&amp; &quot; - &quot;  &amp; Customer_Name__r.Name__c &amp;&quot; - &quot; &amp;TEXT(Activity__c)</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Status to Rejected - FIR</fullName>
        <description>Update the status of the Customer Request to &quot;Rejected - Further Information Required&quot;</description>
        <field>Status__c</field>
        <literalValue>Rejected - Further Information Required</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Acknowledgement email to Co-ordinator for new customer request</fullName>
        <actions>
            <name>Acknowledgement email to Co-ordinator for new customer request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Requests__c.Customer_Request_Origin__c</field>
            <operation>equals</operation>
            <value>Email,Web,Helpline</value>
        </criteriaItems>
        <criteriaItems>
            <field>Customer_Requests__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Acknowledgement email when new customer request is submitted</fullName>
        <actions>
            <name>Acknowledgement</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Customer_Requests__c.Customer_Request_Origin__c</field>
            <operation>equals</operation>
            <value>Email,Web,Helpline</value>
        </criteriaItems>
        <criteriaItems>
            <field>Customer_Requests__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Acknowledgement email when new customer request is submitted to Referrer</fullName>
        <actions>
            <name>Acknowledgement - Referrer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Customer_Requests__c.Customer_Request_Origin__c</field>
            <operation>equals</operation>
            <value>Email,Web,Helpline</value>
        </criteriaItems>
        <criteriaItems>
            <field>Customer_Requests__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Request Assignment to GVT Manager</fullName>
        <actions>
            <name>Assign to GVT Manager Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Requests__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Pending Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Customer_Requests__c.Volunteer_Coordinator__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify TSC of Assigned Customer Request</fullName>
        <actions>
            <name>Email TSC to notify of New Customer Request Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Requests__c.OwnerId</field>
            <operation>notContain</operation>
            <value>GVT</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify the Volunteer of acceptance of the customer request</fullName>
        <actions>
            <name>Email Sent to Volunteer when a customer request is accepted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Requests__c.Allocated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Refer back to orginator</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Requests__c.Activities_Performed_to_Resolve_Request__c</field>
            <operation>equals</operation>
            <value>Referred back to originator</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TEst</fullName>
        <active>false</active>
        <formula>Owner:User.ContactId &lt;&gt; NULL</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Customer Request Subject</fullName>
        <actions>
            <name>Update Customer Request Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Requests__c.Subject__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
