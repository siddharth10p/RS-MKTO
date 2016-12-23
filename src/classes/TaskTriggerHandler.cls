/**
 * Description: If the owner of a task changes, the SLA Violation date should be reset as if the
 * task had first been created at that time, so that the new owner has the same time period to 
 * fulfill their SLA.
 *
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    08/30/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name- TestCreateTaskTriggerHandler
 **/
public with sharing class TaskTriggerHandler {
    public static final String STR_CLOSESTATUS = 'Completed';
    private static final String STR_OPPTY = 'Opportunity';
    private static final String STR_CONOBJ = 'Contact';

    // A method that updates task due date whenever onwer changes
    public static void updateTaskDueDate (Map<Id, Task> pOldTaskMap, Map<Id, Task> pNewTaskMap) {
        Set<String> taskIdSet = new Set<String> ();
        for (String tId : pNewTaskMap.keySet ()) {
            if (pNewTaskMap.get (tId).OwnerId != pOldTaskMap.get (tId).OwnerId) {
                taskIdSet.add (tId);
            }
        }
        Map<String, Sobject> userIdObjMap = CreateMQITaskTriggerHandler.getActiveUserMap ();
        for (Task taskUpdate : pNewTaskMap.values()) {
            // if task type is MQI or Oppty
            if (taskIdSet.contains (taskUpdate.Id) &&
                userIdObjMap.containsKey (taskUpdate.OwnerId)) {

                updateSLADueDate (taskUpdate); // if task type is renewal or SA
                Boolean fastTrack = 
                CreateMQITaskTriggerHandler.isFastTrack (taskUpdate.Lead_Activity_Detail_Text__c);
                CreateMQITaskTriggerHandler.TaskWrapper taskWrp = 
                            CreateMQITaskTriggerHandler.getActivityDate (fastTrack, 
                                                taskUpdate.Line_of_Business__c,
                                                userIdObjMap.get (taskUpdate.OwnerId));
                if (taskWrp != null && taskWrp.dueDate != null) {
                    taskUpdate.ActivityDate = UtilityGeneral.skipWeekEnd (taskWrp.dueDate);
                    Date tempSLADate = UtilityGeneral.skipWeekEnd (taskWrp.dueDate.addDays (1));
                    taskUpdate.SLA_Violation_Date__c = taskWrp.dueDate == null? null 
                                                        :tempSLADate;
                } // End if
            } // End if
        } // End for
    } // End method

    // A method that sets dueDate and SLA dates when task owner changes
    private static void updateSLADueDate (Task taskInstance) {
        if (taskInstance != null) {
            if (CreateSalesAcceptedTaskTriggerHandler.STR_TASKTYPE
                                                 .equalsIgnoreCase (taskInstance.Type))
                CreateSalesAcceptedTaskTriggerHandler.updateTaskDates (taskInstance);
            if (RenewalTaskTriggerHandler.STR_TASKTYPE.equalsIgnoreCase (taskInstance.Type))
                RenewalTaskTriggerHandler.updateTaskDates (taskInstance);
        } // End if
    } // End method

    // A method to copy Contact or Lead lookup (hidden)fields on task
    public static void updateHiddenFields (List<Task> pTaskList) {
        for (Task taskInstance : pTaskList) {
            if (taskInstance.WhoId != null) {
                if (STR_CONOBJ.equalsIgnoreCase (taskInstance.WhoId.getSObjectType()
                                                .getDescribe().getName()))
                    taskInstance.Contact_Hidden__c = taskInstance.WhoId;
                else
                    taskInstance.Lead_Hidden__c = taskInstance.WhoId;
            }
        }
    }
    // A method to populate Lastactivity date on Oppty
    public static void updateOpptyActivityDate (Map<Id, Task> pOldTaskMap, Map<Id, Task> pNewTaskMap) {
        Set<String> opptyIdSet = new Set<String> ();
        for (String taskId : pNewTaskMap.keySet()) {
            if (String.isNotBlank (pNewTaskMap.get (taskId).WhatId)) {
                Id opptyId = String.valueOf (pNewTaskMap.get (taskId).WhatId);
            if (pNewTaskMap.get (taskId).Status != pOldTaskMap.get(taskId).Status &&
                STR_CLOSESTATUS.equalsIgnoreCase (pNewTaskMap.get (taskId).Status) &&
                STR_OPPTY.equalsIgnoreCase (opptyId.getSObjectType().getDescribe().getName()))
                opptyIdSet.add (opptyId);
            } // End if
        } // End for
        List<Opportunity> optyToUpdate = new List<Opportunity> ();
        for (Opportunity oppty : [SELECT Id, Last_Activity_Date__c
                                    FROM Opportunity
                                    WHERE Id IN: opptyIdSet]) {
            oppty.Last_Activity_Date__c = Datetime.now();
            optyToUpdate.add (oppty);
        } // End method
        if (!optyToUpdate.isEmpty())
            update optyToUpdate;
    } // End method
} // End class