/**
 * Description: When a new opportunity is created with Revenue Type = Subscription - Renewal,
 * an Apex trigger will create a new task
 * Technical Description: This is a handler class create Renewal tasks based off Custom
 * Setting data
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/13/2016           1.0      Inital draft
 * Siddharth Pandit    08/25/2016           1.1      Added a logic to populate Recycle reason
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name: TestCreateTaskTriggerHandler
 *
 **/
public with sharing class RenewalTaskTriggerHandler {
    // private final variables
    private static final String STR_RENEWALOBJ = 'Renewal_Tasks_Setting__c';
    private static final String STR_REVTYPE = 'Subscription - Renewal';
    private static final String STR_OPPTYOBJNAME = 'Opportunity';
    private static final String STR_WHERE = 'WHERE';
    private static final String STR_ID = 'Id';
    private static final String STR_IN = 'IN';
    private static final String STR_COLON = ':';
    private static final String STR_SPACE = ' ';
    private static final String STR_INIT = '';
    private static final Integer days = Integer.valueOf (System.Label.Renewal_Task_DueDate);
    public static final String STR_OPTYCLOSE = 'Opportunity Closed'; // Used in test class
    public static final String STR_TASKTYPE = 'Renewal'; // Used in test class

	public static void createRenewalTasks (Map<Id, Opportunity> opptyNewMap) {
		Map<String, String> opptyIdConIdMap = new Map<String, String> ();
		String queryString = getOpptyQuery ();
		Set<Id> opptyIdSet = opptyNewMap.keySet();
		queryString += STR_SPACE+ STR_WHERE + STR_SPACE + STR_ID + STR_SPACE + STR_IN + STR_COLON+
					STR_SPACE+ 'opptyIdSet AND IsClosed = false';
		System.debug ('queryString ==> '+queryString);
		Map<Id, Sobject> opptyIdObjMap = new Map<Id, Sobject> (Database.query (queryString));
		for (OpportunityContactRole opptyConRole : [SELECT Id, OpportunityId, ContactId, IsPrimary
														FROM OpportunityContactRole
														WHERE OpportunityId IN : opptyNewMap.keySet()]) {
			if (opptyIdConIdMap.containsKey (opptyConRole.OpportunityId) &&
				opptyConRole.IsPrimary)
				opptyIdConIdMap.put (opptyConRole.OpportunityId, opptyConRole.ContactId);
			else
				opptyIdConIdMap.put (opptyConRole.OpportunityId, opptyConRole.ContactId);
		}
		List<Renewal_Tasks_Setting__c> renewalTaskData = UtilityGeneral.retrieveCustSettingData (STR_RENEWALOBJ);
		List<Task> tasksListToInsert = new List<Task> ();
        for (Opportunity oppty : opptyNewMap.values()) {
            if (STR_REVTYPE.equalsIgnoreCase (oppty.Revenue_Type__c) && !oppty.IsClosed) {
                Task taskInstance = new Task ();
                taskInstance.OwnerId = oppty.OwnerId;
                taskInstance.WhatId = oppty.Id;
                taskInstance.WhoId = opptyIdConIdMap.get (oppty.Id);
                taskInstance.Contact_Hidden__c = opptyIdConIdMap.get (oppty.Id);
                taskInstance.Type = STR_TASKTYPE;
                taskInstance = updateTaskDates (taskInstance); // Setting SLA and Due dates
                taskInstance = (Task) UtilityGeneral.fillTaskData (taskInstance, true, renewalTaskData,
                                                                opptyIdObjMap.get (oppty.Id));
                tasksListToInsert.add (taskInstance);
                System.debug ('taskInstance ==> '+taskInstance);
            } // End if
        } // End for
		if (tasksListToInsert.size() > 0)
			insert tasksListToInsert;
	} // End method

    // A method to set SLA and Due dates for tasks 
    public static Task updateTaskDates (Task taskInstance) {
        if (taskInstance == null) return null;
            taskInstance.ActivityDate =
                                UtilityGeneral.nextBusinessDay (Date.today().addDays (days));
            Date dateSLA = UtilityGeneral.nextBusinessDay (Date.today().addDays (days +1));
            dateSLA = dateSLA == taskInstance.ActivityDate? dateSLA.addDays (1): dateSLA;
            taskInstance.SLA_Violation_Date__c = dateSLA;
        return taskInstance;
    } // End method

    // A method that returns Oppty query
    private static String getOpptyQuery () {
        String opptyQueryString = STR_INIT;
        for (Schema.FieldSetMember f : retrieveOpptyFields ()) {
            opptyQueryString += f.getFieldPath() + ', ';
        }
        	return UtilityGeneral.getQuery (opptyQueryString, STR_OPPTYOBJNAME);
	}

	// A method to retrieve Oppty fields from fieldset
	private static List<Schema.FieldSetMember> retrieveOpptyFields () {
		return SObjectType.Opportunity.FieldSets.Renewal_Task.getFields();
    }
    
    // A method that populates recycled reason on close Oppty
    public static void updateRecycleReason (List<Opportunity> opptyList) {
        List<Contact> conListToUpdate = new List<Contact> ();
        Set<String> opptyIdSet = new Set<String> ();
        for (Opportunity opptyInstance : opptyList) {
            if (opptyInstance.IsClosed)
                opptyIdSet.add (opptyInstance.Id);
        }
        for (Contact conInstance : [SELECT Id, Recycled_Reason__c
                                    FROM Contact 
                                    WHERE Id IN 
                                    (SELECT ContactId
                                     FROM OpportunityContactRole
                                     WHERE OpportunityId IN :opptyIdSet)]) {
            conInstance.Recycled_Reason__c = STR_OPTYCLOSE;
            conListToUpdate.add (conInstance);
        } // End for
        if (!conListToUpdate.isEmpty ())
            update conListToUpdate;
    } // End method
}