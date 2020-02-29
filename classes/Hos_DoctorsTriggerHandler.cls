public with sharing class Hos_DoctorsTriggerHandler implements Hos_ITrigger{
    public void bulkBefore() {}
    public void bulkAfter() {}
    public void beforeInsert(List<Hos_Contract__c> newlstObj) {}
    public void beforeUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {}
    public void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj) {}
    public void afterInsert(List<SObject> newlstObj,Map<Id,SObject> newMapObj) {
        if(isExternalIdBlank(newlstObj)){
            List<Hos_DoctorRequestBody> requestDoctors = convertToRequestDoctors(newlstObj);

            Hos_Doctor__c doctor = [SELECT Id, Name, External_Id__c, isSynchronized__c, Synchronize_Attempts__c FROM Hos_Doctor__c WHERE Id =: newlstObj[0].Id];
            doctor.isSynchronized__c = false;
            doctor.Synchronize_Attempts__c = 0;
            doctor.External_Id__c = newlstObj[0].Id;

            update doctor;
            requestDoctors = setExternalId(requestDoctors);
            System.enqueueJob(new Hos_DoctorsIntegrationCallout(requestDoctors, 'POST'));
        }
    }
    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj) {
            List<Hos_DoctorRequestBody> requestDoctors = convertToRequestDoctors(newlstObj);
            System.enqueueJob(new Hos_DoctorsIntegrationCallout(requestDoctors, 'PUT'));
    }
    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj) {
            List<Hos_DoctorRequestBody> requestDoctors = convertToRequestDoctors(oldlstObj);
            System.enqueueJob(new Hos_DoctorsIntegrationCallout(requestDoctors, 'DELETE'));
    }
    public void andFinally() {}
    
    public List<Hos_DoctorRequestBody> convertToRequestDoctors(List<Hos_Doctor__c> doctors){
        List<Hos_DoctorRequestBody> requestDoctors = new List<Hos_DoctorRequestBody>();
        for (Hos_Doctor__c doctor : doctors){
            Hos_DoctorRequestBody doc = new Hos_DoctorRequestBody(doctor.id, doctor.First_Name__c, doctor.Name, doctor.Email__c, doctor.Country__c, doctor.External_Id__c);
            requestDoctors.add(doc);
        }
        return requestDoctors;
    }

    public Boolean isExternalIdBlank(List<Hos_Doctor__c> doctors){
        for(Hos_Doctor__c doctor : doctors){
            if(!String.isBlank(doctor.External_Id__c)){
                return false;
            }
        }
        return true;
    }

    public List<Hos_DoctorRequestBody> setExternalId(List<Hos_DoctorRequestBody> doctors){
        for(Hos_DoctorRequestBody doctor : doctors){
            doctor.externalId = doctor.id;
        }
        return doctors;
    }
}