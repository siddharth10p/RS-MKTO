/**
 * Description: This is a trigger handler class which updates Contacts of Opportunities owner based 
 * off the related Account owner.
 *
 * Author           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      02/08/2016               1.0         Initial Draft
 * Siddharth Pandit      04/12/2016               1.1         Added contact trigger functionality
 *
 **/
public with sharing class OwnerUpdateTriggerHandler {
    // Values to filter Oppty records
    public static Set<String> getRevType () {
        return new Set<String> {'Conf. Attendee',
                                'Conf. Sponsorship',
                                'Online Marketing',
                                'Print Marketing'};
    }

    // A method that triggers batch apex when account owner changes
    public static void updateChildRecOwner (Map<Id, Account> oldAccMap, Map<Id, Account> newAccMap) {
       Set<Id> accIdsSet = new Set<Id> ();
       for (Id accId : oldAccMap.keySet()) {
           // if Account owner is changed
           if (oldAccMap.get (accId).OwnerId != newAccMap.get (accId).OwnerId) {
               accIdsSet.add (accId);
           } // End if
       } // End for

       // Calling batch apex
       System.debug ('AccIdSet ==> '+accIdsSet);
       if (accIdsSet.size() > 0) {
           if ([SELECT count()    // Validating the running batch count 
                FROM AsyncApexJob // only calling the batch if the running 
                WHERE JobType='BatchApex' // batch count is less than 5
                AND (Status = 'Processing' OR Status = 'Preparing')] < 5) {
                ID updateRecords = 
                    Database.executeBatch(new UpdateOpptyRecordOwnerBatch(accIdsSet), 200); 
            } else {
               //schedule this same schedulable class again in 30 mins
               UpdateOpptyRecordOwnerBatch schB = new UpdateOpptyRecordOwnerBatch(accIdsSet);
               Datetime dt = Datetime.now() + (0.024305); // i.e. 30 mins
               String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
               Id schedId = System.Schedule('UpdateConRecordOwnerBatch'+timeForScheduler,
                               timeForScheduler,schB);
            }
       }
       updateContactOwner (accIdsSet); // Calling contact trigger to update ownership
    }

    public static Boolean applyOpptyConditions (Sobject opptyObj) {
        if (!Boolean.valueOf (opptyObj.get ('isclosed')) && 
                !getRevType().contains (String.valueOf (opptyObj.get ('Revenue_Type__c'))))
            return true;
            return false;
    }

    public static void updateContactOwner (Set<Id> accIdSet) {
        if (accIdSet.size() > 0) // Dummy update on related contacts to change ownership by contact trigger
        update [SELECT Id FROM Contact WHERE AccountId IN :accIdSet];
    } // End method
    
    // A method to update Contact or Opportunity owner when they are created of updated
    public static void updateRecordOwner (List<Sobject> objList) {
        Set<String> accIdsSet = new Set<String > ();
        for (Sobject objInstance : objList) {
            if (objInstance.get ('AccountId') != null) {
             //   if (!objInstance.getSObjectType().getDescribe().getName().equalsIgnoreCase ('opportunity'))
              ////      accIdsSet.add (String.valueOf (objInstance.get ('AccountId')));
              //   else if (applyOpptyConditions (objInstance)) {
                    accIdsSet.add (String.valueOf (objInstance.get ('AccountId')));
              //  }
            } // End if
        } // End for

        Map<String, String> accOwnerIdMap = new Map< String, String> ();
        for (Account accInstance : [SELECT Id, OwnerId
                                    FROM Account
                                    WHERE Id IN :accIdsSet]) {
            accOwnerIdMap.put (accInstance.Id, accInstance.OwnerId);
        } // End for

        for (Sobject objInstance : objList) {
            if (accOwnerIdMap.containsKey (String.valueOf (objInstance.get ('AccountId')))) {
                if (!objInstance.getSObjectType().getDescribe().getName().equalsIgnoreCase ('opportunity'))
                    objInstance.put ('OwnerId', 
                        accOwnerIdMap.get (String.valueOf (objInstance.get ('AccountId'))));
                else if (applyOpptyConditions (objInstance)) {
                    objInstance.put ('OwnerId', 
                        accOwnerIdMap.get (String.valueOf (objInstance.get ('AccountId'))));
                }
            }
                
        } //End for
    } // End method
} // End class