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
private class TestTaskDetailPageController {

    static testMethod void coverTaskDetailPageController() {
        // Create test data
        createLeadTask ();
        Task taskInstance = [SELECT Id FROM Task LIMIT 1];
        Test.startTest ();
        PageReference pageRef = Page.TaskDetailPage;
        Test.setCurrentPage(pageRef);
        exectueLeadTask (taskInstance, false);
        Test.stopTest ();
    }

    static testMethod void coverTaskDetailPageContrlr() {
        // Create test data
        createConTask ();
        Task taskInstance = [SELECT Id FROM Task LIMIT 1];
        Test.startTest ();
        PageReference pageRef = Page.TaskDetailPage;
        Test.setCurrentPage(pageRef);
        exectueLeadTask (taskInstance, true);
        Test.stopTest ();
    }

    static testMethod void coverTaskDetailPageContrlrAcc() {
        // Create test data
        createAccTask ();
        Task taskInstance = [SELECT Id FROM Task LIMIT 1];
        Test.startTest ();
        PageReference pageRef = Page.TaskDetailPage;
        Test.setCurrentPage(pageRef);
        exectueLeadTask (taskInstance, false);
        Test.stopTest ();
    }

    // A method that creates task for lead
    private static void createLeadTask () {
        Lead leadInstance = new Lead (LastName = 'Test Lead', Company = 'Perkuto',
                                    Revenue_Type__c = 'Subscription - Renewal',
                                    Last_Product_Interest__c = 'Fast Track',
                                    Last_Product_Interest_Family__c = 'Fast Track',
                                    Last_Lead_Activity_Detail__c = 'Fast Track',
                                    p2s_base1__LifecycleStage__c = 'Marketing Qualified Instance',
                                    Opportunity_Enrichment_Date__c = Datetime.now());
        insert leadInstance;
        Task taskInstance = new Task (Subject = 'Call', WhoId = leadInstance.Id);
        insert taskInstance;
    }

    // A method that creates task for Contact
    private static void createConTask () {
        Account acc = new Account (Name = 'Test Account');
        insert acc;

        Contact con = new Contact (LastName = 'Test Con', AccountId = acc.Id,
                                 p2s_base1__LifecycleStage__c = VariableInitializer.MQI_STATUS);
        insert con;
        Task taskInstance = new Task (Subject = 'Call', WhoId = con.Id, WhatId = acc.Id);
        insert taskInstance;
    }

    // A method that creates task for Contact
    private static void createAccTask () {
        Account acc = new Account (Name = 'Test Account');
        insert acc;

        Contact con = new Contact (LastName = 'Test Con', AccountId = acc.Id,
                                 p2s_base1__LifecycleStage__c = VariableInitializer.MQI_STATUS);
        insert con;
        Task taskInstance = new Task (Subject = 'Call', WhatId = acc.Id);
        insert taskInstance;
    }

    // A method that creates task for Contact
    private static void createOpptyTask () {
        Account acc = new Account (Name = 'Test Account');
        insert acc;

        Opportunity oppty = new Opportunity (Name= 'Test', AccountId = acc.Id,
                StageName='Qualified', CloseDate = Date.today());
        insert oppty;
        Contact con = new Contact (LastName = 'Test Con', AccountId = acc.Id,
                                 p2s_base1__LifecycleStage__c = VariableInitializer.MQI_STATUS);
        insert con;
        Task taskInstance = new Task (Subject = 'Call', WhatId = oppty.Id);
        insert taskInstance;
    }

    // A method that calls all the actions based off a Contact task
    private static void exectueLeadTask (Task taskInstance, Boolean isCon) {
        TaskDetailPageController taskContrlr =
            new TaskDetailPageController (new ApexPages.Standardcontroller(taskInstance));
        taskContrlr.getPersonalInfo ();
        taskContrlr.getCompanyInfo ();
        taskContrlr.setRecycleMQI ();
        taskContrlr.setDisQualify ();
        taskContrlr.cancel ();
        taskContrlr.saveRecord ();
        taskContrlr.redirectToHome ();
        taskContrlr.editTask ();
        taskContrlr.returntoTask ();
        taskContrlr.createTask ();
        taskContrlr.createEvent ();
        taskContrlr.saveTask ();
        taskContrlr.acceptMQI ();
        taskContrlr.saveAndNew ();

        if (isCon) {
            taskContrlr.getOpnOptyBtn ();
            taskContrlr.createOpptyConRole ();
            taskContrlr.showOpenOppty ();
        }
        // Button rendered or not methods
        taskContrlr.getDisQlfBtn ();
        taskContrlr.getReclBtn ();
        taskContrlr.getMQIBtn ();
        taskContrlr.createOppty ();
        taskContrlr.getTaskType ();
        taskContrlr.getTIReadOnlyFields ();
        taskContrlr.getPIReadOnlyFields ();
        taskContrlr.getCIReadOnlyFields ();
    }// End method

}