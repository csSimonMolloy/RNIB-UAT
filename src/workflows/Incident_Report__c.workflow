<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Text form filled in by</fullName>
        <description>Field update to update the text field for form filled in by if the Incident report is created internally</description>
        <field>Form_filled_in_by2__c</field>
        <formula>Form_Filled_In_By__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update form filled in by text field</fullName>
        <actions>
            <name>Update Text form filled in by</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Incident_Report__c.Form_filled_in_by2__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
