/**
 * Created by vvalitsky on 10/10/2019.
 */

global class ScheduleForDailyUpdate implements Schedulable {

    global void execute(SchedulableContext sc) {
        BatchDailyUpdate b = new BatchDailyUpdate();
        Database.executeBatch(b);
    }

}