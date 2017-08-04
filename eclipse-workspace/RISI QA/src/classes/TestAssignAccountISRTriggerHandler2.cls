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
 * Liquid Planner: space/118974/projects/show/27074749
 * Copyright © Peruto Solutions Inc.
 */
@isTest (seeAllData = true)
private class TestAssignAccountISRTriggerHandler2 {

    static testMethod void testTriggerCode() {
        // Create test data
        Id risiAccManagerProfileId = UserInfo.getProfileId ();
        Id defultOwner = UserInfo.getUserId ();
        
        profile risiManProfile = [SELECT Id FROM Profile WHERE Name = 'RISI Account Manager' LIMIT 1];
        Profile profileInstance = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User userInstance = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = risiManProfile.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=String.valueOf (Date.today())+'2@testorg.com');
        insert userInstance;
        Set<String> accIdSet = new Set<String> ();
        System.runAs(userInstance ) {
            ISR_Account_Setting__c isrCustSetting = [SELECT RISI_Account_Manager_Profile__c,
                                                             ISR_Profile_Id__c
                                                        FROM ISR_Account_Setting__c
                                                        LIMIT 1];
           // insert isrCustSetting;
        
            Account acc = new Account (Name = 'Test Acc1', Type = 'Prospect');
            insert acc;
            accIdSet.add (acc.Id);

            ISR_Assignment__c isrAssignment = [SELECT Id, Assigned_Account__c 
                                                FROM ISR_Assignment__c
                                                LIMIT 1];
            update isrAssignment;
        }
        
        userInstance.ProfileId = risiManProfile.Id;
        update userInstance;
       
    }
}