/**
 * Description: This trigger will invoke trigger handler class to update
 * Contact owner, whenever a new contact is created or existing contact is updated.
 * Copyright © Peruto Solutions Inc.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 *
 * TDD - https://docs.google.com/document/d/1Bx-ogp-YrIJ2Od60ffd2ghelOV-mbBLDwoNjU6_nHMU/edit#heading=h.5ipxruo03l6r
 **/

trigger ContactOwnerUpdateTrigger on Contact (before insert, before update) {
    OwnerUpdateTriggerHandler.updateRecordOwner (Trigger.new);
}