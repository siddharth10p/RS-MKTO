/**
 * Add discription - Sid
 **/
trigger ClientAccountTrigger on Client_Account__c (after update) {
    ClientAccountTriggerHandler.createIntegrationObj (Trigger.newMap, Trigger.oldMap, false);
}