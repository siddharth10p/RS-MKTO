/**
 * Description: This is a controller class that fetches Opportunities to display on Home
 * page sidebar
 *
 *    Author      Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth P    08/31/2016           1.0      Inital draft
 *
 * LP URL: /space/118974/projects/show/31978072
 * Test class name : TestOpptyGeneral
 **/
public with sharing class OpptyNeedAttentionController {
    public List<OpptyCritical> getOpptyList () {
        Date twoMonths = Date.today().addDays (60);
        Date todayDate = Date.today();
        Date lastWeek = Date.today().addDays (-7);
        List<OpptyCritical> opptyCriticalList = new List<OpptyCritical> ();
        for (Opportunity opptyInstance : [SELECT Id, Name 
                                            FROM Opportunity 
                                            WHERE OwnerId =: UserInfo.getUserId()
                                            AND CloseDate <: twoMonths
                                            AND CloseDate >: todayDate
                                            AND Last_Activity_Date__c <: lastWeek
                                            AND IsClosed = false
                                            ORDER BY Last_Activity_Date__c
                                            ASC LIMIT 10]) {
            OpptyCritical opptyCr = new OpptyCritical ();
            opptyCr.objName = opptyInstance.Name;
            opptyCr.objUrl =  '/'+opptyInstance.Id;
            opptyCr.logoUrl = System.Label.OpptyLogo;
            opptyCriticalList.add (opptyCr);
        }
        return opptyCriticalList;
    }
    
    // A wrapper class
    public class OpptyCritical {
        public String objName  {get; set;}
        public String objUrl   {get; set;}
        public String logoUrl  {get; set;}
    }
}