public with sharing class Hos_HospitalEditController {
    public Hos_Hospital__c hospital {get; set;}
    public String hospitalId;

    public Hos_HospitalEditController(ApexPages.StandardController ssc) {
        hospitalId = apexPages.currentPage().getParameters().get('Id');
        hospital = [SELECT Id, Name, Street__c, City__c, Country__c, Phone__c, Email__c, Website__c FROM Hos_Hospital__c WHERE Id = :hospitalId];
    }

    public PageReference saveHospital() {
        try{
            update hospital;
            return goToPage('Hos_HospitalView');
        }
        catch(DmlException e){
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference cancelEdit() {
        return goToPage('Hos_HospitalView');
    }

    public PageReference goToPage(String page) {
        PageReference pageRef = new PageReference('/apex/' + page);
        pageRef.getParameters().put('Id', hospitalId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}