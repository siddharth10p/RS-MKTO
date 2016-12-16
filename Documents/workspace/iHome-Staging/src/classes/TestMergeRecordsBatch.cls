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
private class TestMergeRecordsBatch {

    static testMethod void coverMergeRecordsBath() {
        // create test records
        Lead newLead = new Lead (LastName = 'test', Email ='test@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 3);
        insert newLead;
        Task task = new Task (Subject = 'Test Sub', Priority = 'Medium', WhoId = newLead.Id);
        insert task;

        Lead newLead2 = new Lead (LastName = 'test', Email ='test@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead2;

        Lead newLead3 = new Lead (LastName = 'test', Email ='test1@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead3;

        Lead newLead4 = new Lead (LastName = 'test', Email ='test1@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead4;

        Lead newLead5 = new Lead (LastName = 'test', Email ='test2@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead5;

        Lead newLead6 = new Lead (LastName = 'test', Email ='test2@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead6;

        Lead newLead7 = new Lead (LastName = 'test', Email ='test3@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead7;

        Lead newLead8 = new Lead (LastName = 'test', Email ='test3@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead8;

        Lead newLead9 = new Lead (LastName = 'test', Email ='test4@perkuto.com', Company = 'Test',
                                ResellerID__c = 577, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead9;

        Lead newLead10 = new Lead (LastName = 'test', Email ='test4@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead10;

        Lead newLead11 = new Lead (LastName = 'test', Email ='test5@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead11;

        Lead newLead12 = new Lead (LastName = 'test', Email ='test5@perkuto.com', Company = 'Test',
                                ResellerID__c = 0, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 5);
        insert newLead12;

        Lead newLead13 = new Lead (LastName = 'test', Email ='test6@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'Yes', Message__c = 'test',
                                mkto2__Lead_Score__c = 4);
        insert newLead13;

        Lead newLead14 = new Lead (LastName = 'test', Email ='test6@perkuto.com', Company = 'Test',
                                ResellerID__c = 511, ActiveAccount__c = 'No', Message__c = 'test',
                                mkto2__Lead_Score__c = 5);
        insert newLead14;

        Test.startTest();
            MergeRecordsBatch mergeRecords = new MergeRecordsBatch ();
            Id batchprocessid = Database.executeBatch(mergeRecords, 200);
          //  System.assertEquals (null, newLead.Id);
        Test.stopTest();
            System.assertEquals (true, newLead.IsDeleted);
    }
}