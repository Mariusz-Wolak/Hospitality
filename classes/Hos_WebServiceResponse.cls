global with sharing class Hos_WebServiceResponse {
    webService String hospitalName{ get; set; }
    webService String responseId { get; set; }
    webService Boolean isSuccess { get; set; }
    webService String errorMsg { get; set; }

    public Hos_WebServiceResponse(String hospitalName, String responseId, Boolean isSuccess, String errorMsg){
        this.hospitalName = hospitalName;
        this.responseId = responseId;
        this.isSuccess = isSuccess;
        this.errorMsg = errorMsg;
    }
}