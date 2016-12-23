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
 * Author            Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit   05/27/2016                   1.0      Initial Draft
 * Siddharth Pandit   16/11/2016                   1.1      Removed SeeAllData = true
 * Liquid Planner: space/118974/projects/show/27074749
 */
@isTest
private class TestAssignAccountISRTriggerHandler {

    static testMethod void testTriggerCode() {
        // Create test data
        Id risiAccManagerProfileId = UserInfo.getProfileId ();
        Id defultOwner = UserInfo.getUserId ();

        profile risiManProfile = [SELECT Id FROM Profile
                                    WHERE Name = 'RISI Account Manager' LIMIT 1];
        Profile isrProfile = [SELECT Id FROM Profile
                                    WHERE Name='RISI Inside Sales Representative' LIMIT 1];

        //Test.startTest();
        User userInstance = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = risiManProfile.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=String.valueOf (Date.today())+'2@testorg.com');
        insert userInstance;
        System.debug ('userInstance ==> '+userInstance);

        User u = new User(Alias = 'spandt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = isrProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName= String.valueOf (Date.today())+'23@test.com');
        insert u;
        ISR_Account_Setting__c isrCustSetting;
        System.runAs(new User(Id = Userinfo.getUserId ())) { // Setup data insert

            isrCustSetting =
                                new ISR_Account_Setting__c (Default_OwnerId__c = defultOwner,
                                            RISI_Account_Manager_Profile__c = risiManProfile.Id,
                                            ISR_Profile_Id__c = isrProfile.Id,
                                            Account_Trigger_On__c = true,
                                            ISR_Assignment_Trigger_On__c = true);
           insert isrCustSetting;
           System.debug ('isrCustSetting ==> '+isrCustSetting);
        }

        Set<String> accIdSet = new Set<String> ();
        System.runAs(userInstance) {
        Test.startTest();
        Account acc = new Account (Name = 'Test', OwnerId = userInstance.Id);
        insert acc;
        System.debug ('acc ==> '+acc);
            accIdSet.add (acc.Id);
            List<ISR_Assignment__c> isrAssignmentList = [SELECT Id, Assigned_Account__c, OwnerId
                                                FROM ISR_Assignment__c
                                                WHERE Assigned_Account__c =: acc.Id];
            if (!isrAssignmentList.isEmpty()) {
            System.assertEquals (isrCustSetting.Default_OwnerId__c,
                                    isrAssignmentList.get (0).OwnerId);
            isrAssignmentList.get (0).OwnerId = u.Id;
            update isrAssignmentList;
            System.assertEquals (u.Id, [SELECT Id, Assigned_ISR__c
                                            FROM Account
                                            WHERE Id =:acc.Id].Assigned_ISR__c);
            }
            // Cover batch class
            UpdateAccountISRBatch updateAccountISR = new UpdateAccountISRBatch (accIdSet);
            Database.executebatch(updateAccountISR, 200);
        Test.stopTest();
        }
    } // End method

    // A method that call user trigger. Using seeAllData = true to resolve mixed DML exception
  //  @isTest (seeAllData=true)
    static testMethod void coverUserTrigger () {
        profile risiManProfile = [SELECT Id FROM Profile
                                    WHERE Name = 'RISI Account Manager' LIMIT 1];
        Profile isrProfile = [SELECT Id FROM Profile
                                    WHERE Name='RISI Inside Sales Representative' LIMIT 1];
        System.runAs(new User(Id = Userinfo.getUserId ())) { // Setup data insert

        ISR_Account_Setting__c isrCustSetting =
                         new ISR_Account_Setting__c (Default_OwnerId__c = Userinfo.getUserId (),
                                            RISI_Account_Manager_Profile__c = risiManProfile.Id,
                                            ISR_Profile_Id__c = isrProfile.Id,
                                            Account_Trigger_On__c = true,
                                            ISR_Assignment_Trigger_On__c = true);
            insert isrCustSetting;
            Account acc = new Account (Name = 'Test');
            insert acc;
        System.debug('acc ==> '+acc);
        } // End run as
        Test.startTest ();
        List<Account> accInstList = [SELECT Id, OwnerId FROM Account
                            WHERE Owner.ProfileId <>: risiManProfile.Id
                            LIMIT 1];
        System.debug('accInstList ==> '+accInstList);
        if (!accInstList.isEmpty()) {
            User usr = [SELECT Id, ProfileId FROM User 
                            WHERE Id =:accInstList.get (0).OwnerId LIMIT 1];
            //usr.ProfileId = risiManProfile.Id;
            update usr;
        } // End if
        Test.stopTest ();
    }
}