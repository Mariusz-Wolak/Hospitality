@RestResource(urlMapping='/Hos_WebServiceREST/Countries/*')

global with sharing class Hos_GetCountriesREST {
    @HttpGet
    global static List<String> getCountries() {
        return Hos_WebServiceREST_Handler.getCountries();
    }
}