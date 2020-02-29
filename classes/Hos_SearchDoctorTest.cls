@IsTest
private class Hos_SearchDoctorTest {
    @TestSetup
    private static void setup(){
        List<Hos_Doctor__c> doctors = new List<Hos_Doctor__c>();
        for(Integer i = 0; i < 10; i++)
        {
            doctors.add(new Hos_Doctor__c(Name = String.valueOf(i), First_Name__c = String.valueOf(i), Country__c = 'PL',
                     Email__c = 'doctor' + String.valueOf(i) + '@example.com'));
        }
        insert doctors;

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(doctors);
    }
    @IsTest
    private static void createQueryTestWithNullFields() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c ', result);
    }
    @IsTest
    private static void createQueryTestWithLastName() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.Name = 'r';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE Name LIKE \'r%\' ORDER BY Full_Name__c ASC', result);
    }
    @IsTest
    private static void createQueryTestWithLastNameFirstName() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.Name = 'r';
        controller.searchItem.First_Name__c = 'a';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE Name LIKE \'r%\' AND First_Name__c LIKE \'a%\' ORDER BY Full_Name__c ASC', result);
    }
    @IsTest
    private static void createQueryTestWithLastNameCountry() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.Name = 'r';
        controller.searchItem.Country__c = 'PL';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE Name LIKE \'r%\' AND Country__c LIKE \'PL%\' ORDER BY Full_Name__c ASC', result);
    }
    @IsTest
    private static void createQueryTestWithLastNameFirstNameCountry() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.Name = 'r';
        controller.searchItem.First_Name__c = 'a';
        controller.searchItem.Country__c = 'PL';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();
        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE Name LIKE \'r%\' AND First_Name__c LIKE \'a%\' AND Country__c LIKE \'PL%\' ORDER BY Full_Name__c ASC', result);
    }
    @IsTest
    private static void createQueryTestWithEmail() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.Email__c = 'aradomski@example.com';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE AND Email__c LIKE \'aradomski@example.com%\' ORDER ' +
                'BY Full_Name__c ASC', result);
    }
    @IsTest
    private static void createQueryTestWithCountry() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.Country__c = 'PL';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE AND Country__c LIKE \'PL%\' ORDER BY Full_Name__c ASC',
                result);
    }
    @IsTest
    private static void createQueryTestWithFirstName() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.searchItem.First_Name__c = 'a';

        Test.startTest();
        String result = controller.createQuery();
        Test.stopTest();

        System.assertEquals('SELECT Name, First_Name__c, Full_Name__c, Country__c, Email__c FROM Hos_Doctor__c WHERE AND First_Name__c LIKE \'a%\' ORDER BY Full_Name__c ASC', result);
    }
    @IsTest
    private static void sortByFullNameTest() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.columnParameter = 'Full_Name__c';

        Test.startTest();
        controller.sortBy();
        Test.stopTest();

        System.assertEquals('Full_Name__c', controller.sortByColumn);
    }
    @IsTest
    private static void sortByEmailTest() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.columnParameter = 'Email__c';

        Test.startTest();
        controller.sortBy();
        Test.stopTest();

        System.assertEquals('Email__c', controller.sortByColumn);
    }
    @IsTest
    private static void sortByCountryTest() {
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.columnParameter = 'Country__c';

        Test.startTest();
        controller.sortBy();
        Test.stopTest();

        System.assertEquals('Country__c', controller.sortByColumn);
    }
    @IsTest
    private static void sortByOrderDescTest(){
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.order = 'ASC';

        Test.startTest();
        controller.sortBy();
        Test.stopTest();

        System.assertEquals('DESC',  controller.order);
    }
    @IsTest
    private static void sortByOrderAscTest(){
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);
        controller.order = 'DESC';

        Test.startTest();
        controller.sortBy();
        Test.stopTest();

        System.assertEquals('ASC',  controller.order);
    }
    @IsTest
    private static void exportCSVTest(){
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);

        PageReference page = controller.exportToCSV();

        System.assertEquals(page.getUrl(),'/apex/Hos_ExportDoctorCSV');
    }
    @IsTest
    private static void exportXLSTest(){
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);

        PageReference page = controller.exportToXLS();

        System.assertEquals(page.getUrl(),'/apex/Hos_ExportDoctorXLS');
    }
    @IsTest
    private static void exportJSONTest(){
        ApexPages.StandardController sc;
        Hos_SearchDoctorController controller = new Hos_SearchDoctorController(sc);

        PageReference page = controller.exportToJSON();

        System.assertEquals(page.getUrl(),'/apex/Hos_ExportDoctorJSON');
    }
}