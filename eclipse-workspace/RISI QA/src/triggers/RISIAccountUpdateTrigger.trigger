/**
 * 
 * @author Martin Dolega
 * 
 * Whenever a Salesforce account gets updated, send a call to ND to also update ND account if 
 * account.salesforceId exists
 * 
 */
trigger RISIAccountUpdateTrigger on Account (after update) {

    System.debug('RISIAccountUpdateTrigger called');
   		for (Account a : Trigger.new) {
       		if( !(  Trigger.oldMap.get(a.ID).ND_SECTOR_NAME__c == Trigger.newMap.get(a.Id).ND_SECTOR_NAME__c && 
                Trigger.oldMap.get(a.ID).Sales_Sector__c == Trigger.newMap.get(a.Id).Sales_Sector__c && 
                Trigger.oldMap.get(a.ID).Description == Trigger.newMap.get(a.Id).Description && 
                Trigger.oldMap.get(a.ID).Account_Type_ND_ID__c == Trigger.newMap.get(a.Id).Account_Type_ND_ID__c && 
                Trigger.oldMap.get(a.ID).ParentId == Trigger.newMap.get(a.Id).ParentId && 
                Trigger.oldMap.get(a.ID).OwnerId == Trigger.newMap.get(a.Id).OwnerId && 
                Trigger.oldMap.get(a.ID).Id == Trigger.newMap.get(a.Id).Id && 
                Trigger.oldMap.get(a.ID).HooversId__c == Trigger.newMap.get(a.Id).HooversId__c && 
                Trigger.oldMap.get(a.ID).Website == Trigger.newMap.get(a.Id).Website &&
                Trigger.oldMap.get(a.ID).Name == Trigger.newMap.get(a.Id).Name                
            ))
            {        
                RISIWebServiceCallout.updateNDAccount(a.Id);
            }
        }        
}