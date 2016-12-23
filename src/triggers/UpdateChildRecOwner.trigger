/**
 * Description: This trigger will invoke batch apex to update Opportunity owners,
 * if Account owner is changed.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 *
 **/
trigger UpdateChildRecOwner on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate)
        OwnerUpdateTriggerHandler.updateChildRecOwner (Trigger.oldMap, Trigger.newMap);
}