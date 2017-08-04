/**
 * Description: When a new customer path record is created where the “Transition To” field is 
 * “Marketing Qualified Instance”, an Apex trigger will create a new task for the 
 * designated owner.
 * Technical Description: This is a handler class create MQI tasks based off Custom Setting data
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/04/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name : TestCreateTaskTriggerHandler
 * LLC TDD (Approach for MQI Follow-Up):
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.vjmst4xinbdp
 *
 * LLC TDD (Approach for MQI Follow-Up):
    https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.vjmst4xinbdp
 **/
public with sharing class CreateMQITaskTriggerHandler {
    private static final String STR_NORMAL = 'Normal'; 
    private static final String STR_MQIOWNER_EXC = 'MQI_Owner_Exception__c';
    private static final String STR_EXECUTEMQI = 'Execute_MQI_Trigger__c';
    private static final String STR_FASTTRACK = 'fast track';
    private static final String STR_LASTDETAIL = 'Last_Lead_Activity_Detail__c';
    private static final String STR_LASTLOB = 'Last_Line_of_Business__c';
    public static final String STR_ASSIGN_SALESSUPPORT = 'Assign_RISI_Sales_Support__c';
    private static final String STR_OPPTYEXCPTN ='Oppty_Enrichment_Exception__c';

    // A method to create MQI tasks
    public static void createMQITasks (List<Sobject> pCustPathList, Boolean isUpdate) {
        UtilityGeneral.count ++;
        System.debug ('Interger ==> '+UtilityGeneral.count);
        System.debug ('recursiveMQI ==> '+UtilityGeneral.recursiveMQI);
        UtilityGeneral.recursiveMQI = !UtilityGeneral.recursiveMQI && !isUpdate ? true : 
                                        UtilityGeneral.recursiveMQI;
        if (UtilityGeneral.recursiveMQI) {
            Map<String, String> custPathIdLeadIdMap = new Map<String, String> ();
            Map<String, String> custoPathIdContactIdMap = new Map<String, String> ();
            Map<String, Sobject> custPathIdObjMap = new Map <String, Sobject> ();
            for (Sobject objInstance : pCustPathList) {
                if (Boolean.valueOf (objInstance.get (STR_EXECUTEMQI)) != isUpdate) continue;
                if (VariableInitializer.MQI_STATUS.equalsIgnoreCase (String.valueOf (
                                        objInstance.get (VariableInitializer.STR_TO_LIFECYCLE)))) {
                    if (objInstance.get (VariableInitializer.STR_CON_LOOKUP) != null)
                        custoPathIdContactIdMap.put (
                            String.valueOf(objInstance.get (VariableInitializer.ID_FIELDNAME)),
                            String.valueOf(objInstance.get (VariableInitializer.STR_CON_LOOKUP))
                        );
                    else
                        custPathIdLeadIdMap.put (
                            String.valueOf(objInstance.get (VariableInitializer.ID_FIELDNAME)),
                            String.valueOf(objInstance.get (VariableInitializer.STR_LEAD_LOOKUP))
                        );
                    custPathIdObjMap.put (
                            String.valueOf (objInstance.get (VariableInitializer.ID_FIELDNAME)), 
                                            objInstance
                    );
                }
                UtilityGeneral.recursiveMQI = false; // breaking recursion
            } // End for
            System.debug ('custPathIdLeadIdMap ==> '+custPathIdLeadIdMap);
            List<Sobject> custSettingData =
                        UtilityGeneral.retrieveCustSettingData (VariableInitializer.STR_MQISETTING);
            System.debug ('recursiveMQI2 ==> '+UtilityGeneral.recursiveMQI);
            if (custPathIdLeadIdMap.size() > 0 )
                createMQITask (retrieveCustPathLeadMap (custPathIdLeadIdMap),
                                custSettingData, VariableInitializer.STR_LCTRANS);
            if (custoPathIdContactIdMap.size() > 0)
                createMQITask (retrieveCustPathConMap (custoPathIdContactIdMap),
                                custSettingData, VariableInitializer.STR_LCTRANS);
            updateCustPaths (custPathIdObjMap.keySet());
        }
    } // End method
    
    private static void updateCustPaths (Set<String> custpathIdSet) {
        List<Sobject> custpathsToUpdate = new List<Sobject> ();
        for (Sobject custPathInstance : [SELECT Execute_MQI_Trigger__c
                                            FROM p2s_base1__CustomerPath__c
                                            WHERE Id IN : custpathIdSet
                                            AND Execute_MQI_Trigger__c = true]) {
            custPathInstance.put (STR_EXECUTEMQI, false);
            custpathsToUpdate.add (custPathInstance);
        }
        if (custpathsToUpdate.size() > 0)
            update custpathsToUpdate;
    }
    // A method to return a map of custPathId and Lead obj
    public static Map<String, Sobject> retrieveCustPathLeadMap (Map<String, String> custPathIdLeadId) {
        Map<String, Sobject> custPathIdLeadObjMap = new Map<String, Sobject> ();
        List<String> leadIdList = custPathIdLeadId.values();
        String leadQuery = getConQuery (retrieveLeadFields (), VariableInitializer.STR_LEAD);
        if (String.isNotBlank(leadQuery)) {
            leadQuery += VariableInitializer.STR_SPACE + VariableInitializer.STR_WHERE + 
                        VariableInitializer.STR_SPACE + VariableInitializer.ID_FIELDNAME + 
                        VariableInitializer.STR_SPACE + VariableInitializer.STR_IN + 
                        VariableInitializer.STR_COLON + VariableInitializer.STR_SPACE + 'leadIdList';
            System.debug ('leadQuery ==> '+leadQuery);
            Map<Id, Sobject> leadIdObjMap = new Map<Id, Sobject> (Database.query (leadQuery));
            for (String custPathId : custPathIdLeadId.keySet()) {
                String leadId = custPathIdLeadId.get (custPathId);
                if (!custPathIdLeadObjMap.containsKey(custPathId) && 
                    leadIdObjMap.containsKey (leadId))
                    custPathIdLeadObjMap.put (custPathId, 
                                            leadIdObjMap.get (leadId));
            } // End for
        }
        return custPathIdLeadObjMap;
    }

    
    public static Boolean isFastTrack (String leadActDetail) {
        if (leadActDetail == null) return false;
        System.debug ('leadActDetail ==> '+leadActDetail);
        return leadActDetail.containsIgnoreCase (STR_FASTTRACK);
    } // End method

    public static Map<String, Sobject> getActiveUserMap () {
        return new Map<String, Sobject> ([SELECT Id, Name, Profile.Name
                                            FROM User
                                            WHERE IsActive = true]);
    }
    // A method that returns contact fields based off fieldSet
    private static List<Schema.FieldSetMember> retrieveLeadFields () {
        return SObjectType.Lead.FieldSets.MQI_Task_Creation.getFields();
    }

    // A method that returns contact fields based off fieldSet
    private static List<Schema.FieldSetMember> retrieveConFields () {
        return SObjectType.Contact.FieldSets.MQI_Task_Creation.getFields();
    }

    // A method that returns Contact query
    private static String getConQuery (List<Schema.FieldSetMember> objFieldSetList, String objName) {
        if (objFieldSetList == null || objName == null)
            return null;
        String conQueryString = VariableInitializer.STR_INIT;
        for (Schema.FieldSetMember f : objFieldSetList) {
             conQueryString += f.getFieldPath() + ', ';
        }
        return UtilityGeneral.getQuery (conQueryString, objName);
    }
    // A method to return a map of custPathId and Contact obj
    public static Map<String, Sobject> retrieveCustPathConMap (Map<String, String> custPathIdConId) {
        Map<String, Sobject> custPathIdConObjMap = new Map<String, Sobject> ();
        List<String> conIdList = custPathIdConId.values();
        String contactQuery = getConQuery (retrieveConFields (), VariableInitializer.STR_CONTACT);
        if (String.isNotBlank(contactQuery)) {
            contactQuery += VariableInitializer.STR_SPACE + VariableInitializer.STR_WHERE + 
                        VariableInitializer.STR_SPACE + VariableInitializer.ID_FIELDNAME + 
                        VariableInitializer.STR_SPACE + VariableInitializer.STR_IN + 
                        VariableInitializer.STR_COLON + VariableInitializer.STR_SPACE + 'conIdList';
            System.debug ('contactQuery ==> '+contactQuery);
            Map<Id, Sobject> conIdObjMap = new Map<Id, Sobject> (Database.query (contactQuery));
            for (String custPathId : custPathIdConId.keySet()) {
                String conId = custPathIdConId.get (custPathId);
                if (!custPathIdConObjMap.containsKey(custPathId) &&
                    conIdObjMap.containsKey (conId))
                    custPathIdConObjMap.put (custPathId, 
                                                conIdObjMap.get (conId));
            } // End for
        }
        return custPathIdConObjMap;
    }

    private static Task assignWhatIdAndHiddenLookups (Boolean pIsContactObj,
                                                    Map<String, Sobject> pCustPathIdCPObjMap,
                                                    Task pTask,
                                                    String pStrCpId) {
        if (pIsContactObj != null && pIsContactObj) { // Assiging what id and hidden lookup fields
           pTask.Contact_Hidden__c = String.valueOf (pCustPathIdCPObjMap.get (pStrCpId)
                                                .get (VariableInitializer.ID_FIELDNAME));
           pTask.WhatId = String.valueOf (pCustPathIdCPObjMap.get (pStrCpId)
                                                .get (VariableInitializer.ACCID_FIELDNAME));
        } else {
           pTask.Lead_Hidden__c = String.valueOf (pCustPathIdCPObjMap.get (pStrCpId)
                                                .get (VariableInitializer.ID_FIELDNAME));
        }
        return pTask;
    }

    // A method that will assign the fields to task. The argument is Custpath Id, Lead or Contact
    // object map, custom setting data and task type
    public static void createMQITask (Map<String, Sobject> custPathIdSobjMap, 
                                        List<Sobject> custDataList, String pType) {
        List<Task> taskListToInsert = new List<Task> ();
        List<Sobject> sobListToUpdate = new List<Sobject> ();
        Map<Id, User> mapIdUserObj = new Map<Id, User> ([SELECT Id, Name, Profile.Name
                                                            FROM User
                                                            WHERE IsActive = true]);
        for (String strCPid : custPathIdSobjMap.keySet()) {
            Task taskInstance = new Task ();
            Sobject leadOrConInstance = custPathIdSobjMap.get (strCPid);
            System.debug ('leadOrConInstance ==> '+leadOrConInstance);
            if (leadOrConInstance == null) continue;
            if (isTaskNotCreate (leadOrConInstance, pType)) continue;
            Boolean isConObj = UtilityGeneral.isContactObj (custPathIdSobjMap.get (strCPid));
            taskInstance.WhoId = String.valueOf (custPathIdSobjMap.get (strCPid)
                                            .get (VariableInitializer.ID_FIELDNAME));
            taskInstance = assignWhatIdAndHiddenLookups (isConObj, custPathIdSobjMap,
                                                            taskInstance, strCPid);
            Sobject taskOwner = retrieveTaskOwner (custPathIdSobjMap.get (strCPid), isConObj, 
                                                    mapIdUserObj);
        if (taskOwner == null) {
            if (pType.equalsIgnoreCase (VariableInitializer.STR_OPPTENRCH))
                leadOrConInstance.put (STR_OPPTYEXCPTN, true);
            else
                leadOrConInstance.put (STR_MQIOWNER_EXC, true);
            sobListToUpdate.add (leadOrConInstance);
            System.debug ('leadOrConInstance ==> '+leadOrConInstance);
            continue;
        }
            taskInstance.Lifecycle_Transition__c =
                VariableInitializer.STR_CSTPATH.equalsIgnoreCase (
                Id.valueOf (strCPid).getSObjectType().getDescribe().getName()) ? strCPid : null;
            taskInstance.Subject = VariableInitializer.STR_INIT;
            taskInstance.Description = VariableInitializer.STR_INIT;
            taskInstance.Type = pType;
            taskInstance = UtilityGeneral.assignTaskOtherFields (taskInstance, 
                                                         custPathIdSobjMap.get (strCPid));
            System.debug ('isConObj ==> '+isConObj);
            // Assign task Subject and Comment
            taskInstance = (Task) UtilityGeneral.fillTaskData (taskInstance, isConObj,
                                                            custDataList,
                                                            custPathIdSobjMap.get (strCPid));
            System.debug ('tastOwner ==> '+taskOwner);
            taskInstance.OwnerId = String.valueOf (taskOwner.get (VariableInitializer.ID_FIELDNAME));
            Boolean fastTrack = isFastTrack (String.valueOf (leadOrConInstance.get (STR_LASTDETAIL)));
            TaskWrapper taskWrp = getActivityDate
                              (fastTrack, 
                              String.valueOf (leadOrConInstance.get (STR_LASTLOB)), taskOwner );
        if (taskWrp != null && taskWrp.dueDate != null) {
            taskInstance.ActivityDate = UtilityGeneral.skipWeekEnd (taskWrp.dueDate);
            Date tempSLADate = UtilityGeneral.skipWeekEnd (taskWrp.dueDate.addDays (1));
            taskInstance.Priority = String.isNotBlank (taskWrp.priority) ? taskWrp.priority : 
                                    STR_NORMAL;
            taskInstance.SLA_Violation_Date__c = tempSLADate == null? null : tempSLADate;
        }
        System.debug ('taskInstance ==> '+taskInstance);
            taskListToInsert.add (taskInstance);
        } // End for
        if (taskListToInsert.size ()> 0)
            insert taskListToInsert;
        if (sobListToUpdate.size() > 0)
            update sobListToUpdate;
    } // End Method

    // A method that returns true value if MQI task or Enrichment task no needs to create
    private static Boolean isTaskNotCreate (Sobject pObj, String pStatus) {
            System.debug ('pObj ==> '+pObj);
            System.debug ('pStatus ==> '+pStatus);
        return ((Boolean.valueOf (pObj.get (STR_MQIOWNER_EXC)) &&
            pStatus.equalsIgnoreCase (VariableInitializer.STR_OPPTENRCH)) ||
            (Boolean.valueOf (pObj.get (STR_OPPTYEXCPTN)) &&
            pStatus.equalsIgnoreCase (VariableInitializer.STR_LCTRANS)));
    }
    // A method to return task due date
    public static TaskWrapper getActivityDate (Boolean isFastTrack,
                                                   String lineOfBusiness, Sobject taskOwner) {
        TaskWrapper taskWrp = new TaskWrapper (null, null);
        if (lineOfBusiness == null)
            return null;
        for (DueDateByLOB__c dueDate : UtilityGeneral.retrieveDueDate ()) {
            Date tempDueDate = dueDate.Subtract__c ? 
                                    Date.today() - Integer.valueOf (dueDate.Days__c) :
                                    Date.today() + Integer.valueOf (dueDate.Days__c);
            if (dueDate.Is_Fast_Track__c && isFastTrack) {
               taskWrp.dueDate = tempDueDate;
               taskWrp.priority = dueDate.Task_Priority__c;
               System.debug ('taskWrp ==> '+taskWrp);
               break;
            }
            if (lineOfBusiness.equals (dueDate.LOB__c)) {
                if (dueDate.Is_ISR__c) {
                    if (taskOwner != null && VariableInitializer.STR_ACCISRPROFILE.equalsIgnoreCase (
                        String.valueOf (taskOwner.getSobject (VariableInitializer.STR_PROFILE)
                                                          .get (VariableInitializer.STR_NAME)))) {
                       taskWrp.dueDate = tempDueDate;
                       taskWrp.priority = dueDate.Task_Priority__c;
                       System.debug ('taskWrp ==> '+taskWrp);
                    } // End if
                } else {
                       taskWrp.dueDate = tempDueDate;
                       taskWrp.priority = dueDate.Task_Priority__c;
                       System.debug ('taskWrp ==> '+taskWrp);
                }
            }
        } // End for
        return taskWrp;
    } // End method
    
    // A method to return task owner based off the criteria
    public static Sobject retrieveTaskOwner (Sobject leadOrCon, Boolean isConObj,
                                            Map<Id, User> existIdUserObjMap) {
        if (leadOrCon == null) return null;
        Sobject taskOwner; // taskOwner obj to return
        if (existIdUserObjMap.containsKey ((Id) (leadOrCon.get (VariableInitializer.OWNER_FIELDNAME)))){
            Boolean isAccManProfile = isAccManagerProfile (existIdUserObjMap.get ((Id) (leadOrCon
                                .get (VariableInitializer.OWNER_FIELDNAME))));
            Boolean isAccISRProfile = isAccISRProfile (existIdUserObjMap.get ((Id) (leadOrCon
                                .get (VariableInitializer.OWNER_FIELDNAME))));
            if (isAccManProfile || isAccISRProfile) {
                if (isLOBEvent (leadOrCon) && isAccManProfile && isConObj) {
                    String accISRId = getAccISR (leadOrCon);
                    if (isConObj && String.isNotBlank (accISRId)) 
                       taskOwner = existIdUserObjMap.get ((Id) accISRId);
                } else {
                       taskOwner = existIdUserObjMap.get ((Id) leadOrCon.get (VariableInitializer.OWNER_FIELDNAME));
                }
            } // End if
        } // End if
        if (taskOwner == null && Boolean.valueOf (leadOrCon.get (STR_ASSIGN_SALESSUPPORT)))
            return existIdUserObjMap.get (System.Label.RISI_Sales_Service_User);
            System.debug ('taskOwner 3==> '+taskOwner);
        return taskOwner;
    } // End method
    
    // A method to check if the owner is account manager profile
    private static Boolean isAccManagerProfile (User userObj) {
        if (userObj == null) return false;
        return VariableInitializer.STR_ACCMANPROFILE.equals (
                String.valueOf (userObj.Profile.Name));
    }
    
    // A method to check if the owner is account ISR profile
    private static Boolean isAccISRProfile (User userObj) {
        if (userObj == null) return false;
        return VariableInitializer.STR_ACCISRPROFILE.equals (
                String.valueOf (userObj.Profile.Name));
    }
    
    // A method to check if the LOB is Events
    private static Boolean isLOBEvent (Sobject leadOrCon) {
        if (leadOrCon == null) return false;
        return VariableInitializer.STR_EVENT.equalsIgnoreCase (
               String.valueOf (leadOrCon.get (VariableInitializer.STR_LOB)));
    }
    
    // A method to return Account ISR
    private static String getAccISR (Sobject leadOrConObj) {
        if (leadOrConObj == null) return null;
        return String.valueOf (leadOrConObj.getSobject (VariableInitializer.STR_ACC)
                              .get (VariableInitializer.ACCISR_FIELDNAME));
    }
    
    // Wrapper class
    public class TaskWrapper {
        public Date dueDate;
        public String priority;
        
         // Constructor
         public TaskWrapper (Date pDueDate, String pPriority) {
            this.dueDate = pDueDate;
            this.priority = pPriority;
         }
    } // End wrapper
}