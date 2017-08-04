/**
 * Description: 
 * 1) The product and line of business responsible for the MQI will be derived from
 * the fields “Last Product Interest” and “Last Product Interest Family” that exist on the
 * Lead/Contact objects in Salesforce.
 * 2) When a new customer path record is created where the “Transition To” field is 
 * “Marketing Qualified Instance”, an Apex trigger will create a new task for the 
 * designated owner.
 * Technical Description: This trigger calls handler to execute logic. The different triggers are clubbed
 * in this one.
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/11/2016           1.0      Inital draft
 * LP URL: /space/118974/projects/show/30558937
 *
 * LLC TDD (Determining Product and Line of Business Responsible for MQI):
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    %20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20pli=1#heading=h.ni0gvo2hoe7c
 *
 * LLC TDD (Approach for MQI Follow-Up):
    https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.vjmst4xinbdp
 **/
trigger CustomerPathTrigger on p2s_base1__CustomerPath__c (before insert, after insert, after update) {
    if (Trigger.isInsert && Trigger.isBefore)
        PopulateMQIDataTriggerHandler.populateMQIInfo (Trigger.new);
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        System.debug ('Is insert ==> '+Trigger.isInsert);
        System.debug ('Is isUpdate ==> '+Trigger.isUpdate);
        CreateMQITaskTriggerHandler.createMQITasks (Trigger.new, Trigger.isUpdate);
    }
}