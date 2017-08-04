/**
 * Description: This trigger calls handler to perform following functions
 * 1) create a new Customer path with SQO- SQO transition
 * 2) Mark IsRenewal = true when OpptyLineItem is exist on ND Order lineItem
 * 
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    06/28/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 *
 **/
trigger OpptyLineItemTrigger on OpportunityLineItem (after insert, after update, before insert) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    OpptyLineItemTriggerHandler.cloneCustPath (Trigger.oldMap, Trigger.newMap,
                                                                    Trigger.isUpdate);
    if (Trigger.isAfter && Trigger.isInsert)
        OpptyLineItemTriggerHandler.markIsRenewal (Trigger.new);
}