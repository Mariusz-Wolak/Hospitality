public with sharing class Hos_SearchDoctorController{
    public List<Hos_Doctor__c> doctors { get; set; }
    public Hos_Doctor__c searchItem { get; set; }

    public ApexPages.StandardSetController ssc { get; set; }
    private static final String DEFAULT_COLUMN = 'Full_Name__c';
    private static final String DEFAULT_ORDER = 'ASC';

    public Integer size { get; set; }
    public Integer numOfRecords {get; set; }
    public String order { get; set; }
    public String sortByColumn { get; set; }
    public String columnParameter { get; set; }

    public String csvBody { get; set; }
    public String jsonBody { get; set; }

    public Boolean isPagesInfoShown { get; set;}

    public List<Hos_Doctor__c> paginatedResults {
        get {
            if (ssc != null) {
                paginatedResults = ssc.getRecords();
            }
            return paginatedResults;
        }
        set;
    }

    public Hos_SearchDoctorController(ApexPages.StandardController sc) {
        size = 5;
        doctors = new List<Hos_Doctor__c>();
        searchItem = new Hos_Doctor__c();
        sortByColumn = DEFAULT_COLUMN;
        order = DEFAULT_ORDER;
        isPagesInfoShown = false;
    }

    public String createQuery() {
        String query = 'SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c ';
        if (searchItem.Name != null || searchItem.Country__c != null || searchItem.First_Name__c != null || searchItem.Email__c != null) {
            query += 'WHERE ' ;
            if (String.isNotBlank(searchItem.Name)) {
                query += 'Name LIKE \'' + searchItem.Name + '%\' ';
            }
            if (String.isNotBlank(searchItem.First_Name__c)) {
                query += 'AND ' ;
                query += 'First_Name__c LIKE \'' + searchItem.First_Name__c + '%\' ';
            }

            if (String.isNotBlank(searchItem.Country__c)) {
                query += 'AND ' ;
                query += 'Country__c LIKE \'' + searchItem.Country__c + '%\' ';
            }
            if (String.isNotBlank(searchItem.Email__c)) {
                query += 'AND ' ;
                query += 'Email__c LIKE \'' + searchItem.Email__c + '%\' ';
            }
            query += 'ORDER BY ' + sortByColumn + ' ' + order;

        }
        System.debug(query);
        return query;
    }

    public PageReference searchDoctor() {
        doctors = Database.query(createQuery());
        paginate();
        isPagesInfoShown = true;
        return null;
    }

    public PageReference exportToCSV() {
        csvBody = getCsvString();
        PageReference page = new PageReference('/apex/Hos_ExportDoctorCSV');
        page.setRedirect(false);
        return page;
    }

    private String getCsvString() {
        String csvRows = '';
        csvRows += '"Full name"' + ',' + '"Email"' + ',' + '"Country"' + '\r\n';
        for (Hos_Doctor__c doctor : doctors) {
            csvRows += '\"' + doctor.Full_Name__c  + '\"' + ',' + '\"' + doctor.Email__c + '\"' + ',' + '\"' + doctor.Country__c + '\"' + '\r\n';
        }
        return csvRows;
    }

    public PageReference exportToXLS() {
        PageReference page = new PageReference('/apex/Hos_ExportDoctorXLS');
        return page;
    }

    private String jsongenerator() {
        List<Hos_DoctorsToJSON> doctorsToJSON = new List<Hos_DoctorsToJSON>();
        for (Hos_Doctor__c doctor : doctors) {
            doctorsToJSON.add(new Hos_DoctorsToJSON(doctor.Full_Name__c, doctor.Email__c, doctor.Country__c));
        }
        for (Hos_DoctorsToJson doc : doctorsToJSON) {
            jsonBody += JSON.serializePretty(doc);
        }
        return jsonBody;
    }

    public PageReference exportToJSON() {
        jsonBody = jsongenerator();
        PageReference page = new PageReference('/apex/Hos_ExportDoctorJSON');
        page.setRedirect(false);
        System.debug(page);
        return page;
    }

    public void paginate() {
        ssc = new ApexPages.StandardSetController(doctors);
        ssc.setPageSize(size);
        numOfRecords = ssc.getResultSize();
    }

    public void sortBy(){
        sortByColumn = columnParameter;
        if (order == 'ASC') {
            order = 'DESC';
        } else{
            order = 'ASC';
        }
        searchDoctor();
    }

    public PageReference clear(){
        searchItem = new Hos_Doctor__c();
        doctors = new List<Hos_Doctor__c>();
        paginate();
        isPagesInfoShown = false;
        return null;
    }
}