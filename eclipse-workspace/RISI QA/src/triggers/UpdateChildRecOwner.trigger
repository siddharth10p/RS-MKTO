/**
 * Description: This trigger will invoke batch apex to update Opportunity owners,
 * if Account owner is changed.
 * Copyright © Peruto Solutions Inc.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 *
 * TDD - https://docs.google.com/document/d/1Bx-ogp-YrIJ2Od60ffd2ghelOV-mbBLDwoNjU6_nHMU/edit#heading=h.5ipxruo03l6r
 **/
trigger UpdateChildRecOwner on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate)
        OwnerUpdateTriggerHandler.updateChildRecOwner (Trigger.oldMap, Trigger.newMap);
}