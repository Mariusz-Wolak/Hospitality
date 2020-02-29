public with sharing class Hos_WebServiceREST_Handler {

    public static List<Hos_WrappedDoctorREST> getDoctors(String firstName, String lastName, String email, String country) {
        if (lastName == null || lastName == '' || String.isBlank(lastName.trim())) {
            throw new GetHospitalsException.OtherException(Label.Required_Last_Name);
        }
        List<Hos_Doctor__c> doctorsAfterQuery = new List<Hos_Doctor__c>();
        List<Hos_WrappedDoctorREST> doctors = new List<Hos_WrappedDoctorREST>();

        String query = 'SELECT Id, External_Id__c, First_Name__c, Name, Country__c, Email__c FROM Hos_Doctor__c';

        if (String.isNotBlank(lastName) || String.isNotBlank(firstName) || String.isNotBlank(country) || String.isNotBlank(email)) {
            query+=' WHERE ';

            if (String.isNotBlank(lastName)) {
                query += 'Name LIKE \'%' + lastName + '%\'';
            }
            if(String.isNotBlank(firstName)){
                query+= ' AND First_Name__c LIKE \'%' + firstName +'%\'';
            }
            if (String.isNotBlank(email)) {
                query += ' AND Email__c LIKE \'%' + email + '%\'';
            }
            if (String.isNotBlank(country)) {
                query += ' AND Country__c LIKE \'%' + country + '%\'';
            }
        }

        doctorsAfterQuery = Database.query(query);
        if(doctorsAfterQuery.size()>0) {
            for (Hos_Doctor__c doctor : doctorsAfterQuery) {
                doctors.add(new Hos_WrappedDoctorREST(doctor.First_Name__c, doctor.Name,doctor.Email__c, doctor.Country__c,
                        String.valueOf(doctor.Id), String.valueOf(doctor.External_Id__c)));
            }
        }else{
            return new List<Hos_WrappedDoctorREST>();
        }
        return doctors;
    }

    public static Hos_WebServiceResponseREST deleteDoctor(String id, String externalId) {
        Set<String> Ids = new Set<String>();
        Ids.add(id);
        Ids.add(externalId);
        Database.DeleteResult deleteResult;
        Hos_WebServiceResponseREST response;
        try {
            Hos_Doctor__c doctor = [SELECT Id, External_Id__c FROM Hos_Doctor__c WHERE Id in :Ids OR External_Id__c in :Ids LIMIT 1];
            if (doctor == null) {
                return new Hos_WebServiceResponseREST(id, Label.Blank_Value, false, doctor.External_Id__c);
            }
            deleteResult = Database.delete(doctor);
            if (deleteResult.isSuccess()) {
                response = new Hos_WebServiceResponseREST(String.valueOf(deleteResult.id), Label.Success_Deleting_Doctor, true, doctor.External_Id__c);
            } else {
                response = new Hos_WebServiceResponseREST(String.valueOf(deleteResult.id), deleteResult.getErrors().get(0).getMessage(), false, doctor.External_Id__c);
            }
            return response ;
        } catch (DmlException dmle) {
            response = new Hos_WebServiceResponseREST(String.valueOf(deleteResult.id), dmle.getMessage(), false, '');
            return response;
        }
    }

    public static Hos_WebServiceResponseREST upsertDoctor(String id, String firstName, String lastName, String email, String country, String externalId) {
        Boolean isChanged = true;
        Hos_Doctor__c doctor;
        String resultId;
        Hos_WebServiceResponseREST response;
        String msg;
        if (lastName == null || lastName == '') {
            return new Hos_WebServiceResponseREST(id, Label.Required_Last_Name, false, externalId);
        }

        if (id != null) {
            msg = Label.Success_Updating_Doctor;
            doctor = [SELECT First_Name__c, Name, Email__c, Country__c, External_Id__c FROM Hos_Doctor__c WHERE External_Id__c = :externalId LIMIT 1];
            if(( doctor.First_Name__c == firstName) && (doctor.Name == lastName)
                    && (doctor.Email__c == email) && (doctor.Country__c == country)){
                isChanged = false;
            }
            doctor.First_Name__c = firstName;
            doctor.Name = lastName;
            doctor.Country__c = country;
            doctor.Email__c = email;
        } else {
            msg = Label.Success_Adding_Doctor;
            doctor = new Hos_Doctor__c();
            doctor.First_Name__c = firstName;
            doctor.Name = lastName;
            doctor.Country__c = country;
            doctor.Email__c = email;
            if(String.isBlank(doctor.External_Id__c)){
                doctor.External_Id__c = externalId;
            }
        }
        try {
            Database.UpsertResult result;
            if(isChanged == true) {
                result = Database.upsert(doctor);
            }
            resultId = result.id;
            if (result.success) {
                response = new Hos_WebServiceResponseREST(resultId, msg, true, doctor.External_Id__c) ;
            } else {
                response = new Hos_WebServiceResponseREST(resultId, result.getErrors().get(0).getMessage(), false, doctor.External_Id__c);
            }
            return response;
        } catch (DmlException e) {
            return new Hos_WebServiceResponseREST(resultId, e.getMessage(), false, doctor.External_Id__c);
        }
    }

    public static List<String> getCountries() {
        List<String> countries = new List<String>();
        Schema.DescribeFieldResult fieldResult = Hos_Doctor__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : ple) {
            countries.add(p.getLabel());
        }
        return countries;
    }
}