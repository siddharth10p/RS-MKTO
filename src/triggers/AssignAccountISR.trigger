/**
 * Description: This trigger calls handler class to process request.
 *
 * Author            Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit   05/27/2016                   1.0      Initial Draft
 * Liquid Planner: space/118974/projects/show/27074749
 **/
trigger AssignAccountISR on Account (after insert, after update) {
    ISR_Account_Setting__c isrAcc = AssignAccountISRTriggerHandler.getISRCustSetting ();
    if (isrAcc != null && isrAcc.Account_Trigger_On__c && 
        Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        AssignAccountISRTriggerHandler.createNewISRs (Trigger.new);
    } // End if
}// End trigger