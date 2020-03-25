/**
 * Created by vvalitsky on 11/4/2019.
 */

@IsTest
private class ErrorUpdateDataMailerTest {

    @IsTest
    static void ErrorUpdateDataMailerTest() {
        List<String> faildIds = new List<String>{'897634000059745', '234523450002345', '23004562345254245'};
        Test.StartTest();
        ErrorUpdateDataMailer.sendReport(faildIds);
        Integer invocations = Limits.getEmailInvocations();
        Test.StopTest();
        System.assertEquals(1, invocations, 'Email has not been sent');
    }

}
