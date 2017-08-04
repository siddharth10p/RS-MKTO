/**
 * Description: This is a controller class for Task Detail VF page
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    08/11/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/31978071
 * Test class name: TestTaskDetailPageController
 *
 * TDD (New Task Layout):
 * https://docs.google.com/document/d/1rJuVoRsHL9ut2YiQcJGSEBjiBbDIURZuI38FWC1HtqY/edit#heading=h.j5lqor868pi6
 **/
public with sharing class TaskDetailPageController {

    public static final String STR_TASK = 'Task';
    public static final String STR_EQL = '=';
    public static final String STR_COMMA = ',';
    public static final String STR_AMPRSD = '&';
    public static final String STR_SUB = 'Subject';
    private static final String STR_MQI = 'Marketing Qualified Instance';
    private static final String STR_LCS = 'p2s_base1__LifecycleStage__c';
    private static final String STR_SA = 'Sales Accepted';
    private static final String STR_NAME = 'Name';
    private static final String STR_CALLTYPE = 'Call';
    private static final String STR_EMAILTYPE = 'Email';
    private static final String STR_WHATID = 'WhatId';
    private static final String STR_WHOID = 'WhoId';
    private static final String STR_WHO_ID = 'who_id';
    private static final String STR_ERRMSG = System.Label.TaskPageErrorMsg;
    private static final String STR_MIDURL = '/00T/e?title=Call&';
    private static final String STR_RTURL = 'followup=1&tsk5=Call&tsk10=Call&retURL=/';
    private static final String STR_COMPLSTATUS = 'Completed';
    private static final String STR_ACC = 'Account';
    private static final String STR_LEAD = 'Lead';
    private static final String STR_CON = 'Contact';
    private static final String STR_IN = 'IN';
    private static final String STR_ACCID = 'AccountId';
    private static final String STR_RCREASON = 'Recycled_Reason__c';
    private static final String STR_DQREASON = 'Disqualified_Reason__c';
    private static final String STR_RECYCLED = 'Recycled';
    private static final String STR_DISQLFD = 'Disqualified';
    private static final String STR_BASEURL = URL.getSalesforceBaseUrl().toExternalForm();
    private static final String STR_LEADCONVERTSTATUS = System.Label.LeadConversionStatus;
    private static final String STR_HOMEURL = '/home/home.jsp';
    private static final String STR_FORCECLOSE = 'Force_Closure__c';
    private static final String STR_OPPTYOBJ = 'Opportunity';
    private static final String STR_NEWTASKURL = System.Label.FolloupTaskURL;
    private static final String STR_WHOIDFIELD = 'whoId';
    private static final String STR_NEWEVENTURL = System.Label.FolloupEventURL;
    private static final String STR_GETARCHIVED = ' AND IsDeleted = false ALL ROWS';
    private static final String STR_SUBJECT = System.Label.POCTaskSubject; 
    private static final String STR_NONE = '--None--';
    private static final String STR_ID = 'Id';
    private static final String STR_PERCENT = '%';
    private static final String STR_COMPANY = 'Company';
    private static final String STR_CREATEACC = 'Create New Account: ';
    private static final String STR_ERR = 'Please select an account!';

    // Get set variables
    public Task task                         {get; set;}
    public Boolean isEdit                    {get; set;}
    public Boolean displayPopup              {get; set;}
    public Sobject accOrLead                 {get; set;}
    public Sobject relObj                    {get; set;}
    public Boolean showErr                   {get; set;}
    public List<SelectOption> openOpptyList  {get; set;}
    public String openOpptySelected          {get; set;}
    public Boolean showOpptyPopup            {get; set;}
    public String selectedAcc                {get; set;}
    public Boolean showAccPopup              {get; set;}
    public List<SelectOption> accNameList    {get; set;}
    public Boolean showDependentPopup        {get; set;}

    private String taskId;
   // private Sobject relObj;
    private Boolean isConObj = false;
    private List<Opportunity> openOptyList;
    private String prevStage;
    private Boolean hasOppBtnClicked = false;
    private Boolean isAcc = false;
    private Boolean isOppty = false;
    private Boolean isLead = false;

    // Constructor
    public TaskDetailPageController(ApexPages.StandardController controller) {
        if (Test.isRunningTest()) {
            Task taskInstance = (Task) controller.getRecord();
            taskId = taskInstance.Id;
        } else
        taskId = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(taskId))
            init (); // Process only if the URL has task Id
    }
    
    private void init () {
        task = getTaskInfo ();
        identifyParents (task); // Identifying related parent object
        isEdit = false;
        displayPopup = false;
        relObj = addRelOBj ();
        System.debug ('relObj ==> '+relObj);
        if (isLead)
            accOrLead = relObj;
        List<Sobject> accLeadList = getRelAcc (task);
        if (accLeadList != null && !accLeadList.isEmpty())
            accOrLead = accLeadList.get (0);
        initilizeObjs ();
    }

    // A method that initilze the all related objects if they are null
    private void initilizeObjs () {
        if (relObj == null) relObj = new Lead ();
        if (accOrLead == null) accOrLead = new Lead ();
    }
    // A method that return Lead or Account's fields related to task
    private List<Sobject> getRelAcc (Task pTaskInstance) {
        List<Sobject> relAccOrLead;
        if (pTaskInstance != null) {
            if (isConObj)
                relAccOrLead = retrieveAccObj (String.valueOf (relObj.get (STR_ACCID)));
            if (isAcc)
                relAccOrLead = retrieveAccObj (pTaskInstance.WhatId);
            if (isOppty) {
                Opportunity oppty = [SELECT AccountId 
                                    FROM Opportunity
                                    WHERE Id =: pTaskInstance.WhatId
                                    LIMIT 1];
                relAccOrLead = retrieveAccObj (oppty.AccountId);
            }
        }
        return relAccOrLead;
    }
    // A method that returns colon (:) separated field api names
    private static String formatFieldsString (String pFieldApiNames) {
        if (pFieldApiNames == null) return null;
        String formatString = pFieldApiNames.replaceAll(' ', '');
        formatString = formatString.replaceAll(',', ':');
        return formatString;
    }

    // A method that returns Task Info read only fields
    public String getTIReadOnlyFields () {
       // if (task.WhoId == null) return null;
        return formatFieldsString (System.Label.TaskReadOnlyFields);
    } // End method

    // A method that returns personalInfo read only fields
    public String getPIReadOnlyFields () {
        if (task.WhoId == null) return null;
        return formatFieldsString (System.Label.PersonInfoReadOnlyFields);
    } // End method

    // A method that returns company info read only fields
    public String getCIReadOnlyFields () {
        if (task.WhoId == null && !isAcc) return null;
        return formatFieldsString (System.Label.CompanyInfoReadOnlyFields);
    } // End method

    // A method that changes the task status to completed
    private PageReference closeTask (Task pTask) {
        if (pTask != null) {
            System.debug ('pTask ==> '+pTask);
            String prevStatus = pTask.Status;
            try {
                pTask.Status = STR_COMPLSTATUS;
                update pTask;
            } catch (DmlException e) {
                pTask.Status = prevStatus;
                PageReference taskPage = new PageReference ('/apex/TaskDetailPage?id='+ pTask.Id);
                taskPage.setRedirect(false);
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                        e.getMessage()));
                return taskPage;
            System.debug ('Error Msg ==> '+e.getMessage());
            }
        }
        return null;
    }
    // A method that updates object
    private static void updateRelObj (Sobject pObj) {
        if (pObj != null) {
            try {
                update pObj;
            } catch (DmlException e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                        e.getMessage()));
            }
        }
    }

    // A method that returns Lead or Contact record
    private Sobject addRelOBj () {
        List<Sobject> relObjList = getRelObjList (String.valueOf (task.WhoId));
        if (relObjList!= null && !relObjList.isEmpty ())
            return relObjList.get (0);
            return null;
    }
    public String getURL () {
        if (task == null) return null;
        if (isConObj)
            return '/apex/mkto_si__Contact?id='+task.WhoId;
        if (isLead)
            return '/apex/mkto_si__Lead?id='+task.WhoId;
        if (isAcc)
            return '/apex/mkto_si__Account?id='+task.WhatId;
        if (isOppty)
            return '/apex/mkto_si__Opportunity?id='+task.WhatId;
            return null;
    }

    // A method to identify the related parent object ie. Lead / Contact / Oppty / Account
    private void identifyParents (task pTask) {
        if (pTask != null) {
            Id objId;
            if (pTask.WhoId != null) {
                objId = pTask.WhoId;
                isConObj = STR_CON.equalsIgnoreCase (objId.getSObjectType()
                                                    .getDescribe().getName());
                isLead = STR_LEAD.equalsIgnoreCase (objId.getSObjectType()
                                                    .getDescribe().getName());
            }
            else if (pTask.WhatId != null) {
                objId = pTask.WhatId;
                isAcc = STR_ACC.equalsIgnoreCase (objId.getSObjectType()
                                                    .getDescribe().getName());
                isOppty = STR_OPPTYOBJ.equalsIgnoreCase (objId.getSObjectType()
                            .getDescribe().getName());
            }
        } 
    }

    // A method that return list of account name on VF page
   // public List<SelectOption> getAccNameList () {
   //     return new List<selectOption>();
   // }
    // A method that creates account drop down list
    private static List<SelectOption> getAccNames (List<Sobject> pLstSobj, String pCompName) {
        List<SelectOption> options = new List<SelectOption>();
        options.add (new selectOption (STR_NONE, STR_NONE));
        options.add (new selectOption (STR_NONE, STR_CREATEACC + pCompName));
        for (Sobject sobjInstance : pLstSobj) {
            options.add ( new selectOption (String.valueOf (sobjInstance.get (STR_ID)),
                            String.valueOf (sobjInstance.get (STR_NAME))));
        }
        return options;
    }

    // A method that shows list of matching contacts
    private static List<Contact> getConList (List<String> conStrList) {
        return [SELECT Id, Name
                FROM Contact
                WHERE Name LIKE :conStrList];
    }
    // A method that shows list of matching accounts
    private static List<Account> getAccList (List<String> accStrList) {
        return [SELECT Id, Name
                FROM Account
                WHERE Name LIKE :accStrList LIMIT 995];
    }

    // A method that creates fuzzy search string 
    private static List<String> splitNameToMatch (String pName) {
        List<String> strList = new List<String> ();
        if (String.isNotBlank (pName)) {
            List<String> strSplitList = pName.split (' ');
            for (String strInstance : strSplitList) {
                strList.add (STR_PERCENT + strInstance + STR_PERCENT);
            }
        }
        return strList;
    }

   // private static String getAccId () {
        
  //  }
    // A method that converts a lead and returns contact record
    private Contact returnContact (Boolean pIsCon, Sobject pLeadOrCon) {
        Contact conIsntnce;
        if (!pIsCon) {
            Lead leadInstance = (Lead) pLeadOrCon;
            Database.LeadConvert convertLead = new Database.LeadConvert();
            convertLead.setLeadId (leadInstance.id);
            if (!STR_NONE.equalsIgnoreCase (selectedAcc)) // Setting up account Id to do dedup
                convertLead.setAccountId (selectedAcc);
            convertLead.setConvertedStatus (STR_LEADCONVERTSTATUS);
            convertLead.setDoNotCreateOpportunity(True);
            try {
                Database.LeadConvertResult convertLeadResult = Database.convertLead(convertLead);
                if (convertLeadResult.isSuccess ()) {
                    conIsntnce = [SELECT Id, p2s_base1__LifecycleStage__c, AccountId 
                                    FROM Contact
                                    WHERE Id =: convertLeadResult.getContactId()];
                } 
            } catch (DmlException e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                        e.getMessage()));
                System.debug ('Error ==> '+e.getMessage());
            }
        } else
                conIsntnce = (Contact) pLeadOrCon;
            return conIsntnce;
    }

    // A method that redirect a user to OpptyContactRole page
    public PageReference createOpptyConRole () {
            task.Force_Closure__c = true; // Avoiding the validation rule to close task
            closeTask (task);
            String url = '/p/opp/ContactRoleEditUi/e?oppid='+ openOpptySelected +
                       '&retURL=/' + openOpptySelected;
            PageReference conRolePage = new PageReference (url);
        return conRolePage;
    } // End method

    // A method that returns a list of select options and display a popup for Open oppty
    public PageReference showOpenOppty () {
        openOpptyList = new List<SelectOption> ();
        for (Opportunity opptyInstance : openOptyList) {
            openOpptyList.add(new SelectOption (opptyInstance.Id, opptyInstance.Name));
        }
        if (!openOpptyList.isEmpty()) {
            displayPopup = true;
            showOpptyPopup = true;
            hasOppBtnClicked = true;
        }
        return null;
    }

    // A method to redirect on new task page based off Save & New Task click
    public PageReference saveAndNew () {
        PageReference errPage = saveTask (); // saving inline edits
        if (errPage == null) return null;
        String taskWhoId = task.WhoId == null? '' : task.WhoId;
        String taskWhatId = task.WhatId == null? '' : task.WhatId;
        PageReference newTaskPage = new PageReference ('/00T/e?tsk5=Call&tsk10=Call&retURL=' +
                                                     task.Id +'&anm='+ task.OwnerId + 
                                                    '&who_id='+taskWhoId+ '&what_id='+taskWhatId);
        return newTaskPage;
    } // End method

    // A method that displays existing accountList when lead is converted
    public PageReference getAccNameList () {
        saveTask (); // saving inline edits
        if (!isConObj) {
            accNameList = getAccNames ( getAccList (splitNameToMatch (
                    String.valueOf (relObj.get (STR_COMPANY)))),
                    String.valueOf (relObj.get (STR_COMPANY))) ;
            showAccPopup = true;
            displayPopup = true;
        } else
        return createOppty ();
        return null;
    }
    // A method that create a new Oppty
    public PageReference createOppty () {
        if (STR_NONE.equalsIgnoreCase (selectedAcc) && !isConObj) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, STR_ERR));
            return null;
        } else {
            showAccPopup = false;
            displayPopup = false;
            Contact conToRedirect = returnContact (isConObj, relObj);
            if (conToRedirect == null) return null;
                task taskInstance = [SELECT Id, Status FROM Task WHERE Id =: task.Id];
                taskInstance.Force_Closure__c = true; // Avoiding the validation rule to close task
                closeTask (taskInstance); // Changing task status to completed
                return new PageReference (STR_BASEURL+ '/006/e?lookupcmpgn=1&retURL=/'+ 
                                    conToRedirect.Id + '&accid='+conToRedirect.AccountId + 
                                    '&conid='+ conToRedirect.Id+ '&opp11=Qualified');
        
        }
    }
    // A method that executes AcceptMQI button functionality
    public PageReference acceptMQI () {
        if (relObj == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, STR_ERRMSG));
            return null;
        }
            task.Force_Closure__c = true; // Avoiding the validation rule to close task
            PageReference retPage = closeTask (task);
            if (retPage != null) return retPage;
            relObj.put (STR_LCS, STR_SA);
            updateRelObj (relObj);
        return new PageReference (getLogACallURL (relObj.Id));
    }

    private String getLogACallURL (String pObjId) {
        String midUrl = (isLead || isConObj)? // Checking only pass whoid if it present
                    STR_MIDURL+ STR_WHO_ID+ STR_EQL+ pObjId+ STR_AMPRSD : 
                    STR_MIDURL;
        return midUrl+ pObjId + STR_RTURL+ pObjId;
    }

    public Boolean getCreateOppty () {
        return task.Subject.contains (STR_SUBJECT);
    }
    // A method that returns true if the task type is Email or Call
    public Boolean getTaskType () {
        return (STR_CALLTYPE.equalsIgnoreCase (task.Type) || 
                STR_EMAILTYPE.equalsIgnoreCase (task.Type));
    }
    // A method that returns true if the related obj Lifecycle stage is MQI
    public Boolean getMQIBtn () {
        if (task.WhoId == null) return null;
        return (STR_MQI.equalsIgnoreCase (convertToString(relObj.get (STR_LCS))));
    }
    
    private static String convertToString (Object obj) {
        return String.valueOf (obj);
    }
    // A method that retruns true if the related obj Lifecycle stage is MQI or SAL
    public Boolean getReclBtn () {
        if (task.WhoId == null) return null;
        return (STR_MQI.equalsIgnoreCase (convertToString(relObj.get (STR_LCS))) ||
                STR_SA.equalsIgnoreCase (convertToString(relObj.get (STR_LCS))));
    }

    // A method that retruns true if the related obj Lifecycle stage is MQI or SAL or Name
    public Boolean getDisQlfBtn () {
        if (task.WhoId == null) return null;
        return (STR_MQI.equalsIgnoreCase (convertToString(relObj.get (STR_LCS))) ||
                STR_SA.equalsIgnoreCase (convertToString(relObj.get (STR_LCS))) ||
                STR_NAME.equalsIgnoreCase (String.valueOf (relObj.get (STR_LCS))));
    }

    // A method that retruns true if the related accounts has an open oppty
    public Boolean getOpnOptyBtn () {
        if (isConObj != null && isConObj) {
            openOptyList = retrieveOpptyList (task.WhoId);
            if (openOptyList != null && !openOptyList.isEmpty()) return true;
        }
        return false;
    }

    // A method that returns account from Contact query
    private static Account getAccount (String pConId) {
        if (String.isBlank (pConId)) return null;
        return [SELECT Id FROM Account 
                WHERE Id IN (SELECT AccountId FROM Contact WHERE Id =:pConId) LIMIT 1];
    }
    // A method to return a list of Open opty on the account
    private static List<Opportunity> retrieveOpptyList (String pConId) {
        Account acc = getAccount (pConId);
        if (acc == null) return null;
        return [SELECT Id, Name, p2s_base1__LifecycleStage__c
                FROM Opportunity
                WHERE AccountId =: acc.Id
                AND isClosed = false];
    }
    private List<Sobject> getRelObjList (String objId) {
        if (String.isNotBlank (objId)) {
            if (isLead)
                return Database.query (getObjQuery (objId, STR_LEAD));
            if (isConObj)
                return Database.query (getObjQuery (objId, STR_CON));
        }
            return null;
    }
    // Following three methods returns fields from fieldSet
    public List<Schema.FieldSetMember> getTaskFields () {
        return SObjectType.Task.FieldSets.Task_Information.getFields ();
    }
    
    public List<Schema.FieldSetMember> getPersonFields () {
        return SObjectType.Contact.FieldSets.PersonInfoForTask.getFields ();
    }
    
    private List<Schema.FieldSetMember> getAccFields () {
        return SObjectType.Account.FieldSets.AccountFieldsForTask.getFields ();
    }
    
    private List<Schema.FieldSetMember> getLeadFields () {
        return SObjectType.Lead.FieldSets.PersonInfoForTask.getFields ();
    }

    private List<Schema.FieldSetMember> getCompanyFields () {
        return SObjectType.Lead.FieldSets.CompanyFieldsForTask.getFields ();
    }

    // A method that identify if the related obj is Contact and returns Accounts fields or leads
    public List<Schema.FieldSetMember> getCompanyInfo () {
        if (isConObj || isOppty || isAcc)
            return getAccFields ();
        else return getCompanyFields ();
        return null;
    }

    // A method that identify if the related obj is Contact and returns Accounts fields or leads
    public List<Schema.FieldSetMember> getPersonalInfo () {
        if (isConObj)
            return getPersonFields ();
        else return getLeadFields ();
        return null;
    }
    //A method that returns a master list of fieldSetMember for lead
    private List<Schema.FieldSetMember> retrieveAllLeadFields () {
        List<Schema.FieldSetMember> allFieldSetList = new List<Schema.FieldSetMember> ();
        allFieldSetList.addAll (getCompanyFields ());
        allFieldSetList.addAll (getLeadFields ());
        return allFieldSetList;
    }
    // A method that returns contact query
    private String getObjQuery (String pId, String objName) {
      if (String.isBlank (pId) || String.isBlank (objName)) return null;
      String objQuery ='';
        if (STR_LEAD.equalsIgnoreCase (objName)) {
            objQuery = constructQuery (retrieveAllLeadFields ());
        }
        else if (isConObj) {
            objQuery = constructQuery (getPersonFields ())+ STR_ACCID+ VariableInitializer.STR_COMMA;
        }
            objQuery = appendReasonFields (objQuery);
            objQuery = appendId (objQuery) + objName;
            objQuery += getWhereCls (pId);
      System.debug ('objQuery ==> '+objQuery);
      return objQuery;
    }

    // A method that adds recycled reason and disqualify reason in the query
    private String appendReasonFields (String pObjQuery) {
      if (String.isBlank (pObjQuery)) return null;
      return pObjQuery+ STR_RCREASON+ VariableInitializer.STR_COMMA+
              VariableInitializer.STR_SPACE+ STR_DQREASON+ 
              VariableInitializer.STR_COMMA+ VariableInitializer.STR_SPACE;
    }
    // A method that appends Id in the query
    private String appendId (String pQuery) {
      if (String.isBlank (pQuery)) return null;
      return pQuery + VariableInitializer.ID_FIELDNAME+ 
                    VariableInitializer.STR_SPACE+ VariableInitializer.STR_FROM+ 
                    VariableInitializer.STR_SPACE;
    }

    // A method to pull account if contact is not present
    private List<Sobject> retrieveAccObj (String pAccId) {
        if (pAccId == null) return null;
        String accQuery = constructQuery (getAccFields());
        accQuery = appendId (accQuery);
        accQuery += STR_ACC+ VariableInitializer.STR_SPACE+ 
                     VariableInitializer.STR_WHERE+ VariableInitializer.STR_SPACE+ 
                     VariableInitializer.ID_FIELDNAME+ + VariableInitializer.STR_SPACE+
                     STR_EQL+ '\''+ pAccId +'\'';
        System.debug ('accQuery ==> '+accQuery);
        return Database.query (accQuery);
    }
    // A method that constructs dynamic query. List of fieldset member needs tobe pass in param
    private static String constructQuery (List<Schema.FieldSetMember> fieldSetMember) {
        Set<String> fieldNameSet = new Set<String> ();
        String query = VariableInitializer.STR_SELECT+ VariableInitializer.STR_SPACE;
        for (Schema.FieldSetMember fieldMember : fieldSetMember) {
            if (!fieldNameSet.contains (fieldMember.getFieldPath ()))
                query += fieldMember.getFieldPath ()+ VariableInitializer.STR_COMMA+ VariableInitializer.STR_SPACE;
                fieldNameSet.add (fieldMember.getFieldPath ()); // Adding field to prevent dups in query
        }
        return query;
    }
    
    // A method that returns where clasue by appending Id
    private static String getWhereCls (String pObjId) {
        return VariableInitializer.STR_SPACE+ VariableInitializer.STR_WHERE+ 
                VariableInitializer.STR_SPACE+ VariableInitializer.ID_FIELDNAME+ STR_EQL+ 
                '\''+ pObjId +'\'';
    }
    // A method that construct query for task detail page
    private String getTaskQuery (String pTaskId) {
        if (String.isBlank (pTaskId)) return null;
        Set<String> fieldNameSet = new Set<String> ();
        String taskQuery = constructQuery (getTaskFields ());
        taskQuery += taskQuery.containsIgnoreCase (STR_WHATID) ? '':
                STR_WHATID+  VariableInitializer.STR_COMMA + VariableInitializer.STR_SPACE;
        taskQuery += taskQuery.containsIgnoreCase (STR_WHOID) ? '':
                STR_WHOID+  VariableInitializer.STR_COMMA + VariableInitializer.STR_SPACE;
            taskQuery += VariableInitializer.ID_FIELDNAME+ VariableInitializer.STR_COMMA+ 
                        VariableInitializer.STR_SPACE+ STR_FORCECLOSE + 
                        VariableInitializer.STR_COMMA+ VariableInitializer.STR_SPACE +
                        STR_SUB+ VariableInitializer.STR_SPACE+ VariableInitializer.STR_FROM+ 
                        VariableInitializer.STR_SPACE+ STR_TASK+ getWhereCls (pTaskId) +
                        STR_GETARCHIVED;
                     System.debug ('taskQuery ==> '+taskQuery);
       return taskQuery;
    }
    // A method to set recycle reason popup on page
    public PageReference setRecycleMQI () {
      prevStage = convertToString (relObj.get (STR_LCS));
      relObj.put (STR_LCS, STR_RECYCLED);
      showOpptyPopup = false;
      showAccPopup = false;
      displayPopup = true;
      return null;
    }

    // A method to set disqualify reason popup on page
    public PageReference setDisQualify () {
      prevStage = convertToString (relObj.get (STR_LCS));
      relObj.put (STR_LCS, STR_DISQLFD);
      showOpptyPopup = false;
      showAccPopup = false;
      displayPopup = true;
      return null;
    }
    // A method to set recycle reason popup on page
    public PageReference cancel () {
        if (!hasOppBtnClicked)
        relObj.put (STR_LCS, prevStage);
        displayPopup = false;
        hasOppBtnClicked = false;
      return null;
    }

    // A method to set recycle reason popup on page
    public PageReference saveRecord () {
        if ((STR_RECYCLED.equalsIgnoreCase (convertToString (relObj.get (STR_LCS))) &&
            String.isBlank (convertToString (relObj.get (STR_RCREASON)))) || 
            (STR_DISQLFD.equalsIgnoreCase (convertToString (relObj.get (STR_LCS))) &&
            String.isBlank (convertToString (relObj.get (STR_DQREASON))))) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                   System.Label.ReasonErrMsg));
            showErr = true;
            return null;
        }
        return redirectToHome ();
    }
    
    public PageReference redirectToHome () {
        updateRelObj (relObj);
        closeTask (task);
        displayPopup = false;
        showErr = false;
        PageReference homePage = new PageReference (STR_HOMEURL);
        System.debug ('homePage ==> '+homePage);
        homePage.setRedirect(true);
        return homePage;
    }
    // A method to retrun task detail
    private Task getTaskInfo () {
        String queryStr = getTaskQuery (taskId);
        System.debug ('queryStr ==> '+queryStr);
        if (String.isNotBlank (queryStr)) {
            return Database.query (queryStr);
        }
        else return null;
    }

    // Edit method to convert edit page
    public PageReference editTask () {
        isEdit = true;
        return null;
    }
    
    // A method to cancel the edit operation
    public PageReference returntoTask () {
        isEdit = false;
        return null;
    }

    // A method that redirects user to new task page
    public PageReference createTask () {
        task.Force_Closure__c = true; // Avoiding the validation rule to close task
        PageReference retPage = closeTask (task);
        if (retPage != null) return retPage;
        String relObjId = task.WhoId == null? '': task.WhoId;
        String newTaskUrl = STR_NEWTASKURL.replace (STR_WHOIDFIELD, relObjId);
        PageReference newTaskPage = new PageReference (newTaskUrl);
        return newTaskPage;
    }

    // A method that redirects user to new task page
    public PageReference createEvent () {
        task.Force_Closure__c = true; // Avoiding the validation rule to close task
        PageReference retPage = closeTask (task);
        if (retPage != null) return retPage;
        String relObjId = task.WhoId == null? '': task.WhoId;
        String newTaskUrl = STR_NEWEVENTURL.replace (STR_WHOIDFIELD, relObjId);
        PageReference newEventPage = new PageReference (newTaskUrl);
        return newEventPage;
    }
    // Save method to convert into read page
    public PageReference saveTask () {
        PageReference taskPage = new PageReference ('/apex/TaskDetailPage?id='+ task.Id);
        taskPage.setRedirect(true);
        Boolean inLineEdit = !isEdit;
        try {
            update task;
	        update accOrLead;
	        if (isConObj) // If related record is contact not lead, then update contact
	        update relObj;
            isEdit = false;
        } catch (DmlException e) {
            isEdit = inLineEdit? false: true;
            taskPage.setRedirect(false);
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                        e.getMessage()));
            return null;
        }
            return taskPage;
    }
}