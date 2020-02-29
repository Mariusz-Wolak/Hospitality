public with sharing class Hos_WrappedMateuszResponse {
    public String id { get; set; }
    public String message {get;set;}
    public Boolean success { get; set; }
    public String externalId { get; set; }

    public Hos_WrappedMateuszResponse(String id, String message, Boolean success, String externalId) {
        this.id = id;
        this.message = message;
        this.success = success;
        this.externalId = externalId;
    }

    public Hos_WrappedMateuszResponse() {}
}