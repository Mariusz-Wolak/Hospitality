public with sharing class Hos_ContractTriggerHandler implements Hos_ITrigger {
    Set<String> doctorsIds;
    Set<String> hospitalsIds;
    List<Hos_Contract__c> contractsList;
    Map<String, List<Hos_Contract__c>> contractMap;

    public void bulkBefore() {
        doctorsIds = new Set<String>();
        hospitalsIds = new Set<String>();
        contractsList = new List<Hos_Contract__c> ();
        contractMap = new Map<String, List<Hos_Contract__c>>();
    }
    public void bulkAfter() {}
    public void beforeInsert(List<Hos_Contract__c> newlstObj) {
        for (Hos_Contract__c con : newlstObj) {
            doctorsIds.add(con.Doctor__c);
            hospitalsIds.add(con.Hospital__c);
        }
        contractsList = [
                SELECT Hospital__c, Doctor__c, StartDate__c, EndDate__c, Name
                FROM Hos_Contract__c
                WHERE (Doctor__c IN :doctorsIds AND Hospital__c IN :hospitalsIds)
        ];

        for (Hos_Contract__c con : contractsList) {
            addValueToMap(con, contractMap);
        }

        if (contractMap.size() > 0) {
            for (Hos_Contract__c contractToInsert : newlstObj) {
                if (contractMap.get(contractToInsert.Hospital__c + ';' + contractToInsert.Doctor__c) != null) {
                    for (Hos_Contract__c existingContract : contractMap.get(contractToInsert.Hospital__c + ';' + contractToInsert.Doctor__c)) {
                        if (isOverlapped(contractToInsert, existingContract)) {
                            contractToInsert.addError(displayContracts(contractMap.get(contractToInsert.Hospital__c + ';' + contractToInsert.Doctor__c)), false);
                        }
                    }
                }
            }
        }
    }
    public void beforeUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {}
    public void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj) {}
    public void afterInsert(List<SObject> newlstObj,Map<Id,SObject> newMapObj) {}
    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj) {}
    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj) {}
    public void andFinally() {}

    private static String displayContracts(List<Hos_Contract__c> contracts) {
        String result = Label.Contract_overlapping_msg;

        for (Hos_Contract__c c : contracts) {
            result += Label.Contract_number + ' ' + c.Name + ': ' + c.StartDate__c.format() + ' - ';

            if (c.EndDate__c == null) {
                result += Label.Not_Specified;
            } else {
                result += c.EndDate__c.format();
            }

            result += '; ';
        }

        return result;
    }

    private static void addValueToMap(Hos_Contract__c con, Map<String, List<Hos_Contract__c>> contractMap) {
        if (contractMap.get(con.Hospital__c + ';' + con.Doctor__c) == null) {
            List<Hos_Contract__c> tempList = new List<Hos_Contract__c>();
            tempList.add(con);
            contractMap.put(con.Hospital__c + ';' + con.Doctor__c, tempList);
        } else {
            contractMap.get(con.Hospital__c + ';' + con.Doctor__c).add(con);
            contractMap.put(con.Hospital__c + ';' + con.Doctor__c, contractMap.get(con.Hospital__c + ';' + con.Doctor__c));
        }
    }

    private static boolean isOverlapped(Hos_Contract__c contractToCheck, Hos_Contract__c existingContract) {
        if (contractToCheck.EndDate__c == null) {
            if ((contractToCheck.StartDate__c <= existingContract.StartDate__c) ||
                    (contractToCheck.StartDate__c <= existingContract.EndDate__c) ||
                    (contractToCheck.StartDate__c >= existingContract.StartDate__c )) {
                return true;
            }
        } else if (existingContract.EndDate__c == null) {
            if ((contractToCheck.StartDate__c <= existingContract.StartDate__c && contractToCheck.EndDate__c >= existingContract.StartDate__c) ||
                    (contractToCheck.StartDate__c) >= existingContract.StartDate__c) {
                return true;
            }
        } else if (!(contractToCheck.EndDate__c < existingContract.StartDate__c || contractToCheck.StartDate__c > existingContract.EndDate__c)) {
            return true;
        }
        return false;
    }
}