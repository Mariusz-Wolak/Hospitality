public with sharing class Hos_MateuszHospitalSearchSOAP_Controller {

    public Hos_MateuszHospitalSearchSOAP_Handler MateuszSOAP_Handler = new Hos_MateuszHospitalSearchSOAP_Handler();

    public Hos_WrappedSOAPHospital searchItem{get;set;}
    public Hos_WrappedSOAPHospital hospital{get;set;}
    public List<Hos_WrappedSOAPHospital> hospitalResults{get;set;}
    public String hospitalId{get;set;}
    public Boolean isSuccess{get;set;}
    public Hos_WrappedMateuszResponseSOAP mateuszResponse{get;set;}

    public List<SelectOption> countries{get;set;}

    public Hos_MateuszHospitalSearchSOAP_Controller(){
        mateuszResponse = new Hos_WrappedMateuszResponseSOAP();
        MateuszSOAP_Handler.login();
        hospital = new Hos_WrappedSOAPHospital();
        hospitalResults = new List<Hos_WrappedSOAPHospital>();
        searchItem = new Hos_WrappedSOAPHospital();
        fillCountriesSelectOptions();
    }

    public pageReference searchHospitals(){
        isSuccess = MateuszSOAP_Handler.checkIfSuccess(hospital.hospitalName);
        try{
            hospitalResults = MateuszSOAP_Handler.getHospitals(searchItem.hospitalName, searchItem.hospitalCountry, searchItem.hospitalEmail);
        }catch(Exception e){
            isSuccess = false;
            mateuszResponse.message = String.valueOf(e.getMessage());
        }
        return null;
    }

    public pageReference addHospital(){
        isSuccess = MateuszSOAP_Handler.checkIfSuccess(hospital.hospitalName);
        mateuszResponse = MateuszSOAP_Handler.addHospital(hospital.hospitalName, hospital.hospitalCountry, hospital.hospitalEmail);
        if(isSuccess) searchHospitals();
        return null;
    }

    public pageReference updateHospital(){
        isSuccess = MateuszSOAP_Handler.checkIfSuccess(hospital.hospitalName);
        mateuszResponse = MateuszSOAP_Handler.updateHospital(hospitalId, hospital.hospitalName, hospital.hospitalCountry, hospital.hospitalEmail);
        if(isSuccess) searchHospitals();
        return null;
    }

    public pageReference deleteHospital(){
        mateuszResponse = MateuszSOAP_Handler.deleteHospital(hospitalId);
        searchHospitals();
        return null;
    }

    public void fillCountriesSelectOptions(){
        List<String> retrievedCountries = MateuszSOAP_Handler.getCountries();

        countries = new List<SelectOption>();
        for(String s: retrievedCountries){
            countries.add(new SelectOption(s, s));
        }
    }

    public void prepareNewHospitalDialog(){
        isSuccess = false;
        hospitalId = null;
        hospital = new Hos_WrappedSOAPHospital();
        hospital.hospitalName = null;
        hospital.hospitalEmail = null;
        hospital.hospitalCountry = null;
        hospital.hospitalId = null;
    }

    public void prepareUpdateHospitalDialog(){
        isSuccess = false;
        for(Hos_WrappedSOAPHospital hosp: hospitalResults){
            if(hosp.hospitalId == hospitalId){
                hospital = new Hos_WrappedSOAPHospital();
                hospital.hospitalName = hosp.hospitalName;
                hospital.hospitalEmail = hosp.hospitalEmail;
                hospital.hospitalCountry = hosp.hospitalCountry;
            }
        }
    }

    public pageReference clear(){
        searchItem = new Hos_WrappedSOAPHospital();
        hospitalResults = new List<Hos_WrappedSOAPHospital>();
        return null;
    }
}