/**
 * Description: This is a batch class, updates contact owners. This would be executed by a trigger on
 * Account whenever owner changes.
 * Copyright © Peruto Solutions Inc.
 *
 * Created By           Created Date(mm-dd-yyyy)     version       Changelog
 * Siddharth Pandit      09/02/2016                   1.0         Initial Draft
 **/
global with sharing class UpdateOpptyRecordOwnerBatch implements Database.Batchable<Sobject>, Schedulable, Database.Stateful {
    Set<Id> updatedAccIdSet;
    Set<String> opptyRevType;
    global UpdateOpptyRecordOwnerBatch (Set<Id> accIdSet) {
        updatedAccIdSet = accIdSet;
        opptyRevType = OwnerUpdateTriggerHandler.getRevType ();
    }

    global void execute(SchedulableContext SC) {
        UpdateOpptyRecordOwnerBatch ownerUpdateBatch = new UpdateOpptyRecordOwnerBatch(updatedAccIdSet);
        Database.executebatch(ownerUpdateBatch, 200);
    } 

    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 50000000;
        return Database.getQueryLocator([ SELECT Id, AccountId, Former_Owner__c, Revenue_Type__c,
        										isclosed, OwnerId, Notification_Date__c
                                            FROM Opportunity
                                            WHERE AccountId IN : updatedAccIdSet
                                            LIMIT  :maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
    	List<Opportunity> listOpptyUpdate = new List<Opportunity> ();
        for (Opportunity oppty : (List<Opportunity>) scope) {
        	if (String.isBlank(oppty.Former_Owner__c))
        		oppty.Former_Owner__c = oppty.OwnerId;
        	if (!opptyRevType.contains(oppty.Revenue_Type__c) && !(oppty.isclosed)) {
        		oppty.Notification_Date__c = Datetime.now();
            	oppty.Former_Owner__c = oppty.OwnerId;
        	}
            else
            	oppty.OwnerId = oppty.Former_Owner__c;
            	listOpptyUpdate.add (oppty);
        }
        Database.update (listOpptyUpdate, false);
    }

    global void finish(Database.BatchableContext BC) {
    }
}