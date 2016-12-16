/**
 * Description: Sid will add
 **/
public with sharing class UtilityGeneral {
    
    public static Integer BATCH_START_ROWS_LIMIT = 50000000; // Used in batch
    // A method that returns mapping custom setting records
    public static List<IntegrationObjMapping__c> getMappingObj () {
        return IntegrationObjMapping__c.getall().values();
    }

    // A method that builds query for client obj
    public static String retrieveMasterQuery () {
        Set<String> uniqueField = new Set<String> ();
        String queryStr = 'SELECT ';
        for (IntegrationObjMapping__c intObj : getMappingObj ()) {
            queryStr += intObj.Is_Client_Account__c ?
                        'Client_Account__r.'+intObj.Client_Obj_Field__c :
                        intObj.Client_Obj_Field__c;
            queryStr += ', ';
        } // End for
        queryStr.removeEndIgnoreCase(', ');
        queryStr += 'Id, Client_Account__c, Contact__c FROM Client_Account_Contact_Role__c ';
        System.debug ('queryStr ==> '+queryStr);
        return queryStr;
    }

    // A method that returns list of tracking fields
    public static List<TrackingFieldList__c> getTrackingFields () {
        return TrackingFieldList__c.getall().values();
    }
}