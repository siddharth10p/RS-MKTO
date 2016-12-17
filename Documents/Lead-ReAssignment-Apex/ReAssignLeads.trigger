/**
 * Description: The trigger will re-execute the assignment rule when a workflow updates a 
 * a custom checkbox porpusly.
 *
 * Created By: Siddharth Pandit
 * Copyright © Peruto Solutions Inc.
 *
 **/
trigger ReAssignLeads on Lead (after update) {
   if (ReassignLeadsTriggerController.numOfTriggerExectured < 2) {
       Set<Id> leadIds = new Set<Id>();
       for(Lead aLead:trigger.new) {
          leadIds.add (aLead.id);    
       } // End for
       ReassignLeadsTriggerController.reassignLeads (leadIds);
   } // End if
} // End trigger