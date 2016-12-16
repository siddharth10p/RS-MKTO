/**
 * Description: This is a batch class that identifies dup accounts and merge them
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      11/21/2016                   1.0      Initial Draft
 * Liquid Planner: /space/118974/projects/show/30837040
 * Copyright © Peruto Solutions Inc.
 **/
global with sharing class MergeRecordsBatch implements Database.Batchable<Sobject>, 
                                                                              Database.Stateful{
    private List<String> removeSobjList;
    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 50000000;
        return Database.getQueryLocator([ SELECT Id, Email
                                            FROM Lead
                                            WHERE Email = 'siddharth+test9@perkuto.com'
                                            LIMIT  :maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
       Set<String> emailExistSet = new Set<String> ();
       for (Lead leadInstance : (List<Lead>) scope ) {
            emailExistSet.add (leadInstance.Email);
       }
       removeSobjList = MergeRecordsUtil.mergeRecords (emailExistSet);
    }

    global void finish(Database.BatchableContext BC) {
        if (removeSobjList != null && !removeSobjList.isEmpty ())
        MergeRecordsUtil.sendEmail (removeSobjList);
    }
}