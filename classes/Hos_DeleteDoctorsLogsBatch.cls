global class Hos_DeleteDoctorsLogsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    public Hos_MateuszDoctorsREST_Handler mateuszREST_Handler = new Hos_MateuszDoctorsREST_Handler();

    global Database.QueryLocator start(Database.BatchableContext BC){

        String query = 'SELECT Attempts__c, Body__c, Endpoint__c, External_Id__c, Internal_Id__c, Response__c, Status__c, Success__c, Type__c FROM ' +
                'Hos_Request_Logger__c WHERE CreatedDate < LAST_N_DAYS: 5';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        mateuszREST_Handler.login();
        delete scope;
    }

    global void finish(Database.BatchableContext BC){

    }
}