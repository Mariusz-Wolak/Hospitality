public with sharing class Hos_WebServiceHandler {

    public static String createQuery(String name, String country, String email) {
        String query = 'SELECT Name, Country__c, Email__c FROM Hos_Hospital__c WHERE Name LIKE  \'%' + name + '%\'';
        query += String.isBlank(email) ? '' : 'AND Email__c LIKE \'%' + email + '%\'';
        query += String.isBlank(country) ? '' : 'AND Country__c LIKE \'%' + country + '%\'';
        return query;
    }
    
    public static List<Hos_WrappedSOAPHospital> getHospitals(String name, String country, String email){
        if(name == null || name == ''){
            throw new GetHospitalsException.OtherException('You must enter value');
        }
        List <Hos_Hospital__c> hospitals =  Database.query(createQuery(name, country, email));
        List <Hos_WrappedSOAPHospital> wrappedHospitals = new List<Hos_WrappedSOAPHospital>();

        for(Hos_Hospital__c hosp: hospitals){
            Hos_WrappedSOAPHospital wrappedHospital = new Hos_WrappedSOAPHospital(String.valueOf(hosp.Id), hosp.Name, hosp.Country__c, hosp.Email__c);
            wrappedHospitals.add(wrappedHospital);
        }

        return wrappedHospitals;
    }

    public static Hos_WebServiceResponse upsertHospital(String id, String name, String country, String email){
        String msg;
        if(id==null){
            msg = Label.Success_Adding_Hospital;
        }else{
            msg = Label.Success_Updating_Hospital;
        }
        Hos_Hospital__c hospital = new Hos_Hospital__c(Id=id, Name = name, Country__c = country, Email__c = email);
        if(name == '' || name == null){
            return new Hos_WebServiceResponse(name, String.valueOf(id), false, Label.Required_Field_Error);
        }
        try{
            Database.upsert(hospital);
            return new Hos_WebServiceResponse(name, hospital.Id, true, msg);
        } catch(DmlException e){
            return new Hos_WebServiceResponse(name, String.valueOf(id), false, e.getMessage());
        }
    }

    public static Hos_WebServiceResponse deleteHospital(String id){
        String hospitalName = '';
        try {
            Hos_Hospital__c hospital = [SELECT Name, Country__c, Email__c FROM Hos_Hospital__c WHERE Id=:id];
            hospitalName = hospital.Name;
            Database.DeleteResult delResult = Database.delete(hospital);
            return  new Hos_WebServiceResponse(hospitalName, String.valueOf(id), delResult.isSuccess(), delResult.isSuccess() ? Label.Success_Deleting_Hospital : delResult
                    .getErrors()[0].getMessage());
        } catch(DmlException e){
            return  new Hos_WebServiceResponse(hospitalName, String.valueOf(id), false, e.getMessage());
        }
    }

    public static List<String> getCountries(){
        List<String> countries = new List<String>();
        Schema.DescribeFieldResult fieldResult = Hos_Hospital__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : ple){
            countries.add(p.getLabel());
        }
        return countries;
    }
}