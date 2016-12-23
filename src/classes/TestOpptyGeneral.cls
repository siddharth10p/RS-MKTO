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
private class TestOpptyGeneral {
    // A method that creates test records
    private static void createTestData () {
        // Create data
        Account acc = new Account (Name = 'Test Account');
        insert acc;

        Contact con = new Contact (LastName = 'Test Con', AccountId = acc.Id,
                                    p2s_base1__LifecycleStage__c = 'Sales Accepted');
        insert con;

        Opportunity oppty = new Opportunity (Name='Test Opty', CloseDate = Date.today(),
                            StageName = 'Qualification', AccountId = acc.Id);
        insert oppty;
    }
    static testMethod void testFreeTrialCode() {
        // TO DO: implement unit test
        createTestData ();
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        OpptyGeneral.createFreeTrial (oppty.Id);
        List<FreeTrialOpptySetting__c> freeTrialOpptyList = new List<FreeTrialOpptySetting__c> ();
        freeTrialOpptyList.add (new FreeTrialOpptySetting__c (
                                Name= '1', Api_Name__c = 'Amount', Default_Value__c ='0'));
        freeTrialOpptyList.add (new FreeTrialOpptySetting__c (
                                Name= '2', Api_Name__c = 'CloseDate', Default_Value__c ='30'));
        freeTrialOpptyList.add (new FreeTrialOpptySetting__c (
                    Name= '3', Api_Name__c = 'Revenue_Type__c', Default_Value__c ='Free Trial'));
        freeTrialOpptyList.add (new FreeTrialOpptySetting__c (
                                Name= '4', Api_Name__c = 'StageName',
                                Default_Value__c ='Prelim Approval'));
        insert freeTrialOpptyList;
        // Call webservice method
        OpptyGeneral.createFreeTrial (oppty.Id);

        // Assertion
        Opportunity opptyNew = [SELECT Id, Related_Opportunity__c
                                FROM Opportunity
                                WHERE Related_Opportunity__c =: oppty.Id
                                LIMIT 1];
       System.assertEquals (oppty.Id, opptyNew.Related_Opportunity__c);
       System.assertEquals (opptyNew.Id, [SELECT Id, Related_Opportunity__c
                                FROM Opportunity
                                WHERE Related_Opportunity__c =: opptyNew.Id
                                LIMIT 1].Related_Opportunity__c);
    } // End method

    // A method to cover OpptyNeedAttentionController code
    static testMethod void testOpptyNeedAttentionController () {
        // Create test data
        createTestData ();
        Opportunity oppty = [SELECT Id, CloseDate, Name, Last_Activity_Date__c 
                                FROM Opportunity LIMIT 1];
        oppty.CloseDate = Date.today ().addDays (30);
        oppty.Last_Activity_Date__c = Date.today().addDays (-9);
        oppty.OwnerId = UserInfo.getUserId();
        update oppty;
        System.debug ('oppty ==> '+oppty);
        Test.startTest ();
            OpptyNeedAttentionController opptyConr = new OpptyNeedAttentionController ();
            List<OpptyNeedAttentionController.OpptyCritical> opptyWrp = opptyConr.getOpptyList ();
            System.debug ('opptyWrp ==> '+opptyWrp);
        Test.stopTest ();
        // Assertion
        System.assertEquals (oppty.Name, opptyWrp.get (0).objName);
        System.assertEquals ('/'+oppty.Id, opptyWrp.get (0).objUrl);
    }
}