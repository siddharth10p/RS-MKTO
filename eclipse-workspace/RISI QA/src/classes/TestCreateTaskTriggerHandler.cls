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
 * LLC TDD (Approach for MQI Follow-Up):
    https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.vjmst4xinbdp
 *
 * LLC TDD - (Approach for Opportunity Enrichment)
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.lqmo1nqi3esa
 *
 * LLC TDD (Approach for Renewal Tasks):
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.puvjvb1kgwgd
 **/
@isTest
private class TestCreateTaskTriggerHandler {

    static testMethod void testTriggerCode() {
        // Create test data
		Test.startTest();
		Profile accManPro = [SELECT Id FROM Profile WHERE Name='RISI Account Manager']; 
		User u = new User(Alias = 'spandt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = accManPro.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName= String.valueOf (Date.today())+'@test.com');

		User newUser = new User(Alias = 'spandt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = accManPro.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName= String.valueOf (Date.today())+'@test2.com');
        insert newUser;

		System.runAs(new User(Id = Userinfo.getUserId())) {
            List<DueDateByLOB__c> listSLACustSetting = new List<DueDateByLOB__c> ();
			listSLACustSetting.add (new DueDateByLOB__c (Days__c = 4, LOB__c = 'Events',
                                                        Name = 'SLA', Task_Priority__c = 'High'));
            listSLACustSetting.add (new DueDateByLOB__c (Days__c = 0, LOB__c = 'Fast Track',
                                                        Name = 'Fast Track', Is_Fast_Track__c = true,
                                                        Task_Priority__c = 'Low'));
            insert listSLACustSetting;
       }
        Test.stopTest();
        System.runAs(u) {

        Account acc = new Account (Name = 'Test');
        insert acc;
        Opportunity opty = new Opportunity (Name = 'Test', CloseDate = Date.today(), 
        									StageName = 'Prospecting', AccountId = acc.Id,
        									Revenue_Type__c = 'Subscription - Renewal',
        									Expire_Date__c = Date.today());
        insert opty;
      	Contact con = new Contact (LastName = 'Test', AccountId = acc.Id,
      	                             Last_Product_Interest__c = 'Events',
      								Last_Product_Interest_Family__c = 'Events', 
      								p2s_base1__LifecycleStage__c = 'Marketing Qualified Instance');
        insert con;
        OpportunityContactRole opptyConRole = 
                new OpportunityContactRole (OpportunityId = opty.Id, ContactId = con.Id,
                                            IsPrimary = true, Role = 'Influencer'
        );
        insert opptyConRole;
        Lead leadInstance = new Lead (LastName = 'Test Lead', Company = 'Perkuto',
                                    Revenue_Type__c = 'Subscription - Renewal',
                                    Last_Product_Interest__c = 'Fast Track',
                                    Last_Product_Interest_Family__c = 'Fast Track',
                                    Last_Lead_Activity_Detail__c = 'Fast Track',
                                    p2s_base1__LifecycleStage__c = 'Marketing Qualified Instance',
                                    Opportunity_Enrichment_Date__c = Datetime.now());
        insert leadInstance;

        Lead leadInstance2 = new Lead (LastName = 'Test Lead', Company = 'Perkuto',
                                      Revenue_Type__c = 'Subscription - Renewal',
                                      Last_Product_Interest__c = 'Events',
                                      Last_Product_Interest_Family__c = 'Events',
                                  p2s_base1__LifecycleStage__c = 'Marketing Qualified Instance');
        insert leadInstance2;
 
        List<p2s_base1__CustomerPath__c> custPathsToInsert = new List<p2s_base1__CustomerPath__c> ();

        p2s_base1__CustomerPath__c cPath = new p2s_base1__CustomerPath__c (
        								p2s_base1__ToLifecycleStage__c = 'Marketing Qualified Instance',
        								p2s_base1__Contact__c = con.Id,
        								p2s_base1__Opportunity__c = opty.Id,
        								Product_Interest__c = 'Fast Track');
        custPathsToInsert.add (cPath);
        p2s_base1__CustomerPath__c cPath2 = new p2s_base1__CustomerPath__c (
        								p2s_base1__ToLifecycleStage__c = 'Marketing Qualified Instance',
        								p2s_base1__Lead__c = leadInstance.Id,
        								Product_Interest__c = 'Events');
        custPathsToInsert.add (cPath2);
        p2s_base1__CustomerPath__c cPath3 = new p2s_base1__CustomerPath__c (
                                        p2s_base1__ToLifecycleStage__c = 'Marketing Qualified Instance',
                                        p2s_base1__Lead__c = leadInstance2.Id,
                                        Product_Interest__c = 'Events');
        custPathsToInsert.add (cPath3);
        
        insert custPathsToInsert;
        con.Opportunity_Enrichment_Date__c = Datetime.now();
        update con;
        leadInstance.Opportunity_Enrichment_Date__c = Datetime.now().addDays (2);
        update leadInstance;

        // Calling invocable method
        RenewalTaskTriggerHandler.createRenewalTasks (new List<Id> {opty.Id});

        List<Task> taskList = [SELECT Id, ActivityDate, WhoId, OwnerId, Priority, Type,
                                      SLA_Violation_Date__c, WhatId
                                FROM Task];
        Integer days = Integer.valueOf (System.Label.Renewal_Task_DueDate);
        for (Task taskInstance : taskList) {
            if (VariableInitializer.STR_LCTRANS.equals (taskInstance.Type) &&
                leadInstance.Id.equals (taskInstance.WhoId)) {
                System.assertEquals('Low', taskInstance.Priority);
                System.assertEquals(UtilityGeneral.skipWeekEnd (Date.today().addDays (0)),
                                    taskInstance.ActivityDate);
                System.assertEquals(UtilityGeneral.skipWeekEnd (Date.today().addDays (1)),
                                    taskInstance.SLA_Violation_Date__c);
                updateTaskOwner (taskInstance, newUser.Id);
            }
            if (VariableInitializer.STR_LCTRANS.equals (taskInstance.Type) &&
                leadInstance2.Id.equals (taskInstance.WhoId)) {
                System.assertEquals('High', taskInstance.Priority);
                System.assertEquals(UtilityGeneral.skipWeekEnd (Date.today().addDays (4)),
                                    taskInstance.ActivityDate);
                System.assertEquals(UtilityGeneral.skipWeekEnd (Date.today().addDays (5)),
                                    taskInstance.SLA_Violation_Date__c);
            }
            if (VariableInitializer.STR_OPPTENRCH.equals (taskInstance.Type) &&
                leadInstance.Id.equals (taskInstance.WhoId)) {
                System.assertEquals('Low', taskInstance.Priority);
                System.assertEquals(UtilityGeneral.skipWeekEnd (Date.today().addDays (0)),
                                    taskInstance.ActivityDate);
                System.assertEquals(UtilityGeneral.skipWeekEnd (Date.today().addDays (1)),
                                    taskInstance.SLA_Violation_Date__c);
            }
            if (RenewalTaskTriggerHandler.STR_TASKTYPE.equals (taskInstance.Type) &&
                opty.Id.equals (taskInstance.WhatId)) {
                System.assertEquals (UtilityGeneral.nextBusinessDay (Date.today().addDays (days)),
                                    taskInstance.ActivityDate);
                Date dateSLA = UtilityGeneral.nextBusinessDay (Date.today().addDays (days +1));
                dateSLA = dateSLA == taskInstance.ActivityDate? dateSLA.addDays (1): dateSLA;
                System.assertEquals (dateSLA, taskInstance.SLA_Violation_Date__c);
                closeTask (taskInstance);
                System.assertEquals (Date.today (), [SELECT Last_Activity_Date__c
                                    FROM Opportunity 
                                    WHERE Id =: opty.Id LIMIT 1]. Last_Activity_Date__c.date());
            }
        }
            Task taskExist = taskList.get (0);
            taskExist.OwnerId = Userinfo.getUserId();
            update taskExist;
            opty.StageName = 'Closed Won - 100%';
            update opty;
            Contact conExist = [SELECT Id, Recycled_Reason__c FROM Contact WHERE Id =: con.Id];
            System.assertEquals (RenewalTaskTriggerHandler.STR_OPTYCLOSE,
                                conExist.Recycled_Reason__c);
        } // End run as
    } // End method

    // A method that covers TaskTriggerHandler code
    private static void updateTaskOwner (Task pTaskInstance, String pOwnId) {
        System.debug ('pTaskInstance ==> '+pTaskInstance);
        System.debug ('pOwnId ==> '+pOwnId);
        if (pTaskInstance != null && String.isNotBlank (pOwnId)) {
            pTaskInstance.OwnerId = pOwnId;
            update pTaskInstance;
        }
    }

    // A method that covers TaskTriggerHandler code
    private static void closeTask (Task pTaskInstance) {
        if (pTaskInstance != null) {
            pTaskInstance.Status = TaskTriggerHandler.STR_CLOSESTATUS;
            update pTaskInstance;
        }
    }
}