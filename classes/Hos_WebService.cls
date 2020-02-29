global class Hos_WebService {

    webService static List<Hos_WrappedSOAPHospital> getHospitals(String name, String country, String email){
        return Hos_WebServiceHandler.getHospitals(name, country, email);
    }

    webService static Hos_WebServiceResponse addHospital(String name, String country, String email){
        return Hos_WebServiceHandler.upsertHospital(null, name, country, email);
    }

    webService static Hos_WebServiceResponse updateHospital(String id, String name, String country, String email){
        return Hos_WebServiceHandler.upsertHospital(id, name, country, email);
    }

    webService static Hos_WebServiceResponse deleteHospital(String id){
        return Hos_WebServiceHandler.deleteHospital(id);
    }

    webService static List<String> getCountries(){
        return Hos_WebServiceHandler.getCountries();
    }
}