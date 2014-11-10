<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Acknowledgment email sent to volunteer on receipt of their application</fullName>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>Acknowledgement_Emails/Acknowledgment_email_sent_to_volunteer_on_receipt_of_their_application</template>
    </alerts>
    <alerts>
        <fullName>Applicant Chase - not modified after 7 days</fullName>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>All_templates/Chase_Applicant</template>
    </alerts>
    <alerts>
        <fullName>Chase 2 to the Volunteer reminding of the References</fullName>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <template>All_templates/Chase_2_to_the_volunteer_in_regards_to_the_Referee</template>
    </alerts>
    <alerts>
        <fullName>Chase 3 to the volunteer in regards to the References</fullName>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <template>All_templates/Chase_3_to_the_Volunteer_for_references_before_cancelling_the_application</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set Auto Delete Flag</fullName>
        <field>Automatic_Deletion_Required__c</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set Delete Flag</fullName>
        <field>Automatic_Deletion_Required__c</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Active Role Start Date</fullName>
        <description>Update the start date to current date on an active role when the role is activated</description>
        <field>Start_Date__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Workflow Date Field</fullName>
        <field>Test_Workflow__c</field>
        <formula>now()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Acknowledgement email sent to volunteer on receipt of the online application</fullName>
        <actions>
            <name>Acknowledgment email sent to volunteer on receipt of their application</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Role_Opportunity__c.Active_on_Website__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Chase 2 to the volunteer in regards to the References</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Referee Checks</value>
        </criteriaItems>
        <description>This workflow rule will be a 1st reminder to chase applicants for references</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chase 3 to the volunteer in regards to the Referee</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Referee Checks</value>
        </criteriaItems>
        <description>This workflow rule will be a 2nd reminder to chase applicants for references</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email reminder to applicants who have not submitted an application form</fullName>
        <active>true</active>
        <formula>ISPICKVAL(Status__c,&apos;Draft&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to be sent to GVT for verification of referees %28where needed%29</fullName>
        <actions>
            <name>Notification to conduct a verification on Referee</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Referee Checks</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Start Date when Role Activated</fullName>
        <actions>
            <name>Update Active Role Start Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Role</value>
        </criteriaItems>
        <description>Workflow rule to populate the start date when the role is activated</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Reminder to Volunteer Manager to Contact Applicant if Unsuccesful</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Role Filled,Unsuccessful - Not Suitable at Interview,Unsuccessful - Not Suitable for Interview,Unsuccessful - Unsuitable References,Unsuccessful - Unsuitable Risk Assessment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Contact_Informed_of_Application_Outcome__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Reminder to Volunteer Manager to notify applicant if unsuccessful and &quot;Contact Informed of Application Outcome&quot; is unticked after 30 days,</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Auto Delete Flag TEST</fullName>
        <active>false</active>
        <description>This will set a check box - Automatic Deletion Required - to TRUE if there has been no action on the Application and is set to Draft</description>
        <formula>ISPICKVAL(Status__c, &quot;Draft&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Auto Delete Flag TEST2</fullName>
        <active>false</active>
        <formula>ISPICKVAL(Status__c, &quot;Draft&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Auto Delete Flag on 1 day old Application</fullName>
        <active>false</active>
        <description>This will set a check box - Automatic Deletion Required - to TRUE if there has been no action on the Application and is set to Draft</description>
        <formula>ISPICKVAL(Status__c, &quot;Draft&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Auto Delete Flag on 14 day old Application</fullName>
        <active>true</active>
        <description>This will set a check box - Automatic Deletion Required - to TRUE if there has been no action on the Application and is set to Draft</description>
        <formula>ISPICKVAL(Status__c, &quot;Draft&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Task for GVT to arrange an induction call after 2 weeks since the welcome pack is sent to a Volunteer</fullName>
        <actions>
            <name>Task to check with the Volunteer%2C whether they have received the welcome pack and arrange an induction calL</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Role</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Start_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Test Auto Delete TEST3</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Volunteer Role Unsuccessful notify Contact</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Role Filled,Unsuccessful - Not Suitable at Interview,Unsuccessful - Not Suitable for Interview,Unsuccessful - Unsuitable References,Unsuccessful - Unsuitable Risk Assessment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Contact_Informed_of_Application_Outcome__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When a Volunteer Role (Application) is marked as Unsuccessful reminder User to contact Applicant if &quot;Contact Informed of Application Outcome&quot; is unticked after 30 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Workflow task for VM upon Volunteer Role being %27Unsuccessful - Unsuitable Risk Assessment%27</fullName>
        <actions>
            <name>Volunteer Role status was Unsuccessful%2E Update the system%2C if the status of the volunteer%27s application is %27unsuccessful%27 and notify the volunteer%2E</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Unsuitable Risk Assessment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Workflow task for VM upon Volunteer Role being %27Unsuccessful%27 - Notify the applicant and update the system</fullName>
        <actions>
            <name>Volunteer Role status was Unsuccessful%2E Update the system%2C if the status of the volunteer%27s application is %27unsuccessful%27 and notify the volunteer%2E</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Role Filled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Not Suitable at Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Not Suitable for Interview</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Unsuitable References</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Unsuccessful - Unsuitable Risk Assessment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Notification to conduct a verification on Referee</fullName>
        <assignedTo>GVT</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
    <tasks>
        <fullName>Task to check with the Volunteer%2C whether they have received the welcome pack and arrange an induction calL</fullName>
        <assignedTo>GVT</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>14</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
    <tasks>
        <fullName>Volunteer Role status was Unsuccessful%2E Update the system%2C if the status of the volunteer%27s application is %27unsuccessful%27 and notify the volunteer%2E</fullName>
        <assignedTo>Volunteer Manager / Coordinator</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
