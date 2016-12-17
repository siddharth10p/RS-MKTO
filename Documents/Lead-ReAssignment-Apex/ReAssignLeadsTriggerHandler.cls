/**
 * Description: This is a trigger handler class and would re-run assignment rule when a custom
 * checkbox Reassign__c is checked
 * 1) The checkbox should be created
 * 2) It should be updated by a workflow rule based off the criteria
 *
 * Created By: Siddharth Pandit
 * Copyright © Peruto Solutions Inc.
 **/
public with sharing class ReassignLeadsTriggerHandler {

   public static Integer numOfTriggerExectured = 0;

   //Note that the reassignment happens just after the screen refreshes, so most of the time you
   // won't see the lead 
   //owner changes until you refresh the screen a second time. 
   //This 'async apex' is needed as lead records can't be updated in the trigger a second time
   // to avoid infinite loops
   public static void reassignLeads(Set<Id> leadIds){
       numOfTriggerExectured++;
       Database.DMLOptions dmo=new Database.DMLOptions();
       dmo.assignmentRuleHeader.UseDefaultRule = true;

       for (Lead leadInstance : [SELECT id, Reassign__c FROM Lead WHERE Id IN: leadIds]){
        //Note this next line assumes you've created a custom field called Reassign, which is 
        //used to trigger the reassignment
           if(leadInstance.Reassign__c == true){
             leadInstance.Reassign__c = false; //set it to false to avoid continually reassigning this lead
             leadInstance.setOptions(dmo);
           }
       }//for
      try {
          Database.update(leadInstance);
      }catch (DMLException e){
          System.debug('Something went wrong with the reassignLeads method: ' + e.getMessage());
      }//try

   }//reassignLeads
    
}