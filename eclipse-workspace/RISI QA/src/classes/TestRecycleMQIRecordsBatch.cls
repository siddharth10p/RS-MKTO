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
 */
@isTest
private class TestRecycleMQIRecordsBatch {

    static testMethod void coverBatchCode () {
        // Create test records
        Account acc = new Account (Name = 'Test Acc');
        insert acc;
        Contact con = new Contact (LastName = 'Test Con', Email = 'test@perkuto.com',
                                 p2s_base1__LifecycleStage__c = 'Marketing Qualified Instance',
                                 AccountId = acc.Id);
        insert con;
        System.debug ('con ==> '+con);
        Lead ld = new Lead (LastName = 'Test Lead', Email='test10@perkuto.com',
                             Company = 'Test Perkuto', 
                             p2s_base1__LifecycleStage__c = 'Marketing Qualified Instance');
        insert ld;
        System.debug ('ld ==> '+ld);
        List<p2s_base1__CustomerPath__c> cpList =
                                            new List<p2s_base1__CustomerPath__c> ();
        p2s_base1__CustomerPath__c cpNew = new p2s_base1__CustomerPath__c ();
        cpNew.p2s_base1__TransitionDateTime__c =
                                Date.today ().addDays (-RecycleMQIRecordsBatch.INT_NUMDAYS);
        cpNew.p2s_base1__Lead__c = ld.Id;
        cpNew.p2s_base1__MostRecent__c = true;
        cpNew.p2s_base1__ToLifecycleStage__c = 'Marketing Qualified Instance';
        cpList.add (cpNew);
        p2s_base1__CustomerPath__c cpNew2 = new p2s_base1__CustomerPath__c ();
        cpNew2.p2s_base1__TransitionDateTime__c =
                                Date.today ().addDays (-RecycleMQIRecordsBatch.INT_NUMDAYS);
        cpNew2.p2s_base1__Contact__c = con.Id;
        cpNew2.p2s_base1__MostRecent__c = true;
        cpNew2.p2s_base1__ToLifecycleStage__c = 'Marketing Qualified Instance';
        cpList.add (cpNew2);
        insert cpList;
        System.debug ('cpList ==> '+cpList);

        Test.startTest();
            RecycleMQIRecordsBatch recycleMQIRecs = new RecycleMQIRecordsBatch ();
            string schTime = '0 0 * * 1-12 ? *';
            system.schedule('RecycleMQIRecordsBatch', schTime, recycleMQIRecs);
            Database.executeBatch (recycleMQIRecs, 200);
        Test.stopTest();

        // Assertion
        Lead aLead = [SELECT p2s_base1__LifecycleStage__c, Recycled_Reason__c
                        FROM Lead WHERE Id =: ld.Id LIMIT 1 ];
        Contact aCon = [SELECT p2s_base1__LifecycleStage__c, Recycled_Reason__c
                        FROM Contact WHERE Id = :con.Id LIMIT 1 ];

        if (aLead != null) {
            System.assertEquals (RecycleMQIRecordsBatch.STR_RECYCLED,
                                aLead.p2s_base1__LifecycleStage__c);
            System.assertEquals (RecycleMQIRecordsBatch.STR_RECYCLEDRSN,
                                aLead.Recycled_Reason__c);
        }
        if (aCon != null) {
            System.assertEquals (RecycleMQIRecordsBatch.STR_RECYCLED,
                                aCon.p2s_base1__LifecycleStage__c);
            System.assertEquals (RecycleMQIRecordsBatch.STR_RECYCLEDRSN,
                                aCon.Recycled_Reason__c);
        }
    }
}