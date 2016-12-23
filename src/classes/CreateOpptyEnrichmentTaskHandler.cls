/**
 * Description: This is a handler class create Oppty Enrichment tasks based off Custom Setting data
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/14/2016           1.0      Inital draft
 *
 **/
public with sharing class CreateOpptyEnrichmentTaskHandler {
	// final static variables
    private static final String STR_OPPENRICHDATE = 'Opportunity_Enrichment_Date__c';
    private static final String STR_CONTACT = 'Contact';
    private static final String STR_LEAD = 'Lead';
    private static final String STR_SELECT = 'SELECT';
    private static final String STR_FROM = 'FROM';
    private static final String STR_SPACE = ' ';
    private static final String STR_INIT = '';
    private static final String STR_SUBQUERY = '(SELECT Id, Line_of_Business__c, Fast_Track_Formula__c ' +
                                'FROM p2s_base1__CustomerPath__r '+
                                'ORDER BY p2s_base1__TransitionDateTime__c '+
                                'DESC LIMIT 1)';
    private static final String STR_OPPTYENRINCH = 'Opportunity_Enrichment_Task_Setting__c';
    private static final String STR_CHILDNAME = 'p2s_base1__CustomerPath__r';
    private static final String STR_ASSRISISUPPORT = 'Assign_RISI_Sales_Support__c';
    private static final String STR_OPPTYEXCPTN ='Oppty_Enrichment_Exception__c';

    // A method that calls another method to create tasks
    public static void crateOpptyEnrichmentTask (Map<Id, Sobject> oldObjMap,
                                                   Map<Id, Sobject> newObjMap) {
        System.debug ('oldObjMap ==> '+oldObjMap);
        System.debug ('newObjMap ==> '+newObjMap);
        Set<String> objIdSet = new Set<String> ();
        Boolean isConObj = false;
        for (Id objId : newObjMap.keySet()) {
            if (Datetime.valueOf (oldObjMap.get (objId).get (STR_OPPENRICHDATE)) != 
                Datetime.valueOf (newObjMap.get (objId).get (STR_OPPENRICHDATE)) ||
                (Boolean.valueOf (newObjMap.get (objId).get (STR_ASSRISISUPPORT)) &&
                Boolean.valueOf (newObjMap.get (objId).get (STR_OPPTYEXCPTN))))
                objIdSet.add (objId);
                isConObj = UtilityGeneral.isContactObj (newObjMap.get (objId));
        }

        String conQuery = isConObj ? getObjQuery (retrieveConFields (), STR_CONTACT) : 
                         getObjQuery (retrieveLeadFields (), STR_LEAD);
               conQuery+= ' WHERE Id IN : objIdSet';
        System.debug ('conQuery ==> '+conQuery);
        Map<String, Sobject> objIdSObjMap = new Map <String, Sobject> ();
        Map<String, Sobject> custPathCPObjMap = new Map <String, Sobject> ();
        for (Sobject objInstance : Database.query (conQuery)) {
            if (objInstance.getSObjects (STR_CHILDNAME) != null) {
                objIdSObjMap.put ((Id) objInstance.getSObjects (STR_CHILDNAME)
                                                 .get (0).Id, objInstance);
            } else
                objIdSObjMap.put (objInstance.Id, objInstance);
        } // End for
        List<Sobject> custSettingData = UtilityGeneral.retrieveCustSettingData (STR_OPPTYENRINCH);
        CreateMQITaskTriggerHandler.createMQITask (objIdSObjMap, custSettingData, 
                                                  VariableInitializer.STR_OPPTENRCH);
    } // End method

    // A method that returns Contact query
    private static String getObjQuery (List<Schema.FieldSetMember> fieldSetMemberList,
                                                                           String objName) {
        String conQueryString = STR_INIT;
        for (Schema.FieldSetMember f : fieldSetMemberList) {
            conQueryString += f.getFieldPath() + ', ';
        }
            conQueryString += STR_SUBQUERY;
        return UtilityGeneral.getQuery (conQueryString, objName);
    } // End method

    // A method that returns contact fields based off fieldSet
    private static List<Schema.FieldSetMember> retrieveConFields () {
        return SObjectType.Contact.FieldSets.Opportunity_Enrichment_TaskFields.getFields();
    } // End method

    // A method that returns Leads fields based off fieldSet
    private static List<Schema.FieldSetMember> retrieveLeadFields () {
        return SObjectType.Lead.FieldSets.Opportunity_Enrichment_TaskFields.getFields();
    } // End method

    // A method that check off Execute_MQI_Trigger__c checkbox to re-run MQI task trigger
    public static void updateMQICustPath (List<Sobject> pObjList) {
        Set<String> objIdSet = new Set<String> ();
        for (Sobject objInstance : pObjList) {
            if (Boolean.valueOf (objInstance.get (STR_ASSRISISUPPORT)))
                objIdSet.add (String.valueOf (objInstance.get (VariableInitializer.ID_FIELDNAME)));
        }
        System.debug ('objIdSet ==> '+objIdSet);
        Map<String, p2s_base1__CustomerPath__c> objIdCustPathMap = 
                   UtilityGeneral.getCustpathRecordsMap (objIdSet, VariableInitializer.MQI_STATUS, true);
        if (objIdCustPathMap.values().size() > 0)
            update objIdCustPathMap.values();
    } // End method
} // End class