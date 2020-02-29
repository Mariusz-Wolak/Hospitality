global class Hos_DoctorsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    List<Hos_Request_Logger__c> reqLoggersToMail = new List<Hos_Request_Logger__c>();
    public Hos_MateuszDoctorsREST_Handler mateuszREST_Handler = new Hos_MateuszDoctorsREST_Handler();

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT First_Name__c, Name, Email__c, Country__c, External_Id__c, Id, Synchronize_Attempts__c, isSynchronized__c FROM Hos_Doctor__c WHERE ' +
                '(isSynchronized__c = false AND Synchronize_Attempts__c < 3) OR (isSynchronized__c = false AND IsDeleted = true AND LastModifiedDate = LAST_N_DAYS:3) ALL ' +
                'ROWS';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        mateuszREST_Handler.login();
        List<Hos_Doctor__c> doctors = (List<Hos_Doctor__c>)scope;
        Hos_Request_Logger__c reqLogger = new Hos_Request_Logger__c();
        Hos_WrappedMateuszResponse mateuszResponse = new Hos_WrappedMateuszResponse();
        for(Hos_Doctor__c doc: doctors){
            doc.Synchronize_Attempts__c += 1;
            reqLogger = [SELECT CreatedDate, Attempts__c, Body__c, Deleted__c, Endpoint__c, External_Id__c, Internal_Id__c, Response__c, Status__c, Success__c, Type__c FROM
                    Hos_Request_Logger__c WHERE Internal_Id__c = :doc.Id ORDER BY CreatedDate DESC LIMIT 1];

            if(reqLogger.Type__c == 'POST'){
                mateuszResponse = mateuszREST_Handler.addDoctor(doc.First_Name__c, doc.Name, doc.Email__c, doc.Country__c, doc.External_Id__c, (Integer)doc
                                .Synchronize_Attempts__c);
            }
            else if(reqLogger.Type__c == 'PUT'){
                mateuszResponse = mateuszREST_Handler.updateDoctor(doc.Id, doc.First_Name__c, doc.Name, doc.Email__c, doc.Country__c, doc.External_Id__c, (Integer)doc
                        .Synchronize_Attempts__c);
            }
            else if(reqLogger.Type__c == 'DELETE'){
                mateuszResponse = mateuszREST_Handler.deleteDoctor(doc.Id, doc.External_Id__c, (Integer)doc.Synchronize_Attempts__c);
            }

            if(mateuszResponse.success==false && doc.Synchronize_Attempts__c == 3){
                reqLoggersToMail.add(reqLogger);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        if(reqLoggersToMail.size()>0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = getEmailAddresses();
            mail.setToAddresses(toAddresses);
            mail.setSubject(Label.Request_Log_Fail);
            mail.setPlainTextBody(Label.Request_Log_Fail + ': ' +reqLoggersToMail);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }

    private List<String> getEmailAddresses()
    {
        List<String> idList = new List<String>();
        List<String> toAddresses = new List<String>();
        List<GroupMember> groupMembers= [SELECT Id, UserOrGroupId FROM GroupMember WHERE group.name='Admins'];
        for(GroupMember gm : groupMembers)
        {
            idList.add(gm.UserOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr){
            toAddresses.add(u.email);
        }

        return toAddresses;
    }
}