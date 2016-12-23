/** 
 * Description: 25 days after a person transitions to the lifecycle stage of Sales Accepted, if
 * they are still in the lifecycle stage of Sales Accepted, create the following task
 * Technical Description: This is a batch class to create SalesAccepted task after 25 days from lifecycel
 * stage moved into "Sales Accepted". Customer path's transition date field has been used to 
 * calculate the number of days
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/28/2016           1.0      Inital draft
 * Siddharth Pandit    11/03/2016           1.1      Change the task owner to the owner of CP
 *
 * Test class name- TestCreateSATasksBatch
 **/
public with sharing class CreateSalesAcceptedTaskTriggerHandler {
    // Final variables
    private static final String STR_CUSTSETTING = 'SA_Task_Setting__c';
    private static final String STR_SASTATUS = 'Sales Accepted';
    private static final String STR_ISSAL = 'Is_SAL__c';
    private static final Integer days = Integer.valueOf (System.Label.SA_Task_DueDate);
    // Used in test class
    public static final String STR_TASKTYPE = 'Lifecycle Transition - SA';

    // A method that calls by a batch apex and it creates SA tasks
    public static void createSAtasks (Map<String, p2s_base1__CustomerPath__c> pCpIdObjMap,
                                      Map<String, Sobject> pCpIdRelobjMap) {
        List<p2s_base1__CustomerPath__c> custPathList = new List<p2s_base1__CustomerPath__c> ();
        List<SA_Task_Setting__c> custSettingList = 
                                    UtilityGeneral.retrieveCustSettingData (STR_CUSTSETTING);
        List<Task> taskListToInsert = new List<Task> ();
        for (Sobject leadOrCon : pCpIdRelobjMap.values()) {
            //if (leadOrCon == null) continue;
            System.debug ('leadOrCon ==> '+leadOrCon);
            String objId = String.valueOf (leadOrCon.get (VariableInitializer.ID_FIELDNAME));
            if (pCpIdObjMap.containsKey (objId)) {
                p2s_base1__CustomerPath__c custPath = pCpIdObjMap.get (objId);
                Task taskInstance = new Task ();
                taskInstance.Lifecycle_Transition__c = custPath.Id;
                taskInstance.WhoId = objId;
                taskInstance.OwnerId = custPath.OwnerId; 
                // Assign task Subject and Comment
                taskInstance = (Task) UtilityGeneral.fillTaskData (taskInstance, 
                                                UtilityGeneral.isContactObj (leadOrCon),
                                                custSettingList, leadOrCon);
                taskInstance = updateTaskDates (taskInstance); // Setting up dates
                taskInstance.Type = STR_TASKTYPE;
                taskListToInsert.add (taskInstance); // Adding task in the list to insert
                custPath.Is_SA__c = false;
                custPathList.add (custPath);
            }
        }
        if (taskListToInsert.size() > 0)
            insert taskListToInsert;
        if (custPathList.size() > 0)
            update custPathList;
    } // End method

    // A method that sets SLA and DueDates for the tasks
    public static Task updateTaskDates (Task taskInstance) {
        if (taskInstance == null) return null;
            taskInstance.ActivityDate = 
                                UtilityGeneral.nextBusinessDay (Date.today().addDays (days));
            Date dateSLA = UtilityGeneral.nextBusinessDay (Date.today().addDays (days + 1));
            dateSLA = taskInstance.ActivityDate == dateSLA? dateSLA.addDays(1) : dateSLA;
            taskInstance.SLA_Violation_Date__c = dateSLA;
            return taskInstance;
    } // End method
} // End class