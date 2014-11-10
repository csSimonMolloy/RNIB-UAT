<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Default Country to United Kingdom</fullName>
        <field>Country</field>
        <formula>&quot;United Kingdom&quot;</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Address Line 1 with Street</fullName>
        <description>Update the Address Line 1 field with the values from Street</description>
        <field>Address_Line_1__c</field>
        <formula>Street</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Address Line 2 with City</fullName>
        <field>Address_Line_2__c</field>
        <formula>City</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Address Line 3 with Zip%2FPostal</fullName>
        <field>Address_Line_3__c</field>
        <formula>PostalCode</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Address Line 4 State%2FCountry</fullName>
        <field>Address_Line_4__c</field>
        <formula>State + &quot; &quot; +  Country</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Address Fields on User for Ascent Report</fullName>
        <actions>
            <name>Default Country to United Kingdom</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update Address Line 1 with Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update Address Line 2 with City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update Address Line 3 with Zip%2FPostal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update Address Line 4 State%2FCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow rule to update the user record custom address fields for the Ascent export template</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
