public with sharing class Hos_DoctorViewHandler {
    public static List<Hos_Contract__c> getDoctorContracts(String doctorId){
        return [SELECT Hospital__c, Doctor__c, StartDate__c, EndDate__c, Status__c, Name, Doctor__r.First_Name__c, Doctor__r.Name, Doctor__r.Full_Name__c
                FROM Hos_Contract__c
                WHERE Doctor__r.Id = :doctorId];
    }

    public static PageReference sendEmail(String docEmail, String emailSubject, String emailBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String emailAddress = docEmail;

        List<String> myAdresses = new List<String>();
        myAdresses.add(emailAddress);

        email.setToAddresses(myAdresses);
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);

        Messaging.SendEmailResult [] emailResults =
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        return null;
    }

    public static String createQuery(Hos_Hospital__c searchItem) {
        String query = 'SELECT Name, Country__c, Email__c FROM Hos_Hospital__c ';
        if (searchItem.Name != null || searchItem.Country__c != null || searchItem.Email__c != null) {
            query += 'WHERE ' ;
            if (String.isNotBlank(searchItem.Name)) {
                query += 'Name LIKE \'' + searchItem.Name + '%\' ';
            }
            if (String.isNotBlank(searchItem.Country__c)) {
                query += 'AND ' ;
                query += 'Country__c LIKE\'' + searchItem.Country__c + '%\' ';
            }
            if (String.isNotBlank(searchItem.Email__c)) {
                query += 'AND ' ;
                query += 'Email__c LIKE\'' + searchItem.Email__c + '%\' ';
            }
        }
        return query;
    }

    public static List<Hos_Hospital__c> getHospitalResults(Hos_Hospital__c searchItem){
        return Database.query(createQuery(searchItem));
    }

    public static void populateNewWrappedContracts(List<Hos_DoctorViewController.WrapDoctorHire> newWrappedContracts, List<Hos_DoctorViewController.WrapDoctorHire>
            wrappedHospitals, Set<String> selectedId, String doctorId){
        for (Hos_DoctorViewController.WrapDoctorHire hosp : wrappedHospitals){
            if (hosp.selected == true) {
                hosp.contract.Hospital__c = hosp.hosp.Id;
                hosp.contract.Doctor__c = doctorId;
                hosp.status = null;
                selectedId.add(hosp.hosp.Id);
                newWrappedContracts.add(hosp);
            }
        }
    }

    public static void populateWrappedHospitals(List<Hos_DoctorViewController.WrapDoctorHire> wrappedHospitals, List<Hos_DoctorViewController.WrapDoctorHire> newWrappedContracts,
                                                List<Hos_Hospital__c> hospitalResults, Set<String> selectedId, Hos_DoctorViewController doctorController){
        if(!newWrappedContracts.isEmpty()){
            for(Hos_DoctorViewController.WrapDoctorHire item : newWrappedContracts){
                wrappedHospitals.add(item);
            }
        }
        for (Hos_Hospital__c hosp : hospitalResults){
            if(!selectedId.contains(hosp.Id)){
                wrappedHospitals.add(new Hos_DoctorViewController.WrapDoctorHire(doctorController,hosp));
            }
        }
    }

    public static void setTemplate(List<Hos_DoctorViewController.WrapDoctorHire> newWrappedContracts, String selectedHospitalId){
        Date startDate;
        Date endDate;
        for (Hos_DoctorViewController.WrapDoctorHire contract : newWrappedContracts){
            if (contract.hosp.Id == selectedHospitalId) {
                startDate = contract.contract.StartDate__c;
                endDate = contract.contract.EndDate__c;
            }
        }
        for (Hos_DoctorViewController.WrapDoctorHire contract : newWrappedContracts){
            contract.contract.StartDate__c = startDate;
            contract.contract.EndDate__c = endDate;
        }
    }

    public static void processSelectedContracts(List<Hos_DoctorViewController.WrapDoctorHire> newWrappedContracts, Boolean allSuccess, List<Hos_Contract__c> doctorContracts, String doctorId){
        List<Hos_Contract__c> selectedContracts = new List<Hos_Contract__c>();
        List<String> errors = new List<String>();
        for(Hos_DoctorViewController.WrapDoctorHire contract : newWrappedContracts){
            if(contract.selected == true){
                selectedContracts.add(contract.contract);
            }
        }

        List<Database.UpsertResult> addedHospitals = Database.upsert(selectedContracts,false);
        Integer i = 0;
        for (Hos_DoctorViewController.WrapDoctorHire hosp : newWrappedContracts) {
            if (hosp.selected == true) {
                if(addedHospitals.get(i).isSuccess()){
                    hosp.status = System.Label.Success;
                }
                else{
                    hosp.status = addedHospitals.get(i).errors[0].getMessage();
                    errors.add(addedHospitals.get(i).errors[0].getMessage());
                }
                i++;
            }
        }
        if (errors.isEmpty()) {
            allSuccess = !allSuccess;
            doctorContracts = getDoctorContracts(doctorId);
        }
    }

    public static void disableButtons(List<Hos_DoctorViewController.WrapDoctorHire> newWrappedContracts, Hos_DoctorViewController.WrapDoctorHire item){
        for (Integer i = 0; i<newWrappedContracts.size();i++){
            if (newWrappedContracts[i] != item){
                newWrappedContracts[i].disabled = !newWrappedContracts[i].disabled;
            }
        }
    }

    public static void removeSelectedItem(Hos_DoctorViewController.WrapDoctorHire item, List<Hos_DoctorViewController.WrapDoctorHire> newWrappedContracts, Set<String> selectedId){
        for (Integer i = 0; i < newWrappedContracts.size();i++){
            if (newWrappedContracts[i] == item) {
                newWrappedContracts[i].selected = false;
                newWrappedContracts[i].contract = new Hos_Contract__c();
                newWrappedContracts.remove(i);
                break;
            }
        }
        for (String id : selectedId){
            if (id == item.hosp.Id) {
                selectedId.remove(item.hosp.Id);
            }
        }
    }

    public static void dismissContract(Hos_Contract__c contractToDismiss, String contractId, String doctorId, List<Hos_Contract__c> doctorContracts){
        contractToDismiss = [SELECT Hospital__c, Doctor__c, StartDate__c, EndDate__c, Status__c FROM Hos_Contract__c WHERE Id =: contractId];
        if(contractToDismiss.StartDate__c > System.today()){
            delete contractToDismiss;
        }
        else{
            contractToDismiss.EndDate__c = System.today();
            update contractToDismiss;
        }

        doctorContracts = getDoctorContracts(doctorId);
    }
}