/**
 * Description- This is trigger handler class to create Client_Account_Update__c 
 *
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    10/06/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/33432286
 * Test class name-
 **/
public with sharing class ClientAccountTriggerHandler {
    // static final variables
    private static final String STR_UNIQKEY = 'Unique_Key__c';
    private static final String STR_RECENT = 'Most_Recent__c'; 
    private static final String STR_CHILDNAME = 'Client_Account__r';

    // A method that creates new records based off Client Account obj update
    public static void createIntegrationObj (Map<Id, Client_Account__c> mapNewClientAcc, 
                                            Map<Id, Client_Account__c> mapOldClientAcc) {
      //  createIntegrationObj (Map<Id, Client_Account__c> mapNewClientAcc, 
      //                      Map<Id, Client_Account__c> mapOldClientAcc, false); // Create integration obj method
    }// End method

    // A method that invokes when a Client Account Contact role object update
    public static void createIntObj (Map<Id, Client_Account_Contact_Role__c> mapNewClientAccCon, 
                                Map<Id, Client_Account_Contact_Role__c> mapOldClientAccCon) {
        Set<String> clientAccConIdSet = new Set<String> ();
        for (Client_Account_Contact_Role__c clientAccConNew : mapNewClientAccCon.values()) {
            clientAccConIdSet.add (clientAccConNew.Id);
        } // End for
       // createIntegrationObj (clientAccConIdSet, true); // Create integration obj method
    } // End method

    // A method that returns final query with where clause
    private static String getFinalQuery (Boolean isAccConObj) {
        String finalQuery = UtilityGeneral.retrieveMasterQuery ();
        if (isAccConObj) finalQuery += 'WHERE Id IN: objIdSet';
        else finalQuery += 'WHERE Client_Account__c IN: objIdSet';
        return finalQuery;
    }
    // A method that creates integration object records
    public static void createIntegrationObj (Map<Id, Sobject> newObjMap,
                                            Map<Id, Sobject> oldObjMap,
                                            Boolean isAccConRole) {
        Set<String> uniqueKeySet = new Set<String> ();
        Set<Id> objIdSet = newObjMap.keySet ();
        String queryStr =  getFinalQuery (isAccConRole);
        /*queryStr += isAccConRole ? 'WHERE Id IN: objIdSet' :
                    'WHERE Client_Account__c IN: objIdSet'; */
        List<Client_Account_Update__c> intgrObjList = new List<Client_Account_Update__c> ();
        for (Client_Account_Contact_Role__c clAccConRole : Database.query (queryStr)) {
            Client_Account_Update__c clientAccObj;
            Sobject cliAccNew, cliAccOld;
            clientAccObj = new Client_Account_Update__c ();
            if (isAccConRole) {
                cliAccNew = newObjMap.get (clAccConRole.Id);
                cliAccOld = oldObjMap == null? cliAccNew : oldObjMap.get (clAccConRole.Id);
                System.debug ('cliAccNew ==> '+cliAccNew);
                System.debug ('cliAccOld ==> '+cliAccOld);
            } else {
                cliAccNew = newObjMap.get (clAccConRole.Client_Account__c);
                cliAccOld = oldObjMap.get (clAccConRole.Client_Account__c);
            }
            for (TrackingFieldList__c trackField : UtilityGeneral.getTrackingFields ()) {
                if (isAccConRole) {
                    if (!trackField.Client_Account_Obj__c &&
                        cliAccNew.get (trackField.Field_Name__c) != 
                        cliAccOld.get (trackField.Field_Name__c)) {
                        //clientAccObj = clientAccObj == null? new Client_Account_Update__c () :
                         //           clientAccObj;
                        clientAccObj.put (trackField.CheckboxFieldName__c, true);
                    } 
                } else {
                        if (trackField.Client_Account_Obj__c &&
                            cliAccNew.get (trackField.Field_Name__c) != 
                            cliAccOld.get (trackField.Field_Name__c)) {
                            clientAccObj = clientAccObj == null? new Client_Account_Update__c () :
                                     clientAccObj;
                            clientAccObj.put (trackField.CheckboxFieldName__c, true);
                        }
                }
            }
            if (clientAccObj != null) {
                for (IntegrationObjMapping__c mapping : UtilityGeneral.getMappingObj ()) {
                    System.debug ('mapping client==> '+mapping.Integration_Obj_Field__c);
                    System.debug ('mapping client field==> '+mapping.Client_Obj_Field__c);
                    if (mapping.Is_Client_Account__c) {
                        clientAccObj.put (mapping.Integration_Obj_Field__c, 
                                    clAccConRole.getSobject (STR_CHILDNAME)
                                    .get (mapping.Client_Obj_Field__c));
                    }
                    else
                    clientAccObj.put (mapping.Integration_Obj_Field__c, 
                                    clAccConRole.get (mapping.Client_Obj_Field__c));
                }
                String key = String.valueOf (clAccConRole.Id) +
                             String.valueOf (clAccConRole.Client_Account__c) +
                             String.valueOf (clAccConRole.Contact__c);
                uniqueKeySet.add (key);
                clientAccObj.put (STR_UNIQKEY, key);
                clientAccObj.put (STR_RECENT, true);
                intgrObjList.add (clientAccObj);
                System.debug ('clientAccObj ==> '+clientAccObj);
                
                System.debug ('intgrObjList ==> '+intgrObjList);
            } // End if
        } // End for
        if (!intgrObjList.isEmpty ()) {
            if (oldObjMap != null)
            unflagMostRecent (uniqueKeySet);
            insert intgrObjList;
        }
    } // End method

    // A method that returns client account contact role details
    public static void unflagMostRecent (Set<String> uniqueKeySet) {
        List<Client_Account_Update__c> listClAccUpdate = new List<Client_Account_Update__c> ();
        for (Client_Account_Update__c cliAcc : [SELECT Id, Most_Recent__c
                                                FROM Client_Account_Update__c
                                                WHERE Unique_Key__c IN: uniqueKeySet]) {
            cliAcc.Most_Recent__c = false;
            listClAccUpdate.add (cliAcc);
        } // End for
        if (!listClAccUpdate.isEmpty ())
            update listClAccUpdate;
    }
}