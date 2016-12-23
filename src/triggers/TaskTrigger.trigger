/**
 * Description: If the owner of a task changes, the SLA Violation date should be reset as if the
 * task had first been created at that time, so that the new owner has the same time period to 
 * fulfill their SLA. 
 *
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    09/15/2016           1.0      Inital draft
 *
 **/
trigger TaskTrigger on Task (before update, after update, before insert) {
    if (Trigger.isBefore && Trigger.isUpdate)
        TaskTriggerHandler.updateTaskDueDate (Trigger.oldMap, Trigger.newMap);
    if (Trigger.isAfter && Trigger.isUpdate)
        TaskTriggerHandler.updateOpptyActivityDate (Trigger.oldMap, Trigger.newMap);
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        TaskTriggerHandler.updateHiddenFields (Trigger.new);
}