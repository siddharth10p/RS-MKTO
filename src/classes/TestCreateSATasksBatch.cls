/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 **/
@isTest
private class TestCreateSATasksBatch {
    private static final Integer INT_DAYS = Integer.valueOf (System.Label.SA_Task_Duration);

    static testMethod void testBatchCode() {
         // Create data
        Account acc = new Account (Name = 'Test Account');
        insert acc;

        Contact con = new Contact (LastName = 'Test Con', AccountId = acc.Id,
                                    p2s_base1__LifecycleStage__c = 'Sales Accepted');
        insert con;
        System.debug ('con ==> '+con);
        p2s_base1__CustomerPath__c custPath = new p2s_base1__CustomerPath__c (
                                            p2s_base1__Contact__c = con.Id,
                                            p2s_base1__ToLifecycleStage__c = 'Sales Accepted',
                                            p2s_base1__TransitionDateTime__c = 
                                                Datetime.now(),
                                            Is_SA__c = true);
        insert custPath;
        Integer days = Integer.valueOf (System.Label.SA_Task_DueDate);
        Test.startTest();
        custPath.p2s_base1__TransitionDateTime__c = 
                custPath.p2s_base1__TransitionDateTime__c.addDays (-INT_DAYS);
        update custPath;

        CreateSATasksBatch createSATask = new CreateSATasksBatch();
        string schTime = '0 0 * * 1-12 ? *';
        system.schedule('CreateSATasksBatch', schTime, createSATask);
        Database.executeBatch (createSATask, 200);
        Test.stopTest();
        // Assertion
        for (Task taskInstance : [SELECT Type, WhoId, ActivityDate
                                    FROM Task
                                    WHERE WhoId =: con.Id]) {
            System.assertEquals (CreateSalesAcceptedTaskTriggerHandler.STR_TASKTYPE,
                                    taskInstance.Type);
            System.assertEquals (UtilityGeneral.nextBusinessDay (Date.today().addDays (days)),
                                    taskInstance.ActivityDate);
        }
    } // End method
}