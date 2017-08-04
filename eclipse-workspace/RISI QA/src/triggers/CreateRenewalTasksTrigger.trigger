/**
 * Description: When a new opportunity is created with Revenue Type = Subscription - Renewal,
 * an Apex trigger will create a new task
 * Technical Description: This trigger calls handler class to Create Renewal tasks
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/13/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 *
 * LLC TDD (Approach for Renewal Tasks):
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.puvjvb1kgwgd
 **/
trigger CreateRenewalTasksTrigger on Opportunity (after insert, before update) {
    if (Trigger.isBefore && Trigger.isUpdate)
        RenewalTaskTriggerHandler.updateRecycleReason (Trigger.new);
}