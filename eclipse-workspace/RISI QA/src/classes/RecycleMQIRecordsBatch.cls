/**
 * Description: This batch class will be executed daily and it finds Leads / Contacts to update
 * Lifecycle Stage to Recycled after certain days. Number of days is fetched from the custom
 * label.
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      01/11/2017                   1.0      Initial Draft
 * Liquid Planner: /space/118974/projects/show/34691757
 * Copyright © Peruto Solutions Inc.
 **/
global class RecycleMQIRecordsBatch implements Database.Batchable<sObject>,
                                                                          Schedulable {
    public static final Integer INT_NUMDAYS = Integer.valueOf (System.Label.DurationToRecycle);
    public static final String STR_RECYCLED = 'Recycled';
    public static final String STR_MQI = 'Marketing Qualified Instance';
    public static final String STR_RECYCLEDRSN = 'Automated Recycle';

    global Database.Querylocator start(Database.BatchableContext BC) {
        Date dt = Date.today ().addDays (-INT_NUMDAYS);
        TimeZone tz = UserInfo.getTimeZone();
        Datetime startRange = DateTime.newInstance (dt.year (), dt.month (), dt.day(), 0, 0, 0);
        Datetime endRange = DateTime.newInstance (dt.year (), dt.month (), dt.day(), 23, 59, 59);
        Datetime startRangeFormat =
                   Datetime.valueOfGMT (startRange.format ('yyyy-MM-dd HH:mm:ss', tz.toString ()));
        Datetime endRangeFormat = 
                   Datetime.valueOfGMT (endRange.format ('yyyy-MM-dd HH:mm:ss', tz.toString ()));
        System.debug ('startRangeFormat ==> '+startRangeFormat);
        System.debug ('endRangeFormat ==> '+endRangeFormat);
        Integer maxRows = Test.isRunningTest() ? 10 : UtilityGeneral.BATCH_START_ROWS_LIMIT;
        return Database.getQueryLocator([SELECT Id, p2s_base1__Lead__c,
                                                p2s_base1__Contact__c
                                            FROM p2s_base1__CustomerPath__c
                                            WHERE p2s_base1__TransitionDateTime__c >=:
                                                    startRangeFormat
                                            AND p2s_base1__TransitionDateTime__c <=:
                                                    endRangeFormat
                                            AND p2s_base1__MostRecent__c = true
                                            AND p2s_base1__ToLifecycleStage__c = :STR_MQI
                                            LIMIT : maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> leadIdSet = new Set<Id> ();
        Set<Id> conIdSet = new Set<Id> ();
        for (p2s_base1__CustomerPath__c aCustPath : (List<p2s_base1__CustomerPath__c>) scope) {
            if (String.isNotBlank (aCustPath.p2s_base1__Contact__c))
                conIdSet.add (aCustPath.p2s_base1__Contact__c);
            else if (String.isNotBlank (aCustPath.p2s_base1__Lead__c))
                leadIdSet.add (aCustPath.p2s_base1__Lead__c);
        } // End for
        System.debug ('leadIdSet ==> '+leadIdSet);
        System.debug ('conIdSet ==> '+conIdSet);
        List<Sobject> objListToUpdate = new List<Sobject> ();
        for (Contact conInstance : [SELECT Id, p2s_base1__LifecycleStage__c, Recycled_Reason__c
                                    FROM Contact
                                    WHERE Id IN :conIdSet]) {
            conInstance.p2s_base1__LifecycleStage__c = STR_RECYCLED;
            conInstance.Recycled_Reason__c = STR_RECYCLEDRSN;
            objListToUpdate.add (conInstance);
        } // End for
        for (Lead leadInstance : [SELECT Id, p2s_base1__LifecycleStage__c, Recycled_Reason__c
                                    FROM Lead
                                    WHERE Id IN :leadIdSet
                                    AND IsConverted = false]) {
            leadInstance.p2s_base1__LifecycleStage__c = STR_RECYCLED;
            leadInstance.Recycled_Reason__c = STR_RECYCLEDRSN;
            objListToUpdate.add (leadInstance);
        } // End for

        System.debug ('objListToUpdate ==> '+objListToUpdate);
        if (!objListToUpdate.isEmpty ())
            Database.update (objListToUpdate, false);
    }

    global void execute(SchedulableContext SC) {
        RecycleMQIRecordsBatch recycleMQIRecs = new RecycleMQIRecordsBatch();
        Id batchprocessid = Database.executeBatch(recycleMQIRecs, 200);
    }

    global void finish(Database.BatchableContext BC) {
    } 
}