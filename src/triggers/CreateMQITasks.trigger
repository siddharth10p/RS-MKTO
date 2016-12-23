/**
 * Description: This trigger calls handler to Create MQI tasks
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/11/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 **/
trigger CreateMQITasks on p2s_base1__CustomerPath__c (after insert, after update) {
    CreateMQITaskTriggerHandler.createMQITasks (Trigger.new, Trigger.isUpdate);
}