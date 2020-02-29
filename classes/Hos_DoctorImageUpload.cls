public with sharing class Hos_DoctorImageUpload {
    public Attachment attachment { get; set; }
    public Hos_Doctor__c doctorWithImage { get; set; }
    public Boolean hasAttachment { get; set; }

    public Hos_DoctorImageUpload(ApexPages.standardController controller){
        doctorWithImage = (Hos_Doctor__c) controller.getRecord();
        hasAttachment=false;
        setLastAttachment();
    }

    public void setLastAttachment() {
        List<Attachment> attachments = [
                SELECT Id, Name, Parent.Name
                FROM Attachment
                WHERE ParentId =: doctorWithImage.Id
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];
        if(!attachments.isEmpty() && attachments != null){
            attachment = attachments[0];
            hasAttachment = true;
        } else{
            hasAttachment = false;
        }
    }

    public void deleteImages() {
        List<Attachment> attachmentsToDelete = getAllAttachedPhotos();
        try {
            if (String.isNotBlank(attachment.Id)) {
                delete attachmentsToDelete;
                attachment = new Attachment();
                hasAttachment=false;
            }
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Hos_Doctor_Image_Upload_Error));
        }
        setLastAttachment();
    }

    private List<Attachment> getAllAttachedPhotos() {
        List<Attachment> attachments = [
                SELECT Id,Name
                FROM Attachment
                WHERE ParentId = :doctorWithImage.Id
        ];
        return attachments;
    }

    @RemoteAction
    public static PageReference saveImage(String name, String contentType, String data, String parent) {
        Attachment attachedPhoto = new Attachment(Name = name, OwnerId = UserInfo.getUserId(), contentType = contentType, Body = EncodingUtil.base64Decode(data), ParentId = parent);
        Database.insert(attachedPhoto, true);
        return null;
    }
}