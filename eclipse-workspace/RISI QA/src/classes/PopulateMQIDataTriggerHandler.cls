/**
 * Description: This is a batch class to update Opportunity lookup on
 * customer path records
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    08/19/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name: TestUpdateOpptyLookupOnCustPathBatch
 **/
public with sharing class PopulateMQIDataTriggerHandler {
    // Static variables
    private static final String MQI_STATUS = 'Marketing Qualified Instance';

    // A method that populates MQI information on Customer Path record
    public static void populateMQIInfo (List<p2s_base1__CustomerPath__c> custPathList) {
	    	List<Id> relObjIdList = new List<Id> ();
	    	for (p2s_base1__CustomerPath__c custPathInstance : custPathList) {
	    		if (MQI_STATUS.equals (custPathInstance.p2s_base1__ToLifecycleStage__c)) {
	    			if (String.isNotBlank (custPathInstance.p2s_base1__Contact__c)) {
	    				relObjIdList.add (custPathInstance.p2s_base1__Contact__c);
	    			} else if (String.isNotBlank (custPathInstance.p2s_base1__Lead__c)) {
	    				relObjIdList.add (custPathInstance.p2s_base1__Lead__c);
	    			}
	    		}
	    	}
	    	if (relObjIdList.size () >0) {
	    		Schema.DescribeSObjectResult drObj = relObjIdList.get (0).getSObjectType().getDescribe();
	    		String queryString = VariableInitializer.STR_SELECT+ VariableInitializer.STR_SPACE+
	                  VariableInitializer.STR_PRODINT+ VariableInitializer.STR_COMMA+
	                  VariableInitializer.STR_SPACE + VariableInitializer.STR_PRODINTFAM+
	                  VariableInitializer.STR_COMMA+ VariableInitializer.STR_SPACE+
	                  VariableInitializer.STR_LEADACTVT+ VariableInitializer.STR_COMMA+
	                  VariableInitializer.STR_SPACE + VariableInitializer.STR_FORMFILLPAGE +
	                  VariableInitializer.STR_SPACE+  VariableInitializer.STR_FROM+
	                  VariableInitializer.STR_SPACE+ drObj.getName ()+ VariableInitializer.STR_SPACE+
	                  VariableInitializer.STR_WHERE+ VariableInitializer.STR_SPACE+
	                  VariableInitializer.ID_FIELDNAME+ VariableInitializer.STR_SPACE+
	                  VariableInitializer.STR_IN+ VariableInitializer.STR_COLON+
	                  VariableInitializer.STR_SPACE + 'relObjIdList';
	        Map <Id, Sobject> idObjMap = new Map<Id, Sobject> (Database.query (queryString));
			for (p2s_base1__CustomerPath__c custpath : custPathList) {
				Id key;
				if (idObjMap.containsKey (custpath.p2s_base1__Contact__c))
					key = custpath.p2s_base1__Contact__c;
				else if (idObjMap.containsKey (custpath.p2s_base1__Lead__c))
					key = custpath.p2s_base1__Lead__c;
				if (String.isNotBlank (key)) {
					custpath.Product_Interest__c = String.valueOf (idObjMap.get (key)
														.get (VariableInitializer.STR_PRODINT));
					custpath.Product_Interest_Family__c = String.valueOf (idObjMap.get (key)
														.get (VariableInitializer.STR_PRODINTFAM));
					custpath.Lead_Activity_Detail__c = String.valueOf (idObjMap.get (key)
                                                         .get (VariableInitializer.STR_LEADACTVT));
                    custpath.Form_Fill_Web_Page__c = String.valueOf (idObjMap.get (key)
                                                         .get (VariableInitializer.STR_FORMFILLPAGE));
			    }
		     }
	    	}
    } // End method
}