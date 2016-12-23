/**
 * Description: When a person is given a contact role on an opportunity, an apex batch will
 * populate the “opportunity” lookup with the ID of that opportunity on the following Customer
 * Path records
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    06/29/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name: TestUpdateOpptyLookupOnCustPathBatch
 **/

global class UpdateOpptyLookupOnCustPathBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 
                            UtilityGeneral.BATCH_START_ROWS_LIMIT;
        return Database.getQueryLocator([SELECT ContactId,
                                                OpportunityId,
                                                Opportunity.IsClosed,
                                                CreatedDate
                                            FROM OpportunityContactRole
                                            WHERE CreatedDate = YESTERDAY
                                            OR CreatedDate = TODAY
                                            LIMIT : maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Map<String, OpportunityContactRole> conOppIdObjMap = new Map<String, OpportunityContactRole> ();
        Set<String> conIdSet = new Set<String> (); // String contactIds which added on Open Oppty
        for (OpportunityContactRole conOppRole : (List<OpportunityContactRole>) scope) {
            conOppIdObjMap.put (conOppRole.ContactId, conOppRole);
            if (!conOppRole.Opportunity.IsClosed)
                conIdSet.add (conOppRole.ContactId);
        } // End for

        // Update customer paths Opporutnity lookup
        UtilityGeneral.updateOpptyLookup (conOppIdObjMap);
        
        // Update contact's lifecycle stage to "In Open Opportunity"
        UtilityGeneral.updateContactLifeCycleStage (conIdSet);
    }

    global void execute(SchedulableContext SC) {
        UpdateOpptyLookupOnCustPathBatch updateCustPath = new UpdateOpptyLookupOnCustPathBatch();
        Id batchprocessid = Database.executeBatch(updateCustPath, 200);
    }

    global void finish(Database.BatchableContext BC) {
    } 
}