@isTest
public class UpdateOpportunityCloseDocuSignTestClass{
    static testMethod void yourTestMethod(){
        //insert account
        account acc = new account(
        Name='test account');
        
        insert acc;
        
        opportunity opp = new opportunity(
        Name = 'Test oppty',
        Revenue_Type__c='Subscription - Renewal',
        StageName='Qualified',
        Expire_Date__c=system.today(),
        CloseDate=system.today());
        //fill all the required field and make sure your data passes the validation rules.
        insert opp;
        
        dsfs__DocuSign_Status__c  dsfs = new dsfs__DocuSign_Status__c (
        
        dsfs__Completed_Date_Time__c = system.today(),
        dsfs__Opportunity__c = opp.id);
        insert dsfs;
        
        dsfs.dsfs__Completed_Date_Time__c = system.today();
        update dsfs;
    }
}