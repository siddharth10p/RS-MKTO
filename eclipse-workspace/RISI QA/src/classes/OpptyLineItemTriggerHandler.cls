/**
 * Description: This is a handler class that creates a new Customer Path with SQO-SQO transition
 * a new product is created or existing product is updated. This class also has a function to
 * check off IsRenewal field if the Oppty product is exist on ND Order product
 * 
 *    Author      Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth P    06/28/2016           1.0      Inital draft
 * Siddharth P    08/29/2016           1.1      Change the logic to clone recent customer path
 *
 * LP URL: /space/118974/projects/show/30558937
 * Test class name- TestOpptyLineItemTriggerHandler
 *
 * TDD (Refreshing Campaign Attribution When Products Are Added): 
    https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
        %20%20%20%20%20%20%20%20pli=1#heading=h.e2zdh8w9cyyi
 **/
public with sharing class OpptyLineItemTriggerHandler {
    // Final variables
    public static final String STR_SOQ = 'Sales Qualified Opportunity';
    private static final String STR_CPOBJ = 'p2s_base1__CustomerPath__c';
    private static final String STR_QRFILTER = 'AND p2s_base1__MostRecent__c = true '+
                                       'ORDER BY p2s_base1__TransitionDateTime__c DESC LIMIT 1';
    private static final String STR_OPPTYLOOKUP = 'p2s_base1__Opportunity__c';
    private static final String STR_DETAIL ='Products Have Been Updated';
    private static final String STR_SUBRENEWAL ='Subscription - Renewal';
    private static final String STR_HYFN ='-';

    public static void cloneCustPath (Map<Id, OpportunityLineItem> opptyProdOldMap,
                                      Map<Id, OpportunityLineItem> opptyProdNewMap,
                                      Boolean isUpdate) {
        if (UtilityGeneral.puRecursive) {
            Map<Id, OpportunityLineItem> opptyIdObjMap
                    = new Map<Id, OpportunityLineItem> ([SELECT Quantity, UnitPrice, 
                                                            OpportunityId, Opportunity.IsClosed
                                                        FROM OpportunityLineItem
                                                        Where Id IN: opptyProdNewMap.keySet ()]);
        Set<String> opptyIdSet = new Set<String> ();
        for (String oppProId : opptyProdNewMap.keySet()) {
            if (String.isNotBlank (opptyProdNewMap.get (oppProId).OpportunityId)) {
                if ( opptyIdObjMap.get (oppProId).OpportunityId != null &&
                    !opptyIdObjMap.get (oppProId).Opportunity.IsClosed) {
                    if (!isUpdate)
                        opptyIdSet.add (opptyProdNewMap.get (oppProId).OpportunityId);
                    else if (opptyIdObjMap.get (oppProId).Quantity != 
                        opptyProdOldMap.get (oppProId).Quantity ||
                        opptyIdObjMap.get (oppProId).UnitPrice != 
                        opptyProdOldMap.get (oppProId).UnitPrice) {
                        opptyIdSet.add (opptyProdNewMap.get (oppProId).OpportunityId);
                    } // End else
                } // End if
            } // End if
        } // End for
        List<p2s_base1__CustomerPath__c> custPathList = new List<p2s_base1__CustomerPath__c> ();
        String queryStr = whereCls (buildQuery ());
        System.debug ('Where ==> '+queryStr);
        if (String.isNotBlank (queryStr)) {
            for (p2s_base1__CustomerPath__c cp : Database.query (queryStr)) {
                 p2s_base1__CustomerPath__c newCp = new p2s_base1__CustomerPath__c ();
                 newCp.p2s_base1__TransitionDateTime__c = Datetime.now();
                 newCp.p2s_base1__PreviousTransitionDateTime__c = 
                                       cp.p2s_base1__TransitionDateTime__c;
                 newCp.p2s_base1__ToLifecycleStage__c = STR_SOQ;
                 newCp.p2s_base1__FromLifecycleStage__c = STR_SOQ;
                 newCp.p2s_base1__Detail__c = STR_DETAIL;
                 newCp.p2s_base1__Opportunity__c = cp.p2s_base1__Opportunity__c;
                 newCp.p2s_base1__PreviousCustomerPath__c = cp.Id;
                 custPathList.add (newCp);
                 UtilityGeneral.puRecursive = false;
            } // End for
        }
        if (!custPathList.isEmpty()) 
            insert custPathList;
        }
    }// End method

    // A method to append where clause 
    private static String whereCls (String queryStr) {
        if (String.isBlank (queryStr)) return null;
        return queryStr +VariableInitializer.STR_SPACE+ 
                        VariableInitializer.STR_WHERE + VariableInitializer.STR_SPACE +
                        STR_OPPTYLOOKUP + VariableInitializer.STR_SPACE +
                        VariableInitializer.STR_IN+  VariableInitializer.STR_COLON + 
                        'opptyIdSet' + VariableInitializer.STR_SPACE+ STR_QRFILTER;
    }
    // A method that builds query
    private static String buildQuery () {
        String cpQueryString = VariableInitializer.STR_SELECT+ VariableInitializer.STR_SPACE;
        for (Schema.FieldSetMember f : retrieveCPFields ()) {
             cpQueryString += f.getFieldPath() + ', ';
        }
        
        cpQueryString = cpQueryString.removeEndIgnoreCase (', ');
        cpQueryString += VariableInitializer.STR_SPACE+ 
                        VariableInitializer.STR_FROM + VariableInitializer.STR_SPACE+ STR_CPOBJ;
        return cpQueryString;
    }
    // A private method that returns fields from CPTOClone fieldset
    private static List<Schema.FieldSetMember> retrieveCPFields () {
        return SObjectType.p2s_base1__CustomerPath__c.FieldSets.CPToClone.getFields();
    }

    // A method that check off Is_Renewal__c field on Oppty product
    public static void markIsRenewal (List<OpportunityLineItem> pOpptyProdList) {
        Map<String, List<String>> opptyLineItemsMap = new Map<String, List<String>> ();
        Set<String> lineItemIdSet = new Set<String> ();
        for (OpportunityLineItem opptyLine : pOpptyProdList) {
            if (!opptyLineItemsMap.containsKey (opptyLine.OpportunityId))
                opptyLineItemsMap.put (opptyLine.OpportunityId, new List<String>());
                opptyLineItemsMap.get (opptyLine.OpportunityId) // Unique key of ProdId + OpptyId
                    .add (opptyLine.PricebookEntryId + STR_HYFN + opptyLine.Id);
                    lineItemIdSet.add (opptyLine.Id);
        } // End for
        Map<String, List<String>> ndOrderIdProdMap = new Map<String, List<String>> ();
        for (Opportunity oppty : [SELECT Id, Main_Order__c, Revenue_Type__c
                                    FROM Opportunity
                                    WHERE Main_Order__c <> null
                                    AND Revenue_Type__c = :STR_SUBRENEWAL
                                    AND Id IN :opptyLineItemsMap.keySet ()]) {
            if (!ndOrderIdProdMap.containsKey (oppty.Main_Order__c))
                ndOrderIdProdMap.put (oppty.Main_Order__c, new List<String> ());
                ndOrderIdProdMap.get (oppty.Main_Order__c)
                            .addAll (opptyLineItemsMap.get (oppty.Id));
        } // End for
        Map<String, String> matchProdOpptyIdSet = new Map<String, String> ();
        for (OrderItem ordProd : [SELECT Id, OrderId, Order.ND_ORDER_ID__c, PricebookEntryId
                                        FROM OrderItem
                                        WHERE Order.ND_ORDER_ID__c 
                                        IN :ndOrderIdProdMap.keySet()]) {
            for (String opptyProdKey : ndOrderIdProdMap.get (ordProd.Order.ND_ORDER_ID__c)) {
                List<String> splitKey = opptyProdKey.split(STR_HYFN);
                if (splitKey != null && splitKey.get (0) != null && splitKey.get (1) != null) {
                    if (ordProd.PricebookEntryId == splitKey.get (0))
                        matchProdOpptyIdSet.put (splitKey.get (1), splitKey.get (0));
                }
            }
        } // End for
        List<OpportunityLineItem> lineItemsToUpdate = new List<OpportunityLineItem> ();
        for (OpportunityLineItem opptyLineItem : [SELECT Id, Is_Renewal__c, PricebookEntryId
                                                    FROM OpportunityLineItem
                                                    WHERE Id IN :lineItemIdSet]) {
            if (matchProdOpptyIdSet.containsKey (opptyLineItem.Id) &&
                opptyLineItem.PricebookEntryId.equals (matchProdOpptyIdSet
                                                        .get (opptyLineItem.Id))) {
                opptyLineItem.Is_Renewal__c = true;
                lineItemsToUpdate.add (opptyLineItem);
                System.debug ('opptyLineItem ==> '+opptyLineItem);
            }
        } // End for
        if (lineItemsToUpdate.size() > 0)
            update lineItemsToUpdate;
    }
} // End class