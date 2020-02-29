public with sharing class Hos_MateuszDoctorsREST_Handler {

    String sessionId { get; set; }
    Hos_URL__c MateuszsEndpoint = Hos_URL__c.getInstance('MateuszsEndpointREST');

    public void login() {
        Http httpObj = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        httpReq.setMethod('POST');
        httpReq.setBody(
                'grant_type=password' +
                        '&client_id=' + Hos_Utils.getConsumerKeyToMateuszsOrg() +
                        '&client_secret=' + Hos_Utils.getConsumerSecretToMateuszsOrg() +
                        '&username=' + Hos_Utils.getUsernameToMateuszsOrg() +
                        '&password=' + Hos_Utils.getPasswordToMateuszsOrg()
        );

        HttpResponse myHttpResponse = httpObj.send(httpReq);
        Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(myHttpResponse.getBody());
        sessionId = String.valueOf(responseBodyMap.get('access_token'));
    }

    public List<Hos_WrappedDoctorREST> getDoctors(String firstName, String lastName, String email, String country) {
        List<Hos_WrappedDoctorREST> HosWrappedDoctors = new List<Hos_WrappedDoctorREST>();
        Hos_WrappedDoctorREST wrappedDoc;
        List<Object> resBodyList = new List<Object>();
        List< Map<String, Object> > mappedDoctors = new List<Map<String, Object>>();
        String endpoint = MateuszsEndpoint.URL__c + '?firstName=' + firstName + '&lastName=' + lastName + '&country=' + country + '&email=' + email;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);

        resBodyList = (List<Object>) JSON.deserializeUntyped(res.getBody());
        for (Object o : resBodyList) {
            Map<String, Object> resBodyMap = ((Map<String, Object>) o);
            if (String.valueOf(resBodyMap.get('errorCode')) == 'APEX_ERROR') {
                throw new GetDoctorsException.OtherException(String.valueOf(resBodyMap.get('message')));
            }
            if (String.valueOf(resBodyMap.get('docId')) != null) {
                wrappedDoc = new Hos_WrappedDoctorREST();
                wrappedDoc.docId = String.valueOf(resBodyMap.get('docId'));
                wrappedDoc.docCountry = String.valueOf(resBodyMap.get('docCountry'));
                wrappedDoc.docEmail = String.valueOf(resBodyMap.get('docEmail'));
                wrappedDoc.docFirstName = String.valueOf(resBodyMap.get('docFirstName'));
                wrappedDoc.docLastName = String.valueOf(resBodyMap.get('docLastName'));
                wrappedDoc.docExternalId = String.valueOf(resBodyMap.get('externalId'));
                HosWrappedDoctors.add(wrappedDoc);
            }
        }
        return HosWrappedDoctors;
    }

    public Hos_WrappedMateuszResponse addDoctor(String firstName, String lastName, String email, String country, String externalId, Integer attempt) {
        Hos_WrappedMateuszResponse wrappedMateuszResponse = new Hos_WrappedMateuszResponse();
        Hos_Request_Logger__c newRequestLogger = new Hos_Request_Logger__c();
        Hos_Doctor__c doc = [SELECT Id, First_Name__c, Name, Email__c, Country__c, External_Id__c, isSynchronized__c, Synchronize_Attempts__c FROM Hos_Doctor__c WHERE Id =:
                externalId];

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('firstName', firstName);
        gen.writeStringField('lastName', lastName);
        gen.writeStringField('email', email);
        gen.writeStringField('country', country);
        gen.writeStringField('externalId', externalId);
        gen.writeEndObject();
        String genAsString = gen.getAsString();

        if(attempt >= 0) {
            newRequestLogger.Attempts__c = attempt;
            newRequestLogger.Deleted__c = false;
            newRequestLogger.Endpoint__c = MateuszsEndpoint.URL__c;
            newRequestLogger.Body__c = genAsString;
            newRequestLogger.Type__c = 'POST';
            newRequestLogger.External_Id__c = externalId;
            newRequestLogger.Internal_Id__c = externalId;
        }

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(MateuszsEndpoint.URL__c);
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(genAsString);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        wrappedMateuszResponse = new Hos_WrappedMateuszResponse(String.valueOf(responseMap.get('responseId')), String.valueOf(responseMap.get
                ('responseMessage')), Boolean.valueOf(responseMap.get('responseStatus')), String.valueOf(responseMap.get('externalId')));

        if(attempt >= 0  && wrappedMateuszResponse.message != 'Fields are the same') {
            newRequestLogger.Success__c = wrappedMateuszResponse.success;
            newRequestLogger.Status__c = String.valueOf(res.getStatusCode());
            newRequestLogger.Response__c = wrappedMateuszResponse.message;

            if(wrappedMateuszResponse.success){
                doc.isSynchronized__c = true;
                doc.Synchronize_Attempts__c = 0;
            }else{
                doc.isSynchronized__c = false;
                doc.Synchronize_Attempts__c = attempt;
            }
            try {
                insert newRequestLogger;
                update doc;
            }catch(Exception e) {

            }finally{
                return wrappedMateuszResponse;
            }
        }

        return wrappedMateuszResponse;
    }

    public Hos_WrappedMateuszResponse updateDoctor(String id, String firstName, String lastName, String email, String country, String externalId, Integer attempt) {
        Boolean hasChanged = false;
        Hos_WrappedMateuszResponse wrappedMateuszResponse = new Hos_WrappedMateuszResponse();
        Hos_Request_Logger__c newRequestLogger = new Hos_Request_Logger__c();

        Hos_Doctor__c doc = [SELECT Id, First_Name__c, Name, Email__c, Country__c, External_Id__c, isSynchronized__c, Synchronize_Attempts__c
                                FROM Hos_Doctor__c WHERE Id =: externalId];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('id', id);
        gen.writeStringField('firstName', firstName);
        gen.writeStringField('lastName', lastName);
        gen.writeStringField('email', email);
        gen.writeStringField('country', country);
        gen.writeStringField('externalId', externalId);
        gen.writeEndObject();
        String genAsString = gen.getAsString();

        if(attempt >= 0) {
            newRequestLogger.Attempts__c = attempt;
            newRequestLogger.Deleted__c = false;
            newRequestLogger.Endpoint__c = MateuszsEndpoint.URL__c;
            newRequestLogger.Body__c = genAsString;
            newRequestLogger.Type__c = 'PUT';
            newRequestLogger.External_Id__c = externalId;
            newRequestLogger.Internal_Id__c = externalId;
        }

        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setEndpoint(MateuszsEndpoint.URL__c);
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(genAsString);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        wrappedMateuszResponse = new Hos_WrappedMateuszResponse(String.valueOf(responseMap.get('responseId')), String.valueOf(responseMap.get
                ('responseMessage')), Boolean.valueOf(responseMap.get('responseStatus')), String.valueOf(responseMap.get('externalId')));

        if(attempt >= 0) {
            if(wrappedMateuszResponse.success){
                if(doc.isSynchronized__c == true && doc.Synchronize_Attempts__c == 0){
                    hasChanged = false;
                }else{
                    doc.isSynchronized__c = true;
                    doc.Synchronize_Attempts__c = 0;
                    hasChanged = true;
                }
            }else{
                if(doc.isSynchronized__c == false && doc.Synchronize_Attempts__c == attempt) {
                    hasChanged = false;
                }else{
                    doc.isSynchronized__c = false;
                    doc.Synchronize_Attempts__c = attempt;
                    hasChanged = true;
                }
            }

            if(hasChanged){
                update doc;
                newRequestLogger.Success__c = wrappedMateuszResponse.success;
                newRequestLogger.Status__c = String.valueOf(res.getStatusCode());
                newRequestLogger.Response__c = wrappedMateuszResponse.message;
                insert newRequestLogger;
            }
        }

        return wrappedMateuszResponse;
    }

    public Hos_WrappedMateuszResponse deleteDoctor(String id, String externalId, Integer attempt) {
        String endpoint = MateuszsEndpoint.URL__c + '?id=' + id + '&externalId=' + externalId;
        Hos_Request_Logger__c newRequestLogger = new Hos_Request_Logger__c();

        if(attempt >= 0) {
            newRequestLogger.Attempts__c = attempt;
            newRequestLogger.Deleted__c = false;
            newRequestLogger.Endpoint__c = endpoint;
            newRequestLogger.Body__c = '{ "id" : "' + id + '", "externalId" : "' + externalId + '" }';
            newRequestLogger.Type__c = 'DELETE';
            newRequestLogger.External_Id__c = externalId;
            newRequestLogger.Internal_Id__c = externalId;
        }

        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Hos_WrappedMateuszResponse wrappedMateuszResponse = new Hos_WrappedMateuszResponse(String.valueOf(responseMap.get('responseId')), String.valueOf(responseMap.get
                ('responseMessage')), Boolean.valueOf(responseMap.get('responseStatus')), String.valueOf(responseMap.get('externalId')));

        if(attempt >= 0) {
            newRequestLogger.Success__c = wrappedMateuszResponse.success;
            newRequestLogger.Status__c = String.valueOf(res.getStatusCode());
            newRequestLogger.Response__c = wrappedMateuszResponse.message;
            insert newRequestLogger;
        }
        return wrappedMateuszResponse;
    }

    public List<String> getCountries() {
        List<Object> resBodyList = new List<Object>();
        List<String> countries = new List<String>();

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(MateuszsEndpoint.URL__c + '/countries');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);

        resBodyList = (List<Object>) JSON.deserializeUntyped(res.getBody());
        for (Object o : resBodyList) {
            countries.add(String.valueOf(o));
        }
        return countries;
    }
}