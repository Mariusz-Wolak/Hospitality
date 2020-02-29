public with sharing class Hos_DoctorsIntegrationCallout implements Queueable, Database.AllowsCallouts{

    public List<Hos_DoctorRequestBody> doctors;
    public String method;
    public Hos_MateuszDoctorsREST_Handler mateuszREST_Handler;
    final Integer attempt = 0;

    public Hos_DoctorsIntegrationCallout(List<Hos_DoctorRequestBody> doctors, String method){
        this.doctors = doctors;
        this.method = method;
        mateuszREST_Handler = new Hos_MateuszDoctorsREST_Handler();
    }

    public void execute(QueueableContext context){
        mateuszREST_Handler.login();
        if(method.equals('POST')){
            for(Hos_DoctorRequestBody doctor: doctors) {
                if(doctor.externalId == doctor.id) {
                    Hos_WrappedMateuszResponse mateuszResponse = mateuszREST_Handler.addDoctor(doctor.firstName, doctor.lastName, doctor.email, doctor.country, doctor
                            .externalId, attempt);
                }
            }
        }else if(method.equals('PUT')){
            for(Hos_DoctorRequestBody doctor: doctors) {
                Hos_WrappedMateuszResponse mateuszResponse = mateuszREST_Handler.updateDoctor(doctor.id, doctor.firstName, doctor.lastName, doctor.email, doctor.country,
                        doctor.externalId, attempt);
            }
        }else if(method.equals('DELETE')){
            for(Hos_DoctorRequestBody doctor: doctors) {
                Hos_WrappedMateuszResponse mateuszResponse = mateuszREST_Handler.deleteDoctor(doctor.id, doctor.externalId, attempt);
            }
        }
    }
}