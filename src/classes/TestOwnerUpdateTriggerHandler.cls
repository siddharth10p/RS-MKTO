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
private class TestOwnerUpdateTriggerHandler {

	static testMethod void coverTriggerCode () {
		// Create account data
		Id currentUserId =  UserInfo.getUserId ();
		List<User> userExistList = [SELECT Id 
                                        FROM User 
                                        WHERE IsActive = true 
                                        AND Profile.Name = 'System Administrator'
                                        AND Id != :currentUserId
                                        LIMIT 1];
        // Creating maps to call the trigger method manually due to webservice callout error
        // There is one other trigger on account update that makes webservice callout and hence
        // can't update the account and calling the method manually
        Map<Id, Account> newAccMap = new Map<Id, Account> ();
        Map<Id, Account> oldAccMap = new Map<Id, Account> ();
		Account acc = new Account (Name = 'Test', AnnualRevenue = 1000, 
                                   OwnerId = currentUserId);
		insert acc;
        newAccMap.put(acc.Id, acc);
		Account acc2 = new Account (Name = 'Test', AnnualRevenue = 1000, 
                                   OwnerId = userExistList.get(0).Id);
		insert acc2;
        oldAccMap.put(acc.Id, acc2);
		Contact con = new Contact (LastName = 'Test', AccountId = acc.Id);
		insert con;

		Opportunity oppty = new Opportunity (Name = 'TestOppty', StageName = 'Prospecting',
											CloseDate = Date.today(), AccountId = acc.Id,
											Revenue_Type__c = 'Subscription - New');
		insert oppty;
        Test.startTest();
        OwnerUpdateTriggerHandler.updateChildRecOwner(newAccMap, oldAccMap);
		Account accExist = [SELECT OwnerId FROM Account LIMIT 1];
		System.assertEquals (accExist.OwnerId, [SELECT OwnerId FROM Contact LIMIT 1].OwnerId);
		System.assertEquals (accExist.OwnerId, [SELECT OwnerId FROM Opportunity LIMIT 1].OwnerId);

		// Covering batch code
		Set<Id> accIdSet = new Set<Id> {acc.Id};
		UpdateOpptyRecordOwnerBatch updateRecOwnerBatch = new UpdateOpptyRecordOwnerBatch (accIdSet);
		Database.executeBatch(updateRecOwnerBatch, 2);
		system.schedule('test updateRecOwnerBatch', '0 10 10 * * ? *', updateRecOwnerBatch);
		Test.stopTest();
	}
}