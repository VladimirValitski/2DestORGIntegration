/**
 * Created by vvalitsky on 11/4/2019.
 */

@IsTest
private class CollisionMailerTest {

    @IsTest
    static void sendReportTest() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 4; i++) {
            products.add(new Product2(Name = 'InsertProductName' + i));
        }
        insert products;
        List<Id> ids = new List<Id>();
        for (Product2 product : products){
            ids.add(product.Id);
        }

        Test.startTest();
        CollisionMailer.sendReport(ids);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, invocations, 'Email has not been send');
    }

}