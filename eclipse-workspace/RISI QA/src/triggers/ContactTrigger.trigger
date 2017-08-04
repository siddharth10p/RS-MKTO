/**
 * Description: This trigger calls handler to create Opty Enrichment tasks and to update CustPath
 * 
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    07/14/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/30558937
 **/
trigger ContactTrigger on Contact (after update) {
    CreateOpptyEnrichmentTaskHandler.crateOpptyEnrichmentTask (Trigger.oldMap, Trigger.newMap);
    CreateOpptyEnrichmentTaskHandler.updateMQICustPath (Trigger.new);
}