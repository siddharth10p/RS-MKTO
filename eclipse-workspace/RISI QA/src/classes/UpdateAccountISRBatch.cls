/**
 * Description: This is a batch class called from a usr trigger to update Account's ISR
 *
 * Author            Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit   05/27/2016                   1.0      Initial Draft
 * Liquid Planner: space/118974/projects/show/27074749
 * Copyright © Peruto Solutions Inc.
 *
 * TDD - https://docs.google.com/document/d/1UtHDAVaeg2Ewlzf_czJlKiAz2duKA7odFgm4Ud6x6p0/edit#heading=h.oftlwkjlqvmb
 */

global with sharing class UpdateAccountISRBatch implements Database.Batchable<Sobject>, Database.Stateful{
    Set<String> accIdSet;
    global UpdateAccountISRBatch (Set<String> pAccIdSet) {
        accIdSet = pAccIdSet;
    } // End constructor
    
    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 50000000;
        return Database.getQueryLocator([ SELECT Id, OwnerId
                                            FROM Account
                                            WHERE Id IN : accIdSet
                                            LIMIT  :maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
    	AssignAccountISRTriggerHandler.createNewISRs (scope);
    }

    global void finish(Database.BatchableContext BC) {
    }

} // End class