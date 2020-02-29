public with sharing class Hos_MateuszDoctorsREST_Controller {

    public Hos_MateuszDoctorsREST_Handler MateuszREST_Handler = new Hos_MateuszDoctorsREST_Handler();
    public Hos_WrappedMateuszResponse mateuszResponse { get; set; }

    public Hos_WrappedDoctorREST searchItem { get; set; }
    public Hos_WrappedDoctorREST dialogDoctor { get; set; }
    public List<Hos_WrappedDoctorREST> doctorResults { get; set; }

    public String doctorId { get; set; }
    public String doctorExternalId { get; set; }
    public List<SelectOption> countries { get; set; }

    final Integer attempt = -1;

    public Hos_MateuszDoctorsREST_Controller() {
        MateuszREST_Handler.login();
        fillCountriesSelectOptions();
        mateuszResponse = new Hos_WrappedMateuszResponse();
        dialogDoctor = new Hos_WrappedDoctorREST();
        doctorResults = new List<Hos_WrappedDoctorREST>();
        searchItem = new Hos_WrappedDoctorREST();
    }

    public pageReference searchDoctors() {
        mateuszResponse.success = false;
        try {
            doctorResults = MateuszREST_Handler.getDoctors(searchItem.docFirstName, searchItem.docLastName, searchItem.docEmail, searchItem.docCountry);
            mateuszResponse.success = true;
        } catch (Exception e) {
            mateuszResponse.message = String.valueOf(e.getMessage());
        }
        return null;
    }

    public pageReference addDoctor() {
        mateuszResponse.success = false;
        mateuszResponse = MateuszREST_Handler.addDoctor(dialogDoctor.docFirstName, dialogDoctor.docLastName, dialogDoctor.docEmail, dialogDoctor.docCountry, '', attempt);
        if (mateuszResponse.success && searchItem.docLastName != '') searchDoctors();
        return null;
    }

    public pageReference updateDoctor() {
        mateuszResponse.success = false;
        mateuszResponse = MateuszREST_Handler.updateDoctor(doctorId, dialogDoctor.docFirstName, dialogDoctor.docLastName, dialogDoctor.docEmail, dialogDoctor.docCountry,
                doctorExternalId, attempt);
        if (mateuszResponse.success && searchItem.docLastName != '') searchDoctors();
        return null;
    }

    public pageReference deleteDoctor() {
        mateuszResponse.success = false;
        mateuszResponse = MateuszREST_Handler.deleteDoctor(doctorId, doctorExternalId, attempt);
        if (mateuszResponse.success && searchItem.docLastName != '') searchDoctors();
        return null;
    }

    public void fillCountriesSelectOptions() {
        List<String> retrievedCountries = MateuszREST_Handler.getCountries();
        countries = new List<SelectOption>();
        for (String s : retrievedCountries) {
            countries.add(new SelectOption(s, s));
        }
    }

    public void prepareNewDoctorDialog() {
        mateuszResponse.success = false;
        doctorId = null;
        doctorExternalId = null;
        dialogDoctor = new Hos_WrappedDoctorREST();
        dialogDoctor.docFirstName = null;
        dialogDoctor.docLastName = null;
        dialogDoctor.docEmail = null;
        dialogDoctor.docCountry = null;
        dialogDoctor.docId = null;
    }

    public void prepareUpdateDoctorDialog() {
        mateuszResponse.success = false;
        for (Hos_WrappedDoctorREST doc : doctorResults) {
            if (doc.docId == doctorId || doc.docExternalId == doctorExternalId) {
                dialogDoctor = new Hos_WrappedDoctorREST();
                dialogDoctor.docFirstName = doc.docFirstName;
                dialogDoctor.docLastName = doc.docLastName;
                dialogDoctor.docEmail = doc.docEmail;
                dialogDoctor.docCountry = doc.docCountry;
            }
        }
    }

    public pageReference clear() {
        searchItem = new Hos_WrappedDoctorREST();
        doctorResults = new List<Hos_WrappedDoctorREST>();
        return null;
    }
}