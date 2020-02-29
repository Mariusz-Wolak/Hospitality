public with sharing class Hos_DoctorEditController {
    public Hos_Doctor__c doc {get; set;}
    public String doctorId;

    public Hos_DoctorEditController(ApexPages.StandardController ssc) {
        doctorId = apexPages.currentPage().getParameters().get('Id');
        doc = [
                SELECT Name, First_Name__c, Full_Name__c, City__c, Country__c, License_Number__c, Phone__c, Street__c, Email__c, Date_of_birth__c
                FROM Hos_Doctor__c
                WHERE Id = :doctorId
        ];
    }

    public PageReference saveDoctor(){
        try{
            update doc;
            return goToPage('Hos_DoctorView');
        }
        catch(DmlException e){
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference cancelEdit(){
        return goToPage('Hos_DoctorView');
    }

    public PageReference goToPage(String page){
        PageReference pageRef = new PageReference('/apex/'+page);
        pageRef.getParameters().put('Id', doctorId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}