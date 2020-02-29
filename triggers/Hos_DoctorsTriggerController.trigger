trigger Hos_DoctorsTriggerController on Hos_Doctor__c (after insert, after update, after delete) {
    Hos_TriggerFactory.createHandler(Hos_Doctor__c.SObjectType);
}