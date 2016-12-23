/**
 * Description: This trigger will invoke trigger handler class to update
 * Contact owner, whenever a new contact is created or existing contact is updated.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 *
 **/

trigger ContactOwnerUpdateTrigger on Contact (before insert, before update) {
    OwnerUpdateTriggerHandler.updateRecordOwner (Trigger.new);
}