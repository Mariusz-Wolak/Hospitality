public with sharing class Hos_Utils {

    public Hos_Utils(ApexPages.StandardController ssc){

    }

    public static Boolean isSettingEnabledForCurrentUserCountry(String settingName){
        return isSettingEnabled(settingName, getCurrentUser().Country);
    }

    public static Boolean isAddressSectionEnabledForHospitalCountry(String settingName, string country){
        return isSettingEnabled(settingName, country);
    }

    public static Boolean isSettingEnabled(String settingName, String valueToCheck){
        Hos_Setting__c csItem = Hos_Setting__c.getInstance(settingName);
        if(csItem==null){
            return false;
        }
        else{
            Set<String> csItems = new Set<String>(csItem.Value__c.split(','));
            return csItems.contains(valueToCheck);
        }
    }

    public static Boolean isTriggerExceptionEnabled(Schema.sObjectType soType) {
        Hos_TriggerException__c triggerEx = Hos_TriggerException__c.getInstance();
            if (triggerEx == null) {
            return false;
        }
        
        SObjectType type = Schema.getGlobalDescribe().get((String.valueOf(triggerEx).split(':')[0]));
        Map<String,Schema.SObjectField> mapFields = type.getDescribe().fields.getMap();

        for(String key : mapFields.keySet()){
            if(String.valueOf(mapFields.get(key)) == String.valueOf(soType)){
                return (Boolean) triggerEx.get(mapFields.get(key));
            }
        }

        return false;
    }

    public static User getCurrentUser(){
        return getUser(UserInfo.getUserId());
    }

    public static User getUser(String userId){
        List<User> user = [SELECT email, country FROM User WHERE Id =: userId];

        if(user==null){
            return null;
        }
        else{
            return user[0];
        }
    }

    public static String getUsernameToMateuszsOrg(){
        SOAP_User__c myUser = SOAP_User__c.getInstance('SOAP_Mateusz');
        return myUser.Username__c;
    }

    public static String getPasswordToMateuszsOrg(){
        SOAP_User__c myUser = SOAP_User__c.getInstance('SOAP_Mateusz');
        return myUser.Password__c;
    }

    public static String getConsumerKeyToMateuszsOrg(){
        Hos_KeysREST__c mateuszsKeysREST = Hos_KeysREST__c.getInstance('MateuszsKeys');
        return mateuszsKeysREST.ConsumerKey__c;
    }

    public static String getConsumerSecretToMateuszsOrg(){
        Hos_KeysREST__c mateuszsKeysREST = Hos_KeysREST__c.getInstance('MateuszsKeys');
        return mateuszsKeysREST.ConsumerSecret__c;
    }
}