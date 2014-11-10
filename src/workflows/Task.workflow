<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Task for GVT if the task created for the VM is not closed until 2 weeks %28For task %22Volunteer Role being %27Unsuccessful%27%29</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>Volunteer Role status was Unsuccessful. Update the system,if the status of the volunteer&apos;s application is &apos;unsuccessful&apos; and notify the volunteer.</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Status</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow task for GVT, if the task created for the VM is not closed until 2 weeks (For the workflow task &quot;Volunteer Role being &apos;Unsuccessful&apos; - Notify the applicant and update the system&quot;)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Task for GVT to remind the volunteer manager to update the system if the status of the volunteer%27s application is %27unsuccessful%27%2C the workflow task for this purpose is still open and if they have not notified the volunteer%2E</fullName>
        <assignedTo>GVT</assignedTo>
        <assignedToType>role</assignedToType>
        <description>Task for GVT to remind the volunteer manager to update the system if the status of the volunteer&apos;s application is &apos;unsuccessful&apos;, the workflow task for this purpose is still open and if they have not notified the volunteer.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
