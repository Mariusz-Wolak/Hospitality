@RestResource(urlMapping='/Hos_WebServiceREST/*')
global with sharing class Hos_WebServiceREST {

    @HttpGet
    global static List<Hos_WrappedDoctorREST> getDoctors(){
        String firstName = RestContext.request.params.get('firstName');
        String lastName = RestContext.request.params.get('lastName');
        String email = RestContext.request.params.get('email');
        String country = RestContext.request.params.get('country');
        return Hos_WebServiceREST_Handler.getDoctors(firstName, lastName, email, country);
    }

    @HttpPost
    global static Hos_WebServiceResponseREST addDoctor(String firstName, String lastName, String email, String country, String externalId){
        return Hos_WebServiceREST_Handler.upsertDoctor(null, firstName, lastName, email, country, externalId);
    }
    
    @HttpPut
    global static Hos_WebServiceResponseREST updateDoctor(String id, String firstName, String lastName, String email, String country, String externalId){
        return Hos_WebServiceREST_Handler.upsertDoctor(id, firstName, lastName, email, country, externalId);
    }

    @HttpDelete
    global static Hos_WebServiceResponseREST deleteDoctor(){
        String id = RestContext.request.params.get('id');
        String externalId = RestContext.request.params.get('externalId');
        return Hos_WebServiceREST_Handler.deleteDoctor(id, externalId);
    }
}