public with sharing class Hos_HospitalViewHandler {

    public static List<Hos_Contract__c> getHospitalContracts(String hospitalId){
        return [SELECT Hospital__c, Doctor__c, StartDate__c, EndDate__c, Name, Doctor__r.First_Name__c, Doctor__r.Name, Doctor__r.Full_Name__c, Status__c
                FROM Hos_Contract__c
                WHERE Hospital__r.Id = :hospitalId
        ];
    }

    public static String createQuery(Hos_Doctor__c searchItemToHire, String sortByColumn, String order){
        String query = 'SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c ';
        if (searchItemToHire.Name != null || searchItemToHire.Country__c != null || searchItemToHire.First_Name__c != null || searchItemToHire.Email__c != null) {
            query += 'WHERE ' ;
            if (String.isNotBlank(searchItemToHire.Name)) {
                query += 'Name LIKE \'' + searchItemToHire.Name + '%\' ';
            }
            if (String.isNotBlank(searchItemToHire.First_Name__c)) {
                query += 'AND ' ;
                query += 'First_Name__c LIKE \'' + searchItemToHire.First_Name__c + '%\' ';
            }

            if (String.isNotBlank(searchItemToHire.Country__c)) {
                query += 'AND ' ;
                query += 'Country__c LIKE\'' + searchItemToHire.Country__c + '%\' ';
            }
            if (String.isNotBlank(searchItemToHire.Email__c)) {
                query += 'AND ' ;
                query += 'Email__c LIKE\'' + searchItemToHire.Email__c + '%\' ';
            }
            query += 'ORDER BY ' + sortByColumn + ' ' + order;
        }
        return query;
    }

    public static void hireDoctor(Hos_Contract__c contractToPrepare, String doctorToHireId, String hospitalId, List<Hos_Contract__c> hospitalContracts) {
        contractToPrepare.Doctor__c = doctorToHireId;
        contractToPrepare.Hospital__c = hospitalId;
        insert contractToPrepare;
        hospitalContracts = getHospitalContracts(hospitalId);
    }

    public static void dismissContract(Hos_Contract__c contractToDismiss, String contractId) {
        contractToDismiss = [SELECT Hospital__c, Doctor__c, StartDate__c, EndDate__c, Status__c FROM Hos_Contract__c WHERE Id = :contractId];
        if (contractToDismiss.StartDate__c > System.today()) {
            delete contractToDismiss;
        } else {
            contractToDismiss.EndDate__c = System.today();
            update contractToDismiss;
        }
    }
}