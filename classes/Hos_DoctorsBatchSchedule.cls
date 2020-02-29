global class Hos_DoctorsBatchSchedule implements Schedulable {
//    Hos_DoctorsBatchSchedule batchSchedule = new Hos_DoctorsBatchSchedule();
//    String cronExp = '0 0 23 * * ?';
//    System.schedule('Batch Schedule', cronExp, batchSchedule);

    global void execute(SchedulableContext schedulableContext){
        Hos_DoctorsBatch batch = new Hos_DoctorsBatch();
        Database.executeBatch(batch, 1);
    }
}