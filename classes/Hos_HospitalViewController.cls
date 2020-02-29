public class Hos_HospitalViewController {
    public Hos_Hospital__c hospital { get; set; }
    public String hospitalId { get; set; }
    public String contractId { get; set; }
    public Hos_Contract__c contractToDismiss { get; set; }
    public Hos_Contract__c contractToPrepare { get; set; }

    public List<Hos_Contract__c> hospitalContracts {
        get {
            return Hos_HospitalViewHandler.getHospitalContracts(hospitalId);
        }
        set;
    }

    public List<Hos_Doctor__c> doctorsToHire { get; set; }
    public Hos_Doctor__c searchItemToHire { get; set; }
    public String doctorToHireId { get; set; }
    public Hos_Doctor__c doctorToHire { get; set; }

    public ApexPages.StandardSetController ssc { get; set; }
    private static final String DEFAULT_COLUMN = 'Full_Name__c';
    private static final String DEFAULT_ORDER = 'ASC';

    public Integer size { get; set; }
    public Integer numOfRecords { get; set; }
    public String order { get; set; }
    public String sortByColumn { get; set; }
    public String columnParameter { get; set; }

    public Boolean isPagesInfoShown { get; set; }
    public Boolean isHiringSuccess { get; set; }

    public Boolean isAddressSectionEnabled{
        get{
            return Hos_Utils.isAddressSectionEnabledForHospitalCountry('HospitalAddressSectionEnabled', hospital.Country__c);
        }
        set;
    }

    public Hos_HospitalViewController(ApexPages.StandardController ssc) {
        hospitalId = apexPages.currentPage().getParameters().get('Id');
        hospital = [SELECT Id, Name, Street__c, City__c, Country__c, Phone__c, Email__c, Website__c FROM Hos_Hospital__c WHERE Id = :hospitalId];
        size = 5;
        doctorsToHire = new List<Hos_Doctor__c>();
        searchItemToHire = new Hos_Doctor__c();
        contractToPrepare = new Hos_Contract__c();
        contractToPrepare.StartDate__c = System.today();
        sortByColumn = DEFAULT_COLUMN;
        order = DEFAULT_ORDER;
        isPagesInfoShown = false;
    }

    public List<Hos_Doctor__c> paginatedDoctorsToHire {
        get {
            if (ssc != null) {
                paginatedDoctorsToHire = ssc.getRecords();
            }
            return paginatedDoctorsToHire;
        }
        set;
    }



    public PageReference searchDoctor() {
        doctorsToHire = Database.query(Hos_HospitalViewHandler.createQuery(searchItemToHire, sortByColumn, order));
        paginate();
        if(doctorsToHire.size()>0) isPagesInfoShown = true;
        return null;
    }

    public void paginate() {
        ssc = new ApexPages.StandardSetController(doctorsToHire);
        ssc.setPageSize(size);
        numOfRecords = ssc.getResultSize();
    }

    public void sortBy() {
        sortByColumn = columnParameter;
        if (order == 'ASC') {
            order = 'DESC';
        } else {
            order = 'ASC';
        }
        searchDoctor();
    }

    public void selectDoctorToHire() {
        doctorToHire = [
                SELECT Id, Name, City__c, Country__c, Date_of_birth__c, Email__c, First_Name__c, Full_Name__c, License_Number__c, Next_Birthday__c, Phone__c, Street__c
                FROM Hos_Doctor__c
                WHERE Id = :doctorToHireId
        ];
    }

    public void hireDoctor() {
        isHiringSuccess = true;
        try{
            Hos_HospitalViewHandler.hireDoctor(contractToPrepare, doctorToHireId, hospitalId, hospitalContracts);
        } catch (DmlException ex) {
            isHiringSuccess = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getDmlMessage(0)));
        }
    }

    public PageReference goToHospitalEdit() {
        return goToPage('Hos_HospitalEdit');
    }

    public PageReference deleteHospital() {
        delete hospital;
        PageReference pageRef = new PageReference('/' + String.valueOf(hospital.Id).substring(0, 3));
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference goToPage(String page) {
        PageReference pageRef = new PageReference('/apex/' + page);
        pageRef.getParameters().put('Id', hospitalId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void dismissContract() {
        Hos_HospitalViewHandler.dismissContract(contractToDismiss, contractId);
        hospitalContracts = Hos_HospitalViewHandler.getHospitalContracts(hospitalId);
    }

    public void clearHireDoctorDialog() {
        ApexPages.getMessages().clear();
        contractToPrepare = new Hos_Contract__c();
        contractToPrepare.StartDate__c = System.today();
        doctorToHireId = null;
        searchItemToHire = new Hos_Doctor__c();
        doctorsToHire = new List<Hos_Doctor__c>();
        isPagesInfoShown = false;
        isHiringSuccess = false;
        paginate();
    }

    public PageReference clearSearchResults() {
        searchItemToHire = new Hos_Doctor__c();
        doctorsToHire = new List<Hos_Doctor__c>();
        paginate();
        isPagesInfoShown = false;
        return null;
    }
}