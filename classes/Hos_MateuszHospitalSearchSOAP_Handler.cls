public with sharing class Hos_MateuszHospitalSearchSOAP_Handler {

    Hos_partnerMateuszSoapSforceCom.Soap partner;
    Hos_partnerMateuszSoapSforceCom.LoginResult lr;
    Hos_HRHM_SOAP_HospitalController3.SessionHeader_element header;
    Hos_HRHM_SOAP_HospitalController3.HRHM_SOAP_HospitalController externalWebService = new Hos_HRHM_SOAP_HospitalController3.HRHM_SOAP_HospitalController();

    public void login (){
        header = new Hos_HRHM_SOAP_HospitalController3.SessionHeader_element();
        partner = new Hos_partnerMateuszSoapSforceCom.Soap();
        lr = partner.login(Hos_Utils.getUsernameToMateuszsOrg(), Hos_Utils.getPasswordToMateuszsOrg());
        header.sessionId = lr.sessionId;
        externalWebService.SessionHeader = header;
    }

    public List<Hos_WrappedSOAPHospital> getHospitals(String name, String country, String email) {
        List<Hos_WrappedSOAPHospital> HosWrappedHospitals = new List<Hos_WrappedSOAPHospital>();
        List<Hos_HRHM_SOAP_Wrapper3.HRHM_SOAP_Wrapper> HrhmWrappedHospitals = new List<Hos_HRHM_SOAP_Wrapper3.HRHM_SOAP_Wrapper>();
        try{
            HrhmWrappedHospitals = externalWebService.getHospitals(name, country, email);
        }catch(Exception e){
            throw new GetHospitalsException.OtherException(e.getMessage());
        }
        if (HrhmWrappedHospitals != null) {
            for (Hos_HRHM_SOAP_Wrapper3.HRHM_SOAP_Wrapper hos : HrhmWrappedHospitals) {
                HosWrappedHospitals.add(new Hos_WrappedSOAPHospital(hos.id, hos.name, hos.country, hos.email));
            }
        }
        return HosWrappedHospitals;
    }

    public Hos_WrappedMateuszResponseSOAP addHospital(String name, String country, String email){
        Hos_HRHM_SOAP_ResponseHospital3.HRHM_SOAP_ResponseHospital response = externalWebService.addHospital(null, name, country, email);
        return new Hos_WrappedMateuszResponseSOAP(response.responseId, response.success, response.errorMsg);
    }

    public Hos_WrappedMateuszResponseSOAP updateHospital(String id, String name, String country, String email){
        Hos_HRHM_SOAP_ResponseHospital3.HRHM_SOAP_ResponseHospital response = externalWebService.updateHospital(id, name, country, email);
        return new Hos_WrappedMateuszResponseSOAP(response.responseId, response.success, response.errorMsg);
    }

    public Hos_WrappedMateuszResponseSOAP deleteHospital(String id){
        Hos_HRHM_SOAP_ResponseHospital3.HRHM_SOAP_ResponseHospital response = externalWebService.deleteHospital(id);
        return new Hos_WrappedMateuszResponseSOAP(response.responseId, response.success, response.errorMsg);
    }

    public List<String> getCountries(){
        return externalWebService.getCountries();
    }

    public Boolean checkIfSuccess(String hospitalName){
        if(hospitalName == ''){
            return false;
        }
        else{
            return true;
        }
    }
}