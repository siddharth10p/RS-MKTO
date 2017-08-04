/**
 * Description: This class contains all final variables which are been used in other apex classes
 *
 *    Author             Date (mm-dd-yyyy)    Version       ChangeLog
 * Siddharth Pandit        07/14/2016          1.0          Initial Draft
 * Siddharth Pandit        09/14/2016          1.1          Added / Modified few values
 *
 * LLC TDD (Approach for MQI Follow-Up):
   https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
   pli=1#heading=h.vjmst4xinbdp
 **/
public with sharing class VariableInitializer {
	// final variables
    public static final String MQI_STATUS = 'Marketing Qualified Instance';
	public static final String LOB_FIELDNAME = 'Line_of_Business__c';
	public static final String ID_FIELDNAME = 'Id';
	public static final String ACCID_FIELDNAME = 'AccountId';
	public static final String STR_TO_LIFECYCLE = 'p2s_base1__ToLifecycleStage__c';
	public static final String STR_CON_LOOKUP = 'p2s_base1__Contact__c';
	public static final String STR_LEAD_LOOKUP = 'p2s_base1__Lead__c';
	public static final String STR_ACC = 'Account';
	public static final String STR_NAME = 'Name';
	public static final String STR_INIT = '';
	public static final String STR_COLON = ':'; 
	public static final String STR_LCTRANS = 'Lifecycle Transition - MQI';
	public static final String STR_OPPTENRCH = 'Opportunity Enrichment';
	public static final String STR_ACCMANPROFILE = 'RISI Account Manager';
	public static final String STR_ACCISRPROFILE = 'RISI Inside Sales Representative';
	public static final String STR_EVENT = 'Events';
	public static final String OWNER_FIELDNAME = 'OwnerId'; 
	public static final String ACCISR_FIELDNAME = 'Assigned_ISR__c';
	public static final String STR_PROFILE = 'Profile';
	public static final String STR_MQISETTING = 'MQI_Followup_Task__c';
	public static final String STR_WHERE = 'WHERE';
	public static final String STR_CONTACT = 'Contact';
	public static final String STR_OPPTY = 'Opportunity';
	public static final String STR_LEAD = 'Lead';
	public static final String STR_IN = 'IN';
	public static final String STR_FROM = 'FROM';
	public static final String STR_SELECT = 'SELECT';
	public static final String STR_SPACE = ' ';
	public static final String STR_FASTTRACK = 'Fast_Track_Formula__c';
	public static final String STR_COMMA = ',';
    public static final String STR_FORMFILLPAGE = 'Last_Form_Fill_Web_Page__c';
    public static final String STR_LEADACTVT = 'Last_Lead_Activity_Detail__c';
    public static final String STR_PRODINTFAM = 'Last_Product_Interest_Family__c';
    public static final String STR_PRODINT = 'Last_Product_Interest__c';
    public static final String STR_LOB = 'Last_Line_of_Business__c';
    public static final String STR_CSTPATH = 'p2s_base1__CustomerPath__c';
}