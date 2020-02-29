public with sharing class Hos_DoctorsToJSON {
    public String FullName {get;set;}
    public String Email {get;set;}
    public String Country {get;set;}

    public Hos_DoctorsToJSON(String fullname, String mail, String country){
        this.FullName = fullname;
        this.Email = mail;
        this.Country = country;
    }
}