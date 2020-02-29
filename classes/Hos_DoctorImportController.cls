public with sharing class Hos_DoctorImportController {
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Hos_Doctor__c> docList{get;set;}
    public Hos_Doctor__c docObj{get;set;}
    public List<Hos_DoctorImportController.DoctorEncapsulated> encapsulatedList{get; set;}

    public class DoctorEncapsulated {
        public Hos_Doctor__c docEncapsulated {get; set;}
        public Boolean isSelected {get; set;}
        public Boolean isInserted{get;set;}
        public String info{get;set;}
        public String status{get;set;}

        public DoctorEncapsulated(Hos_Doctor__c doc){
            docEncapsulated = doc;
            isSelected = false;
            info = '';
            isInserted = false;
        }
    }

    public Hos_DoctorImportController(){
        csvFileLines = new String[]{};
        docList = New List<Hos_Doctor__c>();
        encapsulatedList  = new List<Hos_DoctorImportController.DoctorEncapsulated>();
    }

    public void processCSVFile(){
        try{
            csvAsString = '';
            csvFileLines = new String[]{};
            docList = New List<Hos_Doctor__c>();
            encapsulatedList  = new List<Hos_DoctorImportController.DoctorEncapsulated>();

            csvAsString = csvFileBody.toString().remove('"');
            csvFileLines = csvAsString.split('\n');

            for(Integer i=1;i<csvFileLines.size();i++){
                docObj = new Hos_Doctor__c();
                string[] csvRecordData = csvFileLines[i].split(',');

                string[] fullName = csvRecordData[0].split(' ');
                docObj.First_Name__c = fullName[0];
                docObj.Name = fullName[1];
                docObj.Email__c = csvRecordData[1];
                docObj.Country__c = csvRecordData[2];

                docList.add(docObj);
            }
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Hos_Doctor_Import_CSV_File_Error);
            ApexPages.addMessage(errorMessage);
        }

        for(Hos_Doctor__c d: docList){
            encapsulatedList.add(new Hos_DoctorImportController.DoctorEncapsulated(d));
        }
    }

    public PageReference selectAll(){
        for(Hos_DoctorImportController.DoctorEncapsulated d: encapsulatedList){
            d.isSelected = true;
        }
        return null;
    }

    public PageReference deselectAll() {
        for (Hos_DoctorImportController.DoctorEncapsulated d: encapsulatedList) {
            d.isSelected = false;
        }
        return null;
    }

    public PageReference reverse() {
        for (Hos_DoctorImportController.DoctorEncapsulated d: encapsulatedList) {
            d.isSelected = !d.isSelected;
        }
        return null;
    }

    public PageReference importCSVFile(){
        for (Hos_DoctorImportController.DoctorEncapsulated d: encapsulatedList){
            if(d.isSelected && d.isInserted == false){
                try{
                    Database.SaveResult docSaveResult = Database.insert(d.docEncapsulated);
                    d.status = System.Label.Hos_Doctor_Import_Success_Importing;
                    d.info  = Url.getSalesforceBaseUrl().toExternalForm()+'/'+docSaveResult.getId();
                    d.isInserted = true;
                }catch (DmlException e){
                    d.status = System.Label.Hos_Doctor_Import_Fail_Importing;
                    d.info = e.getDmlMessage(0);
                    d.isInserted = false;
                }
            }
        }
        return null;
    }
}