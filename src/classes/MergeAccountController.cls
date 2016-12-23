/**
 * Description: Sid will add it
 *
 *
 **/
public class MergeAccountController {
    // Static final variables
    private static final String STR_MASTERID = 'accId';
    private static final String STR_SLAVEID = 'slaveAcc';
    private static final String STR_WHERE = 'Where';
    private static final String STR_OWNID = 'OwnerId';
    private static final String STR_ID = 'Id';
    private static final String STR_EQUALS = '=';
    private static final String STR_COLON = ':';
    private static final String STR_INIT = '';
    private static final String STR_SPACE = ' ';
    private static final String STR_NOTEQLOPR = 'not equals to';
    private static final String STR_EQLOPR = 'equals';
    private static final String STR_NOTCONOPR = 'does not contain';
    private static final String STR_CONOPR = 'contains';
    private static final String STR_SELECTOPR = '-- Select One --';
    private static final String STR_NONE = '-- None --';
    private static final String STR_REF = 'REFERENCE';
    private static final String STR_NAME = 'Name';
    private static final String STR_ACCNAME = 'Account Name';
    private static final String STR_SELECT = 'SELECT';
    private static final String STR_FROM = 'FROM';
    private static final String STR_COMMA = ',';
    private static final String STR_NDACCID = 'ND_ACCOUNT_ID__c';
    private static final String STR_MSNDACCID = 'Master_ND_AccountId__c';
    private static final String STR_NETSTID = 'NetSuite_Id__c';
    private static final String STR_BASEURL = '/apex/MergeAccounts?';
    private static final String STR_ERRMSG = ' to update Master ND AccountId on slave Account';
    private static final String STR_ERRBTN = '<br/><br/><input type="button" class="button"'+
                          ' onclick="updateNdAccount ();" value="Update Master ND AccountId" />';

    public List<Account> accList        {get; set;}
    public Account masterAcc            {get; set;}
    public String matchAcc              {get; set;}
    public Account slaveAcc             {get; set;}
    public String searchAccName         {get; set;}
    public String operator              {get; set;}
    public String selectedField         {get; set;}
    public Boolean acc1                 {get; set;}
    public Boolean acc2                 {get; set;}
    public Boolean isSuccess            {get; set;}
    public String qrtString             {get; set;}
    public Boolean showManualMergeOpt   {get; set;}

    // Variables
    private Boolean doRollback = false;
    private Sobject masterAcct, dupAcct;
    public String getSuccessMSG () {
        return 'Accounts Merge Successfully!';
    }

    public String getCurrentURL () {
        return STR_BASEURL+ STR_MASTERID+ STR_EQUALS+ accId;
    } // End method

    //private Account slaveAcc;
    private String accId;
    // Constructor
    public MergeAccountController () {
        accId = Apexpages.currentpage().getparameters().get(STR_MASTERID);
        matchAcc = Apexpages.currentpage().getparameters().get(STR_SLAVEID);
        String query = getQueryString ();
               query+= 'WHERE Id =: accId';
               System.debug ('query ==> '+query);
        List<Account> accList = Database.query (query);
        if (accList.size() > 0)
        masterAcc = accList.get (0);
        // accList = accListToDis (masterAcc.Name);
        if (String.isNotBlank (matchAcc))
            slaveAcc = getMatchAccount ();
        System.debug ('accList ==> '+accList);
        showManualMergeOpt = false;
    } // End constructor
    
    // Get Account fieldset
    public List<Schema.FieldSetMember> getAccFields() {
        return SObjectType.Account.FieldSets.MergeAccount.getFields();
    }
    
    public List<Account> getMatchingAccList () {
        List<Account> accList = accListToDis (masterAcc.Name);
        if (accList != null && accList.size() >0)
            return accList;
        else
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,
                                    System.Label.NoSearchResultMsg));
        return null;
    }

    private List<Account> accListToDis (String matchAccName) {
        List<Account> accList;
        String query = getQueryString () + STR_SPACE + STR_WHERE + STR_SPACE + 
                        'Id <> : accId AND' + STR_SPACE;
            String whereCls = String.isNotBlank (searchAccName) ? +
                               filterCondition (operator, selectedField, searchAccName) :
                            'Name =: matchAccName'; 
            query += whereCls + ' LIMIT 10'; 
            System.debug ('query ==> '+query);
            qrtString = query;
        try {
           accList = Database.query (query);
        } catch (QueryException exc) {
            System.debug ('Error==> '+ exc.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                    System.Label.SearchAccountFilterError));
        }
        return accList;
    }

    // A method that returns the prevous page
    public PageReference cancel () {
        matchAcc = null;
        PageReference currentPage = page.MergeAccounts;
        currentPage.getParameters().put (STR_MASTERID, accId);
        return currentPage;
    } // End method

    // A method that merges records
    public PageReference mergeRecords () {
        if (!acc1 && !acc2) {
            disError ();
            return null;
        }
        Savepoint sp = Database.setSavepoint(); // Savepoint to rollback the transaction
        Account selectedAcc, duplicateAcc;
        if (acc1) {
            selectedAcc = masterAcc;
            duplicateAcc = slaveAcc;
        } if (acc2) {
            selectedAcc = slaveAcc;
            duplicateAcc = masterAcc;
        }
        selectedAcc = mergeAccounts (selectedAcc, duplicateAcc);
        if (selectedAcc != null)
            updateMergeRecord (selectedAcc, duplicateAcc);
        if (doRollback)
            Database.rollback(sp);
        return null;
    } // End method
    
    public PageReference clearFilter () {
        searchAccName = STR_INIT;
        operator = STR_SELECTOPR;
        return null;
    }
    private void updateMergeRecord (Account masterAcc, Account dupAcc) {
        if (masterAcc != null && dupAcc != null) {
            try {
                Database.update(masterAcc);
                isSuccess = true;
                Database.delete(dupAcc);
            }
            catch (DmlException e) {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                            e.getMessage()));
                isSuccess = false;
                doRollback = true;
           }
        }
    }

    private String checkNDOwner (String selectedAccOwner, String duplicateAccOwner) {
        String ownerId = selectedAccOwner;
        if (!selectedAccOwner.equals (duplicateAccOwner)) { // Only execute if both accounts have different owner
            Boolean flag = false;
            Map<String, User> userIdObjMap = new Map<String, User> ([SELECT Id, ProfileId, 
                                                                            ND_Salesperson_ID__c
                                                                        FROM User
                                                                        WHERE Id =: selectedAccOwner
                                                                        OR Id =: duplicateAccOwner]);

            if (String.isNotBlank (userIdObjMap.get (duplicateAccOwner).ND_Salesperson_ID__c)) {
                ownerId = duplicateAccOwner;
                flag = true;
            }
            if (String.isNotBlank (userIdObjMap.get (selectedAccOwner).ND_Salesperson_ID__c) && flag) {
                ownerId = null;
            }
        }
        return ownerId;
    }

    private Boolean checkNDaccIds (Sobject selectedAcc, Sobject duplicateAcc) {
        return ((String.isNotBlank (String.valueOf (selectedAcc.get (STR_NDACCID))) && 
                String.isNotBlank (String.valueOf (duplicateAcc.get (STR_NDACCID)))) ||
                (String.isNotBlank (String.valueOf (selectedAcc.get (STR_NETSTID))) &&
                String.isNotBlank (String.valueOf (duplicateAcc.get (STR_NETSTID)))));
    }

    private void updateRelatedObjs (String selAccId, String dupAccId) {
        List<Sobject> sObjListChildUpdate = new List<Sobject> ();
        for (Relationship_Objects__c relObj : getRelatedObjs ()) {
            sObjListChildUpdate.addAll (updateAllChilds (relObj, selAccId, dupAccId));
        }
        System.debug ('sObjListChildUpdate ==> '+sObjListChildUpdate);
        if (sObjListChildUpdate.size() > 0) {
            try {
                Database.update (sObjListChildUpdate, true);
            }
            catch (DmlException e) {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                            e.getMessage()));
              doRollback = true;
           }
        }
    }

    public PageReference disError () {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                            System.Label.MasterAccSelectionError));
        return null;
    }
    private static List<Sobject> updateAllChilds (Relationship_Objects__c custSetting,
                                                    String masterId, String slaveId) {
        String queryStr = STR_SELECT+ STR_SPACE+ STR_ID+ STR_SPACE+ STR_COMMA+ STR_SPACE+ 
                            custSetting.Relationship_Name__c+ STR_SPACE+ STR_FROM+ STR_SPACE+
                            custSetting.Name + STR_SPACE + STR_WHERE + STR_SPACE + 
                            custSetting.Relationship_Name__c+ STR_SPACE+ STR_EQUALS +STR_COLON + 'slaveId';
        System.debug ('queryStr ==> '+queryStr);
        List<Sobject> sobjListToUpdate = new List<Sobject> ();
        for (Sobject obj : Database.query (queryStr)) {
            obj.put (custSetting.Relationship_Name__c, masterId);
            sobjListToUpdate.add (obj);
        }
        System.debug ('sobjListToUpdate ==> '+sobjListToUpdate);
        return sobjListToUpdate;
    }

    private Account mergeAccounts (Sobject master, Sobject slave) {
        masterAcct = master; dupAcct = slave; // Assiging to be used for manual merge
        if (checkNDaccIds (master, slave)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                                    System.Label.NDAccountIDPresent + STR_ERRBTN));
            showManualMergeOpt = true;
            return null;
        }
        String ownId = checkNDOwner (String.valueOf (master.get (STR_OWNID)),
                                        String.valueOf (slave.get (STR_OWNID)));
        if (String.isBlank (ownId)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                                    System.Label.NDuserIdError + STR_ERRBTN));
            showManualMergeOpt = true;
            return null;
        }
        master.put (STR_OWNID, ownId); // Maintining ND UserId owner on master account
        for (Schema.FieldSetMember field : this.getAccFields()) {
            String fieldName = field.getFieldPath ();
            if (master.get (fieldName) == null && slave.get (fieldName) != null)
                master.put (fieldName, slave.get (fieldName));
        }
        updateRelatedObjs (String.valueOf (master.get (STR_ID)),
                            String.valueOf (slave.get (STR_ID)));
        return (Account) master;
    }

    public List<SelectOption> getAllOperators() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(STR_INIT, STR_SELECTOPR));
        options.add(new SelectOption(STR_EQLOPR, STR_EQLOPR));
        options.add(new SelectOption(STR_NOTEQLOPR, STR_NOTEQLOPR));
        options.add(new SelectOption(STR_CONOPR, STR_CONOPR));
        options.add(new SelectOption(STR_NOTCONOPR, STR_NOTCONOPR));
        return options;
    }

    // A method that updates ND master accountId 
    public PageReference updateMasterAccId () {
        dupAcct.put (STR_MSNDACCID, masterAcct.get (STR_NDACCID));
        update dupAcct;
        return null;
    }
    public Account getMatchAccount () {
        String matchAccQuery = getQueryString ();
               matchAccQuery += 'WHERE Id =: matchAcc LIMIT 1';
         return Database.query (matchAccQuery);
    }

    public List<selectOption> getAllFields() {
        List<selectOption> options = new List<selectOption>();
        options.add (new selectOption (STR_NONE, STR_NONE));
        options.add (new selectOption (STR_NAME, STR_ACCNAME));
        List<Schema.FieldSetMember> fieldSetMember = this.getAccFields();
        for (Integer i=0; i < fieldSetMember.size(); i++) {
            if (!STR_REF.Equals (String.valueOf(fieldSetMember.get(i).getType())) &&
                !STR_ACCNAME.equals (fieldSetMember.get(i).getLabel()))
            options.add(new selectOption (fieldSetMember.get(i).getFieldPath(), fieldSetMember.get(i).getLabel()));
        }
        return options;
    } 

    // A method that adds operator in search string query
    private static String filterCondition (String operator, String filterField,
                                        String searchStr) {
        String returnOprString = '';
        if (String.isNotBlank (operator) && String.isNotBlank (filterField)) {
            if (operator.equalsIgnoreCase ('contains') )
                returnOprString = filterField +' Like \'%'+ searchStr +'%\'';
            if (operator.equalsIgnoreCase ('does not contain'))
                returnOprString = '( NOT '+ filterField +' Like \'%'+ searchStr +'%\')';
            if (operator.equalsIgnoreCase ('equals'))
                returnOprString = filterField +' = \''+ searchStr +'\'';
            if (operator.equalsIgnoreCase ('not equals to'))
                returnOprString = filterField +' != \''+ searchStr +'\'';
        }
        return returnOprString;
    }

    // A method that returns custom setting data
    private static List<Relationship_Objects__c> getRelatedObjs () {
        return Relationship_Objects__c.getall().values();
    }

    private String getQueryString () {
        String queryStr = 'Select ';
        for (Schema.FieldSetMember field : this.getAccFields()) {
            queryStr += field.getFieldPath() + ', ';
        }
        queryStr += 'Id, Master_ND_AccountId__c FROM Account ';
        return queryStr;
    } // End method
}