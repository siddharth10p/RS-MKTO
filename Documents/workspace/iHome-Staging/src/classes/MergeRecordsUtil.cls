/**
 * Description: This is a utility class that contains methods used in MergeRecordsBatch
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      11/21/2016                   1.0      Initial Draft
 * Liquid Planner: /space/118974/projects/show/30837040
 * Copyright © Peruto Solutions Inc.
 **/
public with sharing class MergeRecordsUtil {
    private static final String STR_SELECT = 'Select';
    private static final String STR_SPACE = ' ';
    private static final String STR_INIT = '';
    private static final String STR_COMMA = ',';
    private static final String STR_LEAD = 'Lead';
    private static final String STR_CONTACT = 'Contact';
    private static final String STR_FROM = 'FROM';
    private static final String STR_ID = 'Id';
    private static final String STR_WHERE = 'WHERE';
    private static final String STR_COLON = ':';
    private static final String STR_EMAIL = 'Email';
    private static final String STR_NEWLINE = '\n';
    private static final String STR_RID = 'ResellerID__c';
    private static final String STR_ACCACTIVE = 'ActiveAccount__c';
    private static final String STR_CLIENTID = 'ClientID__c';
    private static final String STR_ATTACHMENT = 'Attachment';
    private static final String STR_CONTDOCLINK = 'ContentDocumentLink';
    private static final String STR_LEADHISTORY = 'LeadHistory';
    private static final String STR_MSG = 'Message__c';
    private static final String STR_FIVEONEONE = '511';
    private static final String STR_FIVESEVENSEVEN = '577';
    private static final String STR_SEVENTWOFIVE = '725';
    private static final String STR_TWO = '2';
    private static final String STR_NO = 'no';
    private static final String STR_LEADSCORE = 'mkto2__Lead_Score__c';
    private static final String STR_MASTER = 'master';
    private static final String STR_DUP = 'dup';
    private static final String STR_YES = 'yes';
    private static final String STR_IN = 'IN';
    private static final String STR_PARENTID = 'ParentId';
    private static final String STR_CONTDOCID = 'ContentDocumentId';
    private static final String STR_SEPARATE = '//';

    // A method that returns query on lead
    public static String retrieveLeadQuery (Set<String> existEmailSet) {
        String queryStr = STR_SELECT + STR_SPACE;
        for (Schema.FieldSetMember field : getLeadFields()) {
            queryStr += field.getFieldPath() + STR_COMMA + STR_SPACE;
        }
        queryStr += STR_ID + STR_SPACE + STR_FROM + STR_SPACE + STR_LEAD +
                    STR_SPACE + STR_WHERE + STR_SPACE + STR_EMAIL + STR_SPACE + STR_IN + 
                    STR_COLON + 'existEmailSet';
        return queryStr;
    } // End method

    // A method that calls the custom setting for lead fields
    public static List<Schema.FieldSetMember> getLeadFields() {
        return SObjectType.Lead.FieldSets.Test.getFields();
    }

    // A method that returns list of matching records
    public static List<Sobject> fetchMatchingRecords (Set<String> existEmailSet) {
        return Database.query (retrieveLeadQuery (existEmailSet));
    }

    // A method that validates RID and AccountActive fields
    private static Boolean checkRIDandAccActive (Sobject prevObj, Sobject newObj) {
        return (checkRIDFiveOneOne (prevObj) && checkRIDFiveOneOne (newObj) &&
                checkAccActiveNo (prevObj) && checkAccActiveNo (newObj));
    } // End method

    // A method that validates RID and AccountActive fields
    private static Boolean checkRIDandAccActiveYes (Sobject prevObj, Sobject newObj) {
        return (checkRIDFiveOneOne (prevObj) && checkRIDFiveOneOne (newObj) &&
                !String.valueOf (newObj.get (STR_ACCACTIVE))
                .equalsIgnoreCase (String.valueOf (prevObj.get (STR_ACCACTIVE))));
    } // End method

    // Following methods are to check RID and Account Active field
    private static Boolean compareLeadScore (Sobject prevObj, Sobject newObj) {
        Integer prevObjScore = prevObj.get (STR_LEADSCORE) != null ?
                               Integer.valueOf (prevObj.get (STR_LEADSCORE)) : 0;
        Integer newObjScore = newObj.get (STR_LEADSCORE) != null ?
                              Integer.valueOf (newObj.get (STR_LEADSCORE)) : 0;
        return (prevObjScore > newObjScore);
    }

    private static Boolean checkAccActiveNo (Sobject objInstance) {
        return STR_NO.equalsIgnoreCase (String.valueOf (objInstance.get (STR_ACCACTIVE)));
    }

    private static Boolean checkAccActiveYes (Sobject objInstance) {
        return STR_YES.equalsIgnoreCase (String.valueOf (objInstance.get (STR_ACCACTIVE)));
    }

    private static Boolean checkRIDFiveSevenSeven (Sobject objInstance) {
        return STR_FIVESEVENSEVEN.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    private static Boolean checkRIDFiveOneOne (Sobject objInstance) {
        return STR_FIVEONEONE.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    private static Boolean checkRIDSevenTwoFive (Sobject objInstance) {
        return STR_SEVENTWOFIVE.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    private static Boolean checkRIDTwo (Sobject objInstance) {
        return STR_TWO.equals (String.valueOf (objInstance.get (STR_RID)));
    }

    // A method that returns a map of two records master and duplicate
    private static Map<String, Sobject> checkRIDForPaids (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> objTypeMap = new Map<String, Sobject> ();
        if (checkRIDFiveOneOne (prevObj) && !checkRIDTwo (newObj) &&
            !checkRIDSevenTwoFive (newObj) && !checkRIDFiveSevenSeven (newObj) &&
            !checkRIDFiveOneOne (newObj)) {
            objTypeMap.put (STR_MASTER, prevObj);
            objTypeMap.put (STR_DUP, newObj);
        } else
        if (checkRIDFiveOneOne (newObj) && !checkRIDTwo (prevObj) &&
            !checkRIDSevenTwoFive (prevObj) && !checkRIDFiveSevenSeven (prevObj) &&
            !checkRIDFiveOneOne (prevObj)) {
            objTypeMap.put (STR_MASTER, newObj);
            objTypeMap.put (STR_DUP, prevObj);
        }
        return objTypeMap;
    }

    // A method to validate none of the records paid
    private static Map<String, Sobject> checkNoPaidRID (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> objTypeMap = new Map<String, Sobject> ();
        if ((checkRIDTwo (prevObj) || checkRIDSevenTwoFive (prevObj) ||
            checkRIDFiveSevenSeven (prevObj)) && !checkRIDTwo (newObj) && 
            !checkRIDSevenTwoFive (newObj) && !checkRIDFiveSevenSeven (newObj) &&
            !checkAccActiveYes (newObj)) {
            objTypeMap.put (STR_MASTER, prevObj);
            objTypeMap.put (STR_DUP, newObj);
        } else
        if ((checkRIDTwo (newObj) || checkRIDSevenTwoFive (newObj) ||
            checkRIDFiveSevenSeven (newObj)) && !checkRIDTwo (prevObj) && 
            !checkRIDSevenTwoFive (prevObj) && !checkRIDFiveSevenSeven (prevObj) &&
            !checkAccActiveYes (prevObj)) {
            objTypeMap.put (STR_MASTER, newObj);
            objTypeMap.put (STR_DUP, prevObj);
        }
        return objTypeMap;
    }
    // A method that returns a map of two records master and duplicate
    private static Map<String, Sobject> checkRIDwithAccActive (Sobject prevObj, Sobject newObj) {
        Map<String, Sobject> sobjMap = new Map<String, Sobject> ();
        if (checkRIDandAccActiveYes (prevObj, newObj)) {
            if (checkAccActiveYes (prevObj)) {
                sobjMap.put (STR_MASTER, prevObj); 
                sobjMap.put (STR_DUP, newObj);
            } else if (checkAccActiveYes (newObj)) {
                sobjMap.put (STR_MASTER, newObj); 
                sobjMap.put (STR_DUP, prevObj);
            }
        } else if (checkRIDFiveOneOne (prevObj) && checkRIDFiveOneOne (newObj)) {
            if (compareLeadScore (prevObj, newObj)) {
                sobjMap.put (STR_MASTER, prevObj); 
                sobjMap.put (STR_DUP, newObj);
            } else {
                sobjMap.put (STR_MASTER, newObj); 
                sobjMap.put (STR_DUP, prevObj);
            }
        }
        System.debug ('sobjMap ==> '+sobjMap);
        return sobjMap;
    }

    // 
    // A method that checks dups and merge them
    public static List<String> mergeRecords (Set<String> emailSet) {
        emailSet.remove (null);
        System.debug ('emailSet ==> '+emailSet);
        List<Sobject> existingObjList = fetchMatchingRecords (emailSet);
        System.debug ('existingObjList ==> '+existingObjList);
        System.debug ('existingObjList size ==> '+existingObjList.size ());
        Map<String, Sobject> recIdObjMap = new Map<String, Sobject> ();
        List<String> strListToReturn = new List<String> ();
        Map<String, String> dupIdMasterIdMap = new Map<String, String> ();
        Map<String, Sobject> strSobjMap; Sobject masterRec, dupRec;
        Map<String, Sobject> masterObjMapToUpdate = new Map<String, Sobject> ();
        List<Sobject> dupObjListToDel = new List<Sobject> ();
        for (Sobject objInstance : existingObjList) {
            System.debug ('objInstance ==> '+objInstance);
            System.debug ('recIdObjMap ==> '+recIdObjMap);
            if (recIdObjMap.containsKey (String.valueOf (objInstance.get (STR_EMAIL)))) {
                Sobject prevObj = recIdObjMap.get (String.valueOf (objInstance.get (STR_EMAIL)));
                System.debug ('prevObj ==> '+prevObj);
                strSobjMap = checkRIDwithAccActive (prevObj, objInstance);
                System.debug ('strSobjMap1 ==> '+strSobjMap);
                if (strSobjMap == null || strSobjMap.isEmpty ()) {
                    strSobjMap = checkRIDForPaids (prevObj, objInstance);
                    System.debug ('strSobjMap2 ==> '+strSobjMap);
                }
                if (strSobjMap == null || strSobjMap.isEmpty ()) {
                    strSobjMap = checkNoPaidRID (prevObj, objInstance);
                    System.debug ('strSobjMap3 ==> '+strSobjMap);
                }
                if (strSobjMap != null && !strSobjMap.isEmpty ()) {
                    masterRec = strSobjMap.get (STR_MASTER);
                    dupRec = strSobjMap.get (STR_DUP);
                    System.debug ('masterRec ==> '+masterRec);
                    System.debug ('dupRec ==> '+dupRec);
                    masterObjMapToUpdate.put (String.valueOf (masterRec.get (STR_ID)),
                                            mergeFieldValues (masterRec, dupRec));
                    dupObjListToDel.add (dupRec);
                    strListToReturn.add (String.valueOf (dupRec.get (STR_EMAIL)+ STR_COMMA+ 
                                STR_SPACE+ String.valueOf (dupRec.get (STR_CLIENTID))));
                    dupIdMasterIdMap.put (String.valueOf (dupRec.get (STR_Id)),
                                            String.valueOf (masterRec.get (STR_Id)));
                }
            }
            else
                recIdObjMap.put (String.valueOf (objInstance.get (STR_EMAIL)), objInstance);
        }
        System.debug ('dupIdMasterIdMap ==> '+dupIdMasterIdMap);
        if (!dupIdMasterIdMap.isEmpty ()) updateChildRecords (dupIdMasterIdMap); // Updating child records
        if (!masterObjMapToUpdate.isEmpty ()) update masterObjMapToUpdate.values();
        if (!dupObjListToDel.isEmpty ()) delete dupObjListToDel;
        return strListToReturn;
    } // End method

    // A method to create new attachments, files and history records under master records
    private static void createChildRecords (Map<String, String> dupIdMasterIdMap, String objName,
                                            String relName) {
        List<Sobject> objListToCreate = new List<Sobject> ();
        Set<String> dupIdSet = dupIdMasterIdMap.keySet ();
        String queryStr = retrieveChildQuery (objName, relName) + 'dupIdSet';
        if (STR_ATTACHMENT.equalsIgnoreCase (objName)) {
            for (Attachment attInstance : Database.query (queryStr)) {
                Attachment att = new Attachment (Name = attInstance.Name, Body = attInstance.Body,
                                ParentId = dupIdMasterIdMap.get (attInstance.ParentId));
                objListToCreate.add (att);
            }
        }
        if (STR_CONTDOCLINK.equalsIgnoreCase (objName)) {
            for (ContentDocumentLink conDocLink : Database.query (queryStr)) {
                System.debug ('conDocLink ==> '+conDocLink);
                ContentDocumentLink contDoc = 
                    new ContentDocumentLink (ContentDocumentId = conDocLink.ContentDocumentId, 
                            LinkedEntityId = dupIdMasterIdMap.get (conDocLink.LinkedEntityId));
                objListToCreate.add (contDoc);
            }
        }
        System.debug ('objListToCreate ==> '+objListToCreate);
        if (!objListToCreate.isEmpty ()) insert objListToCreate;
    }

    // A method that returns a query for child objects
    private static String retrieveChildQuery (String objName, String relName) {
        String queryStr = STR_SELECT+ STR_SPACE+ STR_ID+ STR_COMMA+ STR_SPACE+ relName;
        queryStr+= STR_ATTACHMENT.equalsIgnoreCase (objName)? 
                   STR_COMMA+ STR_SPACE+ STR_PARENTID : '';
        queryStr+= STR_CONTDOCLINK.equalsIgnoreCase (objName)? 
                   STR_COMMA+ STR_SPACE+ STR_CONTDOCID : '';
        queryStr+= STR_SPACE+ STR_FROM+ STR_SPACE+
                            objName + STR_SPACE + STR_WHERE + STR_SPACE + 
                            relName+ STR_SPACE+ STR_IN + STR_COLON ;
        return queryStr;
    }
    // A method to merge child records
    public static void updateChildRecords (Map<String, String> dupIdMasterIdMap) {
        System.debug ('dupIdMasterIdMap ==> '+dupIdMasterIdMap);
        List<Sobject> objListToUpdate = new List<Sobject> ();
        Set<String> dupIdSet = dupIdMasterIdMap.keySet ();
        for (Relationship_Obj__c relObj : getRelatedObjs ()) {
            if (STR_ATTACHMENT.equalsIgnoreCase (relObj.Name) ||
                STR_CONTDOCLINK.equalsIgnoreCase (relObj.Name)) {// Checking if obj is attachement
                createChildRecords (dupIdMasterIdMap, relObj.Name, relObj.Relationship_Name__c);
                continue;
            } 
            String queryStr = retrieveChildQuery (relObj.Name, relObj.Relationship_Name__c) +
                                'dupIdSet';
            System.debug ('queryStr ==> '+queryStr);
            System.debug ('queryStr result ==> '+Database.query (queryStr));
            for (Sobject objInstance : Database.query (queryStr)) {
                String dupKey = String.valueOf (objInstance.get (relObj.Relationship_Name__c));
                objInstance.put (relObj.Relationship_Name__c,
                                dupIdMasterIdMap.get (dupKey));
                objListToUpdate.add (objInstance);
            } // End for
        }
        if (!objListToUpdate.isEmpty ())
            update objListToUpdate;
    }

    // A method that returns custom setting data
    private static List<Relationship_Obj__c> getRelatedObjs () {
        return Relationship_Obj__c.getall().values();
    }

    // A method that merges the nonblank fields based off the master record
    private static Sobject mergeFieldValues (Sobject masterObj, Sobject dupObj) {
        System.debug ('masterObj ==> '+masterObj);
        System.debug ('dupObj ==> '+dupObj);
        for (Schema.FieldSetMember leadFields : getLeadFields()) {
            String fieldName = leadFields.getFieldPath ();
            if (STR_MSG.equalsIgnoreCase (fieldName) &&
                String.isNotBlank (String.valueOf(dupObj.get (fieldName)))) { // Message field concatenation
                String msg = masterObj.get (fieldName) == null? '': 
                            String.valueOf (masterObj.get (fieldName)) + STR_SEPARATE;
                msg += dupObj.get (fieldName);
                masterObj.put (fieldName, msg);
                continue;
            }
            System.debug ('fieldName ==> '+fieldName);
            System.debug ('fieldName get ==> ' +masterObj.get (fieldName));
            System.debug ('fieldName get2  ==> '+dupObj.get (fieldName));
            if (masterObj.get (fieldName) == null && dupObj.get (fieldName) != null)
                masterObj.put (fieldName, dupObj.get (fieldName));
        }
        return masterObj;
    }

    // A method that sends email
    public static void sendEmail (List<String> removedObjList) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // Set recipients to two contact IDs.
        // Replace IDs with valid record IDs in your org.
        String emails = System.Label.MergeRecordsEmail.replaceAll (' ', '');
        List<String> emailList = emails.split (';');
        message.toAddresses = emailList;
        message.optOutPolicy = 'FILTER';
        message.subject = 'List of deleted records in merge';
        message.plainTextBody = System.Label.MergeRecordsMsg+ STR_COLON+ STR_NEWLINE+ STR_NEWLINE;
        message.plainTextBody += 'Email;  ClientId'+ STR_NEWLINE;
        for (String delRecord : removedObjList)
             message.plainTextBody += delRecord + STR_NEWLINE;
        Messaging.SingleEmailMessage[] messages = 
        new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        } 
    }
}