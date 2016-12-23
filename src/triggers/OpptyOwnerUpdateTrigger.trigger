/**
 * Description: This trigger will invoke trigger handler class to update Opportunity owner,
 * whenever a new Opportunity is created or existing Opportunity is updated.
 * Copyright © Peruto Solutions Inc.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 *
 **/
trigger OpptyOwnerUpdateTrigger on Opportunity (before insert, before update) {
    OwnerUpdateTriggerHandler.updateRecordOwner (Trigger.new);
}