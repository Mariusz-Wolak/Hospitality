public with sharing class Hos_WrappedMateuszResponseSOAP {
    public String responseId { get; set; }
    public Boolean success { get; set; }
    public String message{get;set;}

    public Hos_WrappedMateuszResponseSOAP(String responseId, Boolean success, String message) {
        this.responseId = responseId;
        this.success = success;
        this.message = message;
    }

    public Hos_WrappedMateuszResponseSOAP() {
    }
}