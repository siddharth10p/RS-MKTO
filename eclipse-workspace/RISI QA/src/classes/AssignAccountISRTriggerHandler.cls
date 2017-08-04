/**
 * Description: This is a handler class that is used on account trigger to assign ISR.
 *
 * Author            Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit   05/25/2016                   1.0      Initial Draft
 * Liquid Planner: space/118974/projects/show/27074749
 * Copyright © Peruto Solutions Inc.
 *
 * TDD - https://docs.google.com/document/d/1UtHDAVaeg2Ewlzf_czJlKiAz2duKA7odFgm4Ud6x6p0/edit#heading=h.oftlwkjlqvmb
 **/
public class AssignAccountISRTriggerHandler {
	
	// Get custom setting data
	public static ISR_Account_Setting__c getISRCustSetting () {
		return ISR_Account_Setting__c.getInstance();
	}
	
	public static Set<String> getUserIds (String profileId) {
		if (profileId == null) return null;
		Set<String> userIdSet = new Set<String> ();
		for (User userInstance : [SELECT Id FROM User
									WHERE ProfileId = : profileId]) {
			userIdSet.add (userInstance.Id);
		} // End for
		return userIdSet;
	} // End method
	
	// A method to create Account ISR records when a user profile is changes
	public static void insertNewISRs (List<Sobject> pObjList) {
		if (pObjList != null && pObjList.size() > 0) {
			ISR_Account_Setting__c isrAcc = getISRCustSetting ();
			if (pObjList.getSObjectType().getDescribe().getName().equalsIgnoreCase ('user')) {
				if (isrAcc != null && isrAcc.RISI_Account_Manager_Profile__c != null) {
					UpdateAccountISRBatch updateAccIsrBatch = 
						new UpdateAccountISRBatch (
									getAccListIsrNotExist (pObjList, isrAcc.RISI_Account_Manager_Profile__c).keySet());
					Database.executebatch(updateAccIsrBatch, 200);
				}
			}
		}
	}

	// A method to create new ISR records
	public static void createNewISRs (List<Sobject> objList) {
		if (objList != null && objList.size() > 0) {
			List<ISR_Assignment__c> listISRAccToInsert = 
													new List<ISR_Assignment__c> ();
			ISR_Account_Setting__c isrAcc = getISRCustSetting ();
			if (isrAcc != null && isrAcc.RISI_Account_Manager_Profile__c != null) {
				Set<String> userIdSet = getUserIds (isrAcc.RISI_Account_Manager_Profile__c);
				Set<String> accIdSet = new Set<String> ();
				for (Sobject accObj : objList) {
					accIdSet.add (String.valueOf (accObj.get ('Id')));
				}
				Map<String, Sobject> objMapWithoutChild = getAccMapToCreateISR (null, accIdSet);
				if (objMapWithoutChild != null) {
					for (Sobject objInstance : objMapWithoutChild.values()) {
						if (userIdSet.contains (String.valueOf (objInstance.get ('OwnerId')))) {
							ISR_Assignment__c isrAccAssignment = new ISR_Assignment__c ();
							isrAccAssignment.Assigned_Account__c = String.valueOf (objInstance.get ('Id'));
							if (isrAcc != null && isrAcc.Default_OwnerId__c != null)
								isrAccAssignment.ownerId = isrAcc.Default_OwnerId__c;
							listISRAccToInsert.add (isrAccAssignment);
						}
					} // End for
				}
			} // End if

			if (listISRAccToInsert.size() > 0)
				insert listISRAccToInsert;
		} // End if
	} // End method
	
	// A method to check if there is related ISR_Account_Setting__c and return accounts that has no related
	// ISR_Account_Setting__c records
	public static Map<String, Sobject> getAccMapToCreateISR (Set<String> userIdSet, Set<String> accIdSet) {
		if (userIdSet == null && accIdSet == null) return null;
		String whereCls = userIdSet == null? ' WHERE Id IN : accIdSet' : ' WHERE OwnerId IN : userIdSet';
		Map<String, Sobject> objMapToReturn = new Map<String, Sobject> ();
		String queryStr = 'SELECT Id, OwnerId,'+
							' (SELECT Id ' +
							' FROM ISR_Assignments__r)' +
							' FROM Account' + whereCls;
		System.debug ('queryStr ==> '+queryStr);
		for (Account accInstance : Database.query (queryStr)) {
			if (!(accInstance.ISR_Assignments__r.size() > 0))
			objMapToReturn.put (accInstance.Id, accInstance);
		}
		return objMapToReturn;
	} // End method

	// A method to create ISR when user is updated
	public static Map<String, Sobject> getAccListIsrNotExist (List<Sobject> userList, Id accManagerProId) {
		if (userList == null || accManagerProId == null) return null;
		Set<String> userIdSet = new Set<String> ();
		for (Sobject userObj : userList) {
			if (accManagerProId == String.valueOf (userObj.get ('ProfileId')))
				userIdSet.add (String.valueOf (userObj.get ('Id')));
		}
		return getAccMapToCreateISR (userIdSet, null); //accIdSet;
	} // End method
	
	// A method to update account assign ISR field
	public static void updateAccountISR (List<Sobject> objList) {
		Map<String, String> accIdIsrIdMap = new Map<String, String> ();
		if (objList != null && objList.size() > 0) {
			ISR_Account_Setting__c isrAcc = getISRCustSetting (); // Get custom setting data
			for (Sobject objInstance : objList) {
				if (!accIdIsrIdMap.containsKey (String.valueOf (objInstance.get ('Assigned_Account__c'))))
					accIdIsrIdMap.put (String.valueOf (objInstance.get ('Assigned_Account__c')), 
										String.valueOf (objInstance.get ('OwnerId')));
			} // End for
			if (isrAcc != null && isrAcc.ISR_Profile_Id__c != null) {
				Map<Id, User> userIdObjMap = new Map<Id, User> ([SELECT Id, ProfileId
																FROM User
																WHERE Id IN :accIdIsrIdMap.values()
																AND ProfileId = :isrAcc.ISR_Profile_Id__c]);
				List<Account> listAccToUpdate = new List<Account> ();
				for (Account accInstance : [SELECT Id, Assigned_ISR__c
											FROM Account
											WHERE Id IN : accIdIsrIdMap.keySet()]) {
					if (userIdObjMap.containsKey (accIdIsrIdMap.get (accInstance.Id)) &&
						accIdIsrIdMap.get (accInstance.Id) != accInstance.Assigned_ISR__c) {
						accInstance.Assigned_ISR__c = accIdIsrIdMap.get (accInstance.Id);
						listAccToUpdate.add (accInstance);
					} // End if
				} // End for
				if (listAccToUpdate.size() > 0)
					update listAccToUpdate;
			} // End if
		} // End if
	} // End method
} // End class