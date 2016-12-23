/**
 * Description: When a new opportunity is created with Revenue Type = Subscription - Renewal,
 * an Apex trigger will create a new task
 * Technical Description: This trigger calls handler class to Create Renewal tasks
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/13/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 **/
trigger CreateRenewalTasksTrigger on Opportunity (after insert, before update) {
    if (Trigger.isInsert && Trigger.isAfter)
        RenewalTaskTriggerHandler.createRenewalTasks (Trigger.newMap);
    if (Trigger.isBefore && Trigger.isUpdate)
        RenewalTaskTriggerHandler.updateRecycleReason (Trigger.new);
}