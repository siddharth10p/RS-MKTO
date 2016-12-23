/**
 * Description: This trigger calls handler to update Oppty Lifecycle stage
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    06/28/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 **/
 // Sid- this trigger needs to be removed as the approach has been changed
trigger UpdateOpptyLifecycle on p2s_base1__CustomerPath__c (after insert, after update) {
   // ProductUpdateCustPathTriggerHandler.updateOpptyLifeCycleStage (Trigger.new);
}