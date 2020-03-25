/**
 * Created by vvalitsky on 10/25/2019.
 */

public with sharing class ErrorUpdateDataMailer {

    public static void sendReport(List<String> failIds) {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Datetime dt = System.now();
        String idsString = String.join(failIds, ', ');
        mail.setSubject('Error update/insert records on Destination(ORG2)');
        EmailTemplate template = [
                SELECT Id, Name, Subject, Body
                FROM EmailTemplate
                WHERE Name = 'Error report'
                LIMIT 1
        ];
        List<String> parameters = new List<String>{
                UserInfo.getName(), idsString, String.valueOf(dt)
        };
        String plainBody = String.format(template.Body, parameters);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTemplateId(template.Id);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(plainBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

}