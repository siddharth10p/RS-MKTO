/**
 * Description: This trigger will invoke trigger handler class to update Opportunity owner,
 * whenever a new Opportunity is created or existing Opportunity is updated.
 * Copyright © Peruto Solutions Inc.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 *
 * TDD- https://docs.google.com/document/d/1Bx-ogp-YrIJ2Od60ffd2ghelOV-mbBLDwoNjU6_nHMU/edit#heading=h.5ipxruo03l6r
 **/
trigger OpptyOwnerUpdateTrigger on Opportunity (before insert, before update) {
    OwnerUpdateTriggerHandler.updateRecordOwner (Trigger.new);
}