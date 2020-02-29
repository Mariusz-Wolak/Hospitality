public with sharing class Hos_RandomizeDoctorsHandler {

    public List <Hos_Doctor__c> randomDoctors { get; set; }
    private Integer totalNumberOfDoctors;
    private final Integer numberOfDoctorsToShow = 5;

    public Hos_RandomizeDoctorsHandler() {
        randomDoctors = new List<Hos_Doctor__c>();
        totalNumberOfDoctors = gettotalNumberOfDoctors();
        Integer randomNumber = randomizeNumber(totalNumberOfDoctors);
        randomDoctors = getDoctors(randomNumber);
    }

    private Integer randomizeNumber(Integer totalNumberOfDoctors) {
        Integer randomNumber = 0;
        do{
            randomNumber = Integer.valueOf((Math.random() * totalNumberOfDoctors));
        }while(randomNumber > totalNumberOfDoctors-numberOfDoctorsToShow);
        return randomNumber;
    }

    private Integer gettotalNumberOfDoctors() {
        List <AggregateResult> totalNumberOfDoctors = [SELECT COUNT(Id) AMOUNT FROM Hos_Doctor__c];
        Integer count = (Integer) totalNumberOfDoctors[0].get('amount');
        return count;
    }

    public List <Hos_Doctor__c> getDoctors(Integer randomNumber) {
        List <Hos_Doctor__c> doctors = [
                SELECT Full_Name__c, Email__c, Country__c
                FROM Hos_Doctor__c
                Order By Full_Name__c
                LIMIT :5
                OFFSET :randomNumber
        ];

        return doctors;
    }
}