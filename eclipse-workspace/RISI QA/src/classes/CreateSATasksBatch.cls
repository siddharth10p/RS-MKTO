/**
 * Description: 25 days after a person transitions to the lifecycle stage of Sales Accepted, if
 * they are still in the lifecycle stage of Sales Accepted, create the following task
 * Technical Description: This is a batch class to create SalesAccepted task after 25 days from lifecycel
 * stage moved into "Sales Accepted". Customer path's transition date field has been used to 
 * calculate the number of days
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    08/18/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name- TestCreateSATasksBatch
 *
 * LLC TDD (Approach for Sales Accepted SAL Task):
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.xr9gmxszel36
 **/
global class CreateSATasksBatch implements Database.Batchable<sObject>, Schedulable{
    private static final String STR_SASTATUS = 'Sales Accepted';
    private static final Integer INT_DAYS = Integer.valueOf (System.Label.SA_Task_Duration);
    private static final Integer INT_NOOFDAYS = Integer.valueOf (System.Label.SATaskBatchFilter_NoOfDays);
    private static final Date DT_PREVDATE = Date.today().addDays (- INT_NOOFDAYS);

    // Start method to fetch records
    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 
                            UtilityGeneral.BATCH_START_ROWS_LIMIT;
        return Database.getQueryLocator([SELECT Id,p2s_base1__Lead__c,
                                               p2s_base1__Contact__c,
                                               p2s_base1__ToLifecycleStage__c,
                                               p2s_base1__TransitionDateTime__c,
                                               Is_SA__c
                                        FROM p2s_base1__CustomerPath__c
                                        WHERE CreatedDate >: DT_PREVDATE
                                        ORDER BY p2s_base1__TransitionDateTime__c DESC
                                        LIMIT : maxRows]);
    } // End method

    // Execute method to process records
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<String> leadOrConIdSet = new Set<String> ();
        for (p2s_base1__CustomerPath__c cpInstance : (List<p2s_base1__CustomerPath__c>) scope) {
            String parentId = String.isNotBlank(cpInstance.p2s_base1__Contact__c) ?
                             cpInstance.p2s_base1__Contact__c: cpInstance.p2s_base1__Lead__c;
            if (parentId != null)
                leadOrConIdSet.add (parentId);
        }
 
        Set<String> parentIdSet = new Set<String> (); // to find most recent customer path
        Map<String, String> cpIdRelObjMap = new Map<String, String> ();
        Map<String, p2s_base1__CustomerPath__c> parentIdCPObjMap = 
                                                new Map<String, p2s_base1__CustomerPath__c> ();
        for (p2s_base1__CustomerPath__c cpInstance : [SELECT Id,p2s_base1__Lead__c,
                                               p2s_base1__Contact__c,
                                               p2s_base1__ToLifecycleStage__c,
                                               p2s_base1__TransitionDateTime__c,
                                               Is_SA__c, OwnerId
                                        FROM p2s_base1__CustomerPath__c
                                        WHERE p2s_base1__Contact__c IN : leadOrConIdSet
                                        OR p2s_base1__Lead__c IN :leadOrConIdSet
                                        ORDER BY p2s_base1__TransitionDateTime__c DESC]) {
            String parentId = String.isNotBlank(cpInstance.p2s_base1__Contact__c) ?
                             cpInstance.p2s_base1__Contact__c: cpInstance.p2s_base1__Lead__c;
            Datetime transDT = (cpInstance.p2s_base1__TransitionDateTime__c).addDays (INT_DAYS);
            System.debug ('cpInstance ==> '+cpInstance);
            System.debug ('transDT ==> '+transDT);
            if (!parentIdSet.contains (parentId) && 
                STR_SASTATUS.equalsIgnoreCase (cpInstance.p2s_base1__ToLifecycleStage__c) &&
                (transDT.date() == Date.today()) && cpInstance.Is_SA__c) {
                cpIdRelObjMap.put (cpInstance.Id, parentId);
                parentIdCPObjMap.put (parentId, cpInstance);
                System.debug ('within the loop ==> ');
             }
             parentIdSet.add (parentId);
        } // End for
        Map<String, Sobject> idObjMasterMap = new Map<String, Sobject> ();
        Map<String, Sobject> idLeadObjMap = // retrieve lead map
                         CreateMQITaskTriggerHandler.retrieveCustPathLeadMap (cpIdRelObjMap);
        if (idLeadObjMap != null)
            idObjMasterMap.putAll (idLeadObjMap);
        Map<String, Sobject> idConObjMap = // retrieve contact map
                            CreateMQITaskTriggerHandler.retrieveCustPathConMap (cpIdRelObjMap);
        if (idConObjMap != null )
            idObjMasterMap.putAll (idConObjMap);
        CreateSalesAcceptedTaskTriggerHandler.createSAtasks (parentIdCPObjMap, idObjMasterMap);
    } // End method

    global void execute(SchedulableContext SC) {
        CreateSATasksBatch createSAtasks = new CreateSATasksBatch();
        Id batchprocessid = Database.executeBatch(createSAtasks, 200);
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
    }
}