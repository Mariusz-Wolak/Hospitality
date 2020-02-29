trigger Hos_ContractOverlappingController on Hos_Contract__c (before insert) {
    Hos_TriggerFactory.createHandler(Hos_Contract__c.SObjectType);
}