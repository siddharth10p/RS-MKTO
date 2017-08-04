/**
 * Description: This trigger calls handler class to process request.
 *
 * Author            Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit   05/27/2016                   1.0      Initial Draft
 * Liquid Planner: space/118974/projects/show/27074749
 * Copyright © Peruto Solutions Inc.
 *
 * TDD - https://docs.google.com/document/d/1UtHDAVaeg2Ewlzf_czJlKiAz2duKA7odFgm4Ud6x6p0/edit#heading=h.oftlwkjlqvmb
 **/
trigger UpdateAccISR on User (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AssignAccountISRTriggerHandler.insertNewISRs (Trigger.new);
    } // End if
}