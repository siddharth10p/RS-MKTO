/**
 * Description: This trigger calls handler class to process request.
 *
 * Author            Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit   05/27/2016                   1.0      Initial Draft
 * Liquid Planner: space/118974/projects/show/27074749
 **/
trigger UpdateAccISR on User (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AssignAccountISRTriggerHandler.insertNewISRs (Trigger.new);
    } // End if
}