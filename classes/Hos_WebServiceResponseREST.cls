global with sharing class Hos_WebServiceResponseREST {
    webService String responseId{get;set;}
    webService String responseMessage{get;set;}
    webService Boolean responseStatus{get;set;}
    webService String externalId{get;set;}

    public Hos_WebServiceResponseREST(String id, String message, Boolean status, String externalId) {
        responseId = id;
        responseMessage = message;
        responseStatus = status;
        this.externalId = externalId;
    }
}