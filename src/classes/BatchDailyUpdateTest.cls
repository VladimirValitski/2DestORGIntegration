/**
 * Created by vvalitsky on 11/4/2019.
 */

@IsTest
private class BatchDailyUpdateTest {

    private static String postMethod = 'POST';

    private static Org2Data__mdt orgData = [
            SELECT clientId__c, clientSecret__c, endPointAuth__c,
                    endPointProducts__c, password__c, userName__c
            FROM Org2Data__mdt
            WHERE DeveloperName = 'DataOrg2'
    ][0];

    @TestSetup
    static void setup() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 200; i++) {
            products.add(new Product2(Name = 'InsertProductName' + i));
        }
        insert products;
    }

    @IsTest
    static void BatchDailyUpdateTest() {
        List<Product2> selectedProducts = Database.query('SELECT ' + String.join(new List<String>
                (Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().keySet()), ',') +
                ' FROM Product2');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpGenerator(selectedProducts, postMethod, orgData));
        BatchDailyUpdate batch = new BatchDailyUpdate();
        batch.execute(null, selectedProducts);
        Test.stopTest();
    }

}