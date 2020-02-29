public without sharing class Hos_DoctorViewController{
    public Hos_Doctor__c doc {get; set;}
    public String doctorId;
    public String contractId {get; set;}
    public Hos_Contract__c contractToDismiss {get; set;}

    public List<Hos_Contract__c> doctorContracts {
        get {
            return getDoctorContracts();
        }
        set; }

    public List<Hos_Hospital__c> hospitalResults { get; set; }
    public Hos_Hospital__c searchItem { get; set; }
    public String selectedHospitalId { get; set; }

    public List<WrapDoctorHire> wrappedHospitals {get;set;}
    public List<WrapDoctorHire> newWrappedContracts {get;set;}
    public Set<String> selectedId {get;set;}
    public Boolean allSuccess {get;set;}
    public List<String> errors {get;set;}
    public Boolean hireDisable {get;set;}

    public ApexPages.StandardSetController ssc { get; set; }

    public String emailSubject { get; set; }
    public String emailBody { get; set; }

    public Boolean isLicenseNumberEnabled {
        get{
            return Hos_Utils.isSettingEnabledForCurrentUserCountry('DoctorLicenseNumberEnabled');
        }
        set;
    }

    public class WrapDoctorHire{
        public Hos_Hospital__c hosp {get;set;}
        public Hos_Contract__c contract {get;set;}
        public Boolean selected {get;set;}
        public String status {get;set;}
        public Hos_DoctorViewController ctrl;
        public Boolean editFlag {get;set;}
        public Boolean disabled {get;set;}

        public WrapDoctorHire(Hos_DoctorViewController controller, Hos_Hospital__c hosp){
            this.ctrl = controller;
            this.hosp = hosp;
            this.contract = new Hos_Contract__c();
            selected = false;
            status = '';
            editFlag = false;
            disabled = false;
        }

        public void remove(){
            ctrl.removeSelectedItem(this);
        }

        public void toggleEditFlag(){
            editFlag = !editFlag;
            ctrl.hireDisable = !ctrl.hireDisable;
            ctrl.disableButtons(this);
        }
    }

    public Hos_DoctorViewController(ApexPages.StandardController ssc){
        doctorId = apexPages.currentPage().getParameters().get('Id');
        doc = [SELECT Name, First_Name__c, Full_Name__c, City__c, Country__c, License_Number__c, Phone__c, Street__c, Email__c, Date_of_birth__c
        FROM Hos_Doctor__c
        WHERE Id=:doctorId];
        hospitalResults = new List<Hos_Hospital__c>();
        searchItem = new Hos_Hospital__c();
        selectedId = new Set<String>();
        allSuccess = false;
        errors = new List<String>();
        hireDisable = false;
        wrappedHospitals = new List<WrapDoctorHire>();
    }

    public List<Hos_Contract__c> getDoctorContracts(){
        return Hos_DoctorViewHandler.getDoctorContracts(doctorId);
    }

    public PageReference sendEmail() {
        return Hos_DoctorViewHandler.sendEmail(doc.Email__c, emailSubject, emailBody);
    }

    public String createQuery() {
        return Hos_DoctorViewHandler.createQuery(searchItem);
    }

    public PageReference searchHospital() {
        Hos_DoctorViewController doctorController = this;
        hospitalResults = Hos_DoctorViewHandler.getHospitalResults(searchItem);
        wrappedHospitals = new List<Hos_DoctorViewController.WrapDoctorHire>();
        Hos_DoctorViewHandler.populateWrappedHospitals(wrappedHospitals, newWrappedContracts, hospitalResults, selectedId, doctorController);
        return null;
    }

    public void selectHospital() {
        newWrappedContracts = new List<WrapDoctorHire>();
        clearNewWrappedContracts(newWrappedContracts);
        Hos_DoctorViewHandler.populateNewWrappedContracts(newWrappedContracts, wrappedHospitals, selectedId, doctorId);
    }

    public void setTemplate(){
        Hos_DoctorViewHandler.setTemplate(newWrappedContracts, selectedHospitalId);
    }

    public void processSelectedContracts(){
        Hos_DoctorViewHandler.processSelectedContracts(newWrappedContracts, allSuccess, doctorContracts, doctorId);
    }

    public void disableButtons(WrapDoctorHire item){
        Hos_DoctorViewHandler.disableButtons(newWrappedContracts, item);
    }

    public void removeSelectedItem(WrapDoctorHire item){
        Hos_DoctorViewHandler.removeSelectedItem(item, newWrappedContracts, selectedId);
    }

    public PageReference goToDoctorEdit(){
        return goToPage('Hos_DoctorEdit');
    }

    public PageReference deleteDoctor(){
        delete doc;
        PageReference pageRef = new PageReference('/' + String.valueOf(doc.Id).substring(0,3));
        pageRef.setRedirect(true);
        return pageRef;
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

    public void dismissContract(){
        Hos_DoctorViewHandler.dismissContract(contractToDismiss, contractId, doctorId, doctorContracts);
    }

    public PageReference clearEmailDialog() {
        emailSubject = null;
        emailBody = null;
        return null;
    }

    public PageReference clearHireDoctorDialog() {
        ApexPages.getMessages().clear();
        searchItem = new Hos_Hospital__c();
        hospitalResults = new List<Hos_Hospital__c>();
        newWrappedContracts = new List<Hos_DoctorViewController.WrapDoctorHire>();
        wrappedHospitals = new List<WrapDoctorHire>();
        selectedHospitalId = null;
        selectedId = new Set<String>();
        hireDisable = false;
        allSuccess = false;
        errors = new List<String>();
        return null;
    }

    public PageReference clearSearchForm() {
        searchItem = new Hos_Hospital__c();
        hospitalResults = new List<Hos_Hospital__c>();
        wrappedHospitals = new List<WrapDoctorHire>();
        return null;
    }

    public void clearNewWrappedContracts(List<WrapDoctorHire> newWrappedContracts){
        for (WrapDoctorHire hosp : wrappedHospitals) {
            if (hosp.status == System.Label.Success) {
                hosp.selected = false;
                hosp.contract = new Hos_Contract__c();
                selectedId.remove(hosp.hosp.Id);
                hosp.contract.Hospital__c = null;
                hosp.contract.Doctor__c = null;
                hosp.status = null;
            }
        }
    }
}