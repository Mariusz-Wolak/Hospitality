global with sharing class Hos_WrappedSOAPHospital {
    webService String hospitalId{get;set;}
    webService String hospitalName{get;set;}
    webService String hospitalCountry{get;set;}
    webService String hospitalEmail{get;set;}

    public Hos_WrappedSOAPHospital(){}

    public Hos_WrappedSOAPHospital(String id, String name, String country, String email){
        hospitalId = id;
        hospitalName = name;
        hospitalCountry = country;
        hospitalEmail = email;
    }
}