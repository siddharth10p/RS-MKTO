/**
 * Description: This trigger calls handler to create Opty Enrichment tasks and to update CustPath
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/25/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 * LLC TDD - (Approach for Opportunity Enrichment)
 * https://docs.google.com/document/d/1m0q2hXBG9iMNWxxnZfsh1UQdnuDyc7PuaIdfug1rGow/edit?
    pli=1#heading=h.lqmo1nqi3esa
 **/
 trigger LeadTrigger on Lead (after update, before update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        CreateOpptyEnrichmentTaskHandler.crateOpptyEnrichmentTask (Trigger.oldMap, Trigger.newMap);
        CreateOpptyEnrichmentTaskHandler.updateMQICustPath (Trigger.new);
    }
}