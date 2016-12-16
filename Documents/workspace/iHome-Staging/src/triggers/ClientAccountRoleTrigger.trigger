/**
 * Discription- Sid to add
 **/
trigger ClientAccountRoleTrigger on Client_Account_Contact_Role__c (after update, after insert) {
    ClientAccountTriggerHandler.createIntegrationObj (Trigger.newMap, Trigger.oldMap, true);
}