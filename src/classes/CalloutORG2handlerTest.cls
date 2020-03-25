/**
 * Created by vvalitsky on 11/4/2019.
 */

@IsTest
private class CalloutORG2handlerTest {

    @TestSetup
    static void setup(){
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(
                    new Product2(
                            Name = 'ProdName' + i,
                            ExtId__c = String.valueOf(i)
                    )
            );
        }
        insert products;
    }

    @IsTest
    static void upsertProductsTest() {
        List<String> updatedNames = new List<String>();
        List<Product2> selectedProducts = [SELECT Id, Name, Name__c, IsDeleted, ExtId__c FROM Product2];
        for (Product2 product : selectedProducts){
            product.Name += '_Updated';
            product.Name__c += '_Updated';
            updatedNames.add(product.Name);
        }
        String jsonString = JSON.serialize(selectedProducts);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = 'https://org1-valitsky-dev-ed.my.salesforce.com/services/apexrest/Products';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        CalloutORG2handler.upsertProducts();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(null, response.responseBody);
        for (Product2 product : [SELECT Id, Name FROM Product2]){
            System.assert(updatedNames.contains(product.Name));
        }
    }

    @IsTest
    static void deleteProductsTest() {
        List<Product2> selectedProducts = [SELECT Id, Name, Name__c, IsDeleted, ExtId__c FROM Product2];

        String jsonString = JSON.serialize(selectedProducts);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/Products';
        request.httpMethod = 'DELETE';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        CalloutORG2handler.deleteProducts();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(null, response.responseBody);
        System.assertEquals(0, [SELECT Id, IsDeleted FROM Product2].size());
        System.assertEquals(5, [SELECT COUNT() FROM Product2 ALL ROWS]);
    }

    @IsTest
    static void undeleteProductsTest() {
        List<Product2> selectedProducts = [SELECT Id, Name, Name__c, IsDeleted, ExtId__c FROM Product2];

        String jsonString = JSON.serialize(selectedProducts).replaceAll('false','true');
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = 'https://org1-valitsky-dev-ed.my.salesforce.com/services/apexrest/Products';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        CalloutORG2handler.undeleteProducts();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(null, response.responseBody);
        for (Product2 product : [SELECT Id, IsDeleted FROM Product2]){
            System.assertEquals(false, product.IsDeleted);
        }
    }

}