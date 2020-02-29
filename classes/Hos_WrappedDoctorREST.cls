global with sharing class Hos_WrappedDoctorREST {
    webService String docFirstName{get;set;}
    webService String docLastName{get;set;}
    webService String docEmail{get;set;}
    webService String docCountry{get;set;}
    webService String docId{get;set;}
    webService String docExternalId{get;set;}

    public Hos_WrappedDoctorREST(){}

    public Hos_WrappedDoctorREST(String docFirstName, String docLastName, String docEmail, String docCountry, String docId, String docExternalId){
        this.docFirstName = docFirstName;
        this.docLastName = docLastName;
        this.docEmail = docEmail;
        this.docCountry = docCountry;
        this.docId = docId;
        this.docExternalId = docExternalId;
    }
}