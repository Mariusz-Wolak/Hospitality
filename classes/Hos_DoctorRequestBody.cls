public with sharing class Hos_DoctorRequestBody {
    public String id { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String country { get; set; }
    public String externalId{get;set;}
    public Hos_DoctorRequestBody(){

    }
    public Hos_DoctorRequestBody(String id, String firstName, String lastName, String email, String country, String externalId){
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.country = country;
        this.externalId = externalId;
    }
}