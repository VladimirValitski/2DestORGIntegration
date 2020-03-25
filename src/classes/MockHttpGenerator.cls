/**
 * Created by vvalitsky on 11/4/2019.
 */

global with sharing class MockHttpGenerator implements HttpCalloutMock{

    private List<Product2> products;
    private String httpMethod;
    private Org2Data__mdt credentials ;

    public MockHttpGenerator(List<Product2> products, String httpMethod, Org2Data__mdt credentials){
        this.products = products;
        this.httpMethod = httpMethod;
        this.credentials = credentials;
    }

    global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint().equals(credentials.endPointAuth__c)) {
            accessTokenValidation(request);
            response.setBody('{"access_token" : "00000000000000000000001"}');
            response.setStatusCode(200);
        } else if (request.getEndpoint().equals(credentials.endPointProducts__c)) {
            callDestinationValidation(request);
            response.setStatusCode(200);
        }
        else {
            response.setBody('{}');
            response.setStatusCode(400);
        }
        return response;
    }

    private void accessTokenValidation(HttpRequest request){
        Map<String, String> credentialsByName = new Map<String, String>();
        System.assertEquals('POST', request.getMethod());
        System.assertEquals('application/x-www-form-urlencoded', request.getHeader('Content-Type'));
        System.assert(String.isNotBlank(request.getBody()));

        for (String paramValuePair : request.getBody().split('&')){
            List<String> temp = paramValuePair.split('=');
            credentialsByName.put(temp[0], temp[1]);
        }
        System.assertEquals(credentials.clientId__c, credentialsByName.get('client_id'));
        System.assertEquals(credentials.clientSecret__c, credentialsByName.get('client_secret'));
        System.assertEquals(credentials.userName__c, credentialsByName.get('username'));
        System.assertEquals(credentials.password__c, credentialsByName.get('password'));
    }

    private void callDestinationValidation(HttpRequest request){
        System.assertEquals(httpMethod, request.getMethod());
        System.assertEquals('application/json', request.getHeader('Content-Type'));
        System.assertEquals('Bearer 00000000000000000000001', request.getHeader('Authorization'));
        System.assert(String.isNotBlank(request.getBody()));

        Map<String, Product2> productsByIds = new Map<String, Product2>(products);
        List<Product2> actualProducts = (List<Product2>) JSON.deserialize(request.getBody(),List<Product2>.class);

        System.assertEquals(products.size(), actualProducts.size());
        for (Product2 product : actualProducts){
            System.assert(product.Id == null, 'Id is not null');
            System.assert(productsByIds.containsKey(product.ExtId__c));
            System.assertEquals(productsByIds.get(product.ExtId__c).Name, product.Name);
        }
    }

}