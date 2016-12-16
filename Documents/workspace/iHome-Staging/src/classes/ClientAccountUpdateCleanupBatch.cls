/**
 * Description: This apex class will delete all ClientAccountUpdate records where
 * Most_Recent__c = false. This will be scheduled at 2 am to run
 *
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    10/07/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/33432286
 * Test class name-
 **/
global class ClientAccountUpdateCleanupBatch implements Database.Batchable<sObject>, Schedulable{

    // Start method to fetch records
    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 
                            UtilityGeneral.BATCH_START_ROWS_LIMIT;
        return Database.getQueryLocator([SELECT Id
                                        FROM Client_Account_Update__c
                                        WHERE Most_Recent__c = false
                                        LIMIT : maxRows]);
    } // End method

    // Execute method to process records
    global void execute(Database.BatchableContext BC, List<Client_Account_Update__c> scope) {
        Database.delete (scope);
    } // End method

    global void execute(SchedulableContext SC) {
        ClientAccountUpdateCleanupBatch recordCleanupbatch = new ClientAccountUpdateCleanupBatch();
        Id batchprocessid = Database.executeBatch(recordCleanupbatch, 200);
    }

    // Finish method
    global void finish(Database.BatchableContext BC) {
    }
}