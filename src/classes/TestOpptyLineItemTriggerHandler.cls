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
private class TestOpptyLineItemTriggerHandler {
    private static final String SQO_STATUS = 'Sales Qualified Opportunity';

    static testMethod void coverOpptyLineItemTriggerCode () {
        // Create data
        UtilityGeneral.setUpTestData ();
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod2 = new Product2 (Name = 'Test prod', IsActive = true);
        insert prod2;
        PricebookEntry priceEntry = new PricebookEntry (product2Id = prod2.Id, UnitPrice = 300, 
                                                        Pricebook2Id = pricebookId, IsActive = true,
                                                        UseStandardPrice = false);
        insert priceEntry;
        Opportunity oppty = [SELECT Id, p2s_base1__LifecycleStage__c, Revenue_Type__c,
                                    Main_Order__c
                                FROM Opportunity LIMIT 1];
        oppty.Revenue_Type__c = 'Subscription - Renewal';
        oppty.Expire_Date__c = Date.today ().addDays (30);
        oppty.Pricebook2Id = pricebookId;
        update oppty;

        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityId = oppty.Id, Quantity =5,
                                                            PricebookEntryId = priceEntry.Id, TotalPrice =100);
        insert lineItem;

        List<p2s_base1__CustomerPath__c> custPathList = [SELECT p2s_base1__ToLifecycleStage__c,
                                                     p2s_base1__MostRecent__c,
                                                     p2s_base1__FromLifecycleStage__c
                                                FROM p2s_base1__CustomerPath__c
                                                WHERE p2s_base1__Opportunity__c =: oppty.Id
                                                ORDER BY p2s_base1__TransitionDateTime__c DESC
                                                LIMIT 1];
        if (custPathList.size() > 0) {
            System.assertEquals (SQO_STATUS, 
                            custPathList.get(0).p2s_base1__ToLifecycleStage__c);
            System.assertEquals (SQO_STATUS, 
                            custPathList.get(0).p2s_base1__FromLifecycleStage__c);
        } // End if
        oppty.Revenue_Type__c = 'Subscription - Renewal';
        oppty.Expire_Date__c = Date.today().addDays (7);
        update oppty;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contract contractInst = new Contract (AccountId = acc.Id, StartDate = Date.today(),
                                            ContractTerm = 12);
        insert contractInst;
        Order ord = new Order (AccountId = acc.Id, EffectiveDate = Date.today(),
                                ContractId= contractInst.Id, ND_ORDER_ID__c = '123456',
                                Status = 'Draft', Pricebook2Id = pricebookId);
        insert ord;
        OrderItem ordItm = new OrderItem (OrderId = ord.Id, Quantity =3,
                                        PricebookEntryId = priceEntry.Id, UnitPrice =100);
        insert ordItm;
        // Create OpptyProduct that matches the orderitem
        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityId = oppty.Id, Quantity =5,
                                                        PricebookEntryId = priceEntry.Id, TotalPrice =100);
        insert lineItem2;
        System.assertEquals (true, [SELECT Id, Is_Renewal__c FROM OpportunityLineItem
                                            WHERE Id =: lineItem2.Id
                                            LIMIT 1].Is_Renewal__c);
        lineItem2.Quantity = 10;
        update lineItem2;
    } // End method
} // End class