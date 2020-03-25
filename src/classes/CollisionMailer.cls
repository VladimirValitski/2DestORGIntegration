/**
 * Created by vvalitsky on 10/16/2019.
 */

public with sharing class CollisionMailer {

    public static void sendReport(List<Id> ids) {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Datetime dt = System.now();
        String idsString = String.join(ids, ', ');
        mail.setSubject('Collision with records');
        EmailTemplate template = [
                SELECT Id, Name, Subject, Body
                FROM EmailTemplate
                WHERE Name = 'Collision Report'
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