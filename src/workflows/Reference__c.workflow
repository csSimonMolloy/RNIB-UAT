<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Chase - 1 email alert to Referee</fullName>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Volunteer_Email__c</field>
            <type>email</type>
        </recipients>
        <template>All_templates/Chase_1_to_the_Referee_Email</template>
    </alerts>
    <alerts>
        <fullName>Chase - 3 to Volunteer to notify the withdrawal of application in absence of references</fullName>
        <protected>false</protected>
        <recipients>
            <field>Volunteer_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <template>All_templates/Chase_3_to_the_Volunteer_for_references_before_cancelling_the_application</template>
    </alerts>
    <alerts>
        <fullName>Chase 1 to the Referee</fullName>
        <protected>false</protected>
        <recipients>
            <recipient>sfdc@rnib.org.uat</recipient>
            <type>user</type>
        </recipients>
        <template>All_templates/Chase_1_to_the_Referee_Email</template>
    </alerts>
    <alerts>
        <fullName>Chase 1 to the Referee</fullName>
        <protected>false</protected>
        <recipients>
            <recipient>sfdc@rnib.org.uat</recipient>
            <type>user</type>
        </recipients>
        <template>All_templates/Chase_1_to_the_Referee_Email</template>
    </alerts>
    <alerts>
        <fullName>Chase 2 to Volunteer for References</fullName>
        <protected>false</protected>
        <recipients>
            <field>Volunteer_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Volunteer_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <template>All_templates/Chase_2_to_the_volunteer_in_regards_to_the_Referee</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update Date Received</fullName>
        <field>Date_Reference_Received__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Outcome</fullName>
        <field>Outcome__c</field>
        <literalValue>Approved</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Volunteer Email field</fullName>
        <field>Volunteer_Email__c</field>
        <formula>Volunteer_Email1__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Volunteer Manager Email field</fullName>
        <field>Volunteer_Manager_Email__c</field>
        <formula>Copy_Volunteer_Manager_Email__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update status to rejected</fullName>
        <field>Outcome__c</field>
        <literalValue>Rejected</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Chase 1 to Referee</fullName>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>equals</operation>
            <value>Pending Checks</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>equals</operation>
            <value>More Information Required</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Date_Reference_Sent__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Date_Reference_Received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Reference_Received__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This is the workflow rule for the chase to Referee after 14 days in regards to references</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chase 1 to the Referee</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>notEqual</operation>
            <value>More Information Required,Accepted,Declined Cancel Application,Declined Request New Referee</value>
        </criteriaItems>
        <description>This is the workflow rule for the chase which will be sent with regard to references</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chase 2 to Volunteer %28Applicant%29 for chasing reference</fullName>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>equals</operation>
            <value>Pending Checks</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>equals</operation>
            <value>More Information Required</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Date_Reference_Sent__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Date_Reference_Received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Reference_Received__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This is the workflow rule for chase 2 to Volunteer after 21 days of non-receipt of References from Referee(s)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chase 3 to Volunteer %28Applicant%29 for chasing reference</fullName>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>equals</operation>
            <value>Pending Checks</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Outcome__c</field>
            <operation>equals</operation>
            <value>More Information Required</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Date_Reference_Sent__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Date_Reference_Received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Reference_Received__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This is the workflow rule for chase 2 to Volunteer after 31 days of non-receipt of References from Referee(s)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate the Volunteer Email field for Chase-1 to Referee workflow</fullName>
        <actions>
            <name>Update Volunteer Email field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard Reference,Risk Assessment Reference</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate the Volunteer Manager Email field for Chase-2 to Volunteer for Reference workflow</fullName>
        <actions>
            <name>Update Volunteer Manager Email field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard Reference,Risk Assessment Reference</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Date Reference Received</fullName>
        <actions>
            <name>Update Date Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.Reference_Received__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
