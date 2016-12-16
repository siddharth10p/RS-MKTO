/**
 * Description: Sid will add 
 * 
 **/
global with sharing class ConvertLeads {

    global static void leadConvert (Set<String> leadIds) {
        List<Database.LeadConvert> leadConvertList = new List<Database.LeadConvert> ();
        for (Id leadId : leadIds) {
            if ('Lead'.equalsIgnoreCase (leadId.getSObjectType().getDescribe().getName())) {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadId);
                lc.setConvertedStatus('Converted'); // This needs to be pulled from custom label
                lc.setDoNotCreateOpportunity(true);
                leadConvertList.add (lc);
            }
        }
        if (!leadConvertList.isEmpty()) {
            List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConvertList);
        }
    }
}