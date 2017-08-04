/**
 * Discription: This is a class that creates Free Trial oppty when clickin on a custom button
 *
 *    Author           Date (mm-dd-yyyy)  Version    Changelog
 * Siddharth Pandit    08/29/2016           1.0      Inital draft
 * Samantha Hayford    03/24/2017           2.0      Corrections for Deployment
 *
 * LP URL: /space/118974/projects/show/31978073
 * Test class name : TestOpptyGeneral
 **/
global with sharing class OpptyGeneral {
    private static final String STR_NAME = 'Free Trial: ';
    private static final String STR_OBJNAME = 'Opportunity';
    private static final String STR_DATETYPE = 'Date';
    private static final String STR_CURRENCYTYPE = 'CURRENCY';
    private static final String STR_DOUBLETYPE = 'DOUBLE';

    // Class method to create new Oppty.
    // Returns a string that indicates success or failure.
    webservice static String createFreeTrial (String opptyId) {
        // Pull custom setting data
        Map<String, Schema.SObjectField> objectFieldsMap = 
        Schema.getGlobalDescribe().get(STR_OBJNAME).getDescribe().fields.getMap();
            
        // pull the existing Oppty.
        Opportunity opptyExist = [SELECT Id, Name, AccountId, Related_Opportunity__c
                                FROM Opportunity
                                WHERE Id =: opptyId];

        // Insert new Oppty, rollback if any problems
        // and return error messages to the calling environment.
        try {
	        Opportunity newOppty = new Opportunity ();
	        newOppty.Name = STR_NAME + opptyExist.Name;
            newOppty.AccountId = opptyExist.AccountId;
	        newOppty.Related_Opportunity__c = opptyExist.Id;
	        for (FreeTrialOpptySetting__c opptyField : FreeTrialOpptySetting__c.getall().values()) {
	            if (objectFieldsMap.containsKey (opptyField.Api_Name__c)) {
	                String fieldType = String.valueOf (objectFieldsMap.get (opptyField.Api_Name__c)
	                                    .getDescribe().getType());
	                if (STR_DATETYPE.equalsIgnoreCase (fieldType)) {
	                    Integer noOfDays = Integer.valueOf (opptyField.Default_Value__c);
                        newOppty.put (opptyField.Api_Name__c, Date.today().addDays (noOfDays));
	                } else if (STR_CURRENCYTYPE.equalsIgnoreCase (fieldType)) {
                        Decimal numField = Decimal.valueOf (opptyField.Default_Value__c);
                        newOppty.put (opptyField.Api_Name__c, numField);
	                } else if (STR_DOUBLETYPE.equalsIgnoreCase (fieldType)){
	                   Double numField = Double.valueOf (opptyField.Default_Value__c);
                       newOppty.put (opptyField.Api_Name__c, opptyField.Default_Value__c);
	                } else
	                   newOppty.put (opptyField.Api_Name__c, opptyField.Default_Value__c);
	            }
	        }
            Database.insert(newOppty);
            opptyExist.Related_Opportunity__c = newOppty.Id;
            Database.update (opptyExist);
        }
        catch (Exception e) {
            return e.getMessage();
        }

        // On success, return a message to the calling program.
        return 'Free Trial Opportunity is created successfully.';
    }
}