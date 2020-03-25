/**
 * Created by vvalitsky on 10/3/2019.
 */

@RestResource(urlMapping='/Products/*')
global with sharing class CalloutORG2handler {

    @HttpPost
    global static void upsertProducts() {
        List<String> failedIds = new List<String>();
        List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
        RestRequest request= RestContext.request;
        RestResponse response = RestContext.response;
        if (String.isNotBlank(request.requestBody.toString())) {
            List<Product2> newProducts = (List<Product2>)
                    System.JSON.deserialize(request.requestBody.toString(), List<Product2>.class);
            if (!newProducts.isEmpty()) {
                List<String> productIds = new List<String>();
                List<String> productNames = new List<String>();
                for (Product2 product : newProducts) {
                    productIds.add(product.ExtId__c);
                    productNames.add(product.Name);
                }
                List<Product2> allProducts = [
                        SELECT Id, Name, ExtId__c
                        FROM Product2
                        WHERE ExtId__c IN :productIds OR Name IN :productNames
                ];
                List<String> forMailIds = new List<String>();
                if (!allProducts.isEmpty()) {
                    Map<String, Product2> allProductsByExtIds = new Map<String, Product2>();
                    Map<String, Product2> allProductsByNames = new Map<String, Product2>();
                    for (Product2 product : allProducts) {
                        allProductsByExtIds.put(product.ExtId__c, product);
                        allProductsByNames.put(product.Name, product);
                    }
                    for (Product2 product : newProducts) {
                        product.Id = null;
                        Boolean isValid_Conditions = !allProductsByExtIds.containsKey(product.ExtId__c);
                        isValid_Conditions &= allProductsByNames.containsKey(product.Name);
                        if (isValid_Conditions) {
                            product.Id = allProductsByNames.get(product.Name).Id;
                            forMailIds.add(product.Id);
                        } else {
                            product.Id = allProductsByExtIds.get(product.ExtId__c).Id;
                        }
                    }
                    upsertResults = Database.upsert(newProducts, false);
                    if (!forMailIds.isEmpty()) {
                        CollisionMailer.sendReport(forMailIds);
                    }
                    if (!upsertResults.isEmpty()) {
                        for (Integer i = 0; i < upsertResults.size(); i++) {
                            if (!upsertResults[i].isSuccess()) {
                                failedIds.add(String.valueOf(newProducts[i].ExtId__c));
                            }
                        }
                    }
                }
                if (!failedIds.isEmpty()) {
                    response.statusCode = 202;
                    response.addHeader('Content-Type', 'application/json');
                    response.responseBody = Blob.valueOf(JSON.serialize(failedIds));
                } else {
                    response.statusCode = 200;
                }
            }
        }
    }

    @HttpDelete
    global static void deleteProducts() {
        List<String> failedIds = new List<String>();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if (String.isNotBlank(request.requestBody.toString())) {
            List<Product2> deletedList = (List<Product2>)
                    System.JSON.deserialize(request.requestBody.toString(), List<Product2>.class);
            if (!deletedList.isEmpty()) {
                failedIds = deleteRecievedProducts(deletedList);
                if (!failedIds.isEmpty()) {
                    response.statusCode = 202;
                    response.addHeader('Content-Type', 'application/json');
                    response.responseBody = Blob.valueOf(JSON.serialize(failedIds));
                } else {
                    response.statusCode = 200;
                }
            }
        }
    }

    @HttpPut
    global static void undeleteProducts() {
        List<String> failedIds = new List<String>();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if (String.isNotBlank(request.requestBody.toString())) {
            List<Product2> undeletedList = (List<Product2>)
                    System.JSON.deserialize(request.requestBody.toString(), List<Product2>.class);
            if (!undeletedList.isEmpty()) {
                failedIds = undeleteRecievedProducts(undeletedList);
                if (!failedIds.isEmpty()) {
                    response.statusCode = 202;
                    response.addHeader('Content-Type', 'application/json');
                    response.responseBody = Blob.valueOf(JSON.serialize(failedIds));
                } else {
                    response.statusCode = 200;
                }
            }
        }
    }

    private static List<String> deleteRecievedProducts(List<Product2> recordsToDelete) {
        List<String> failedIds = new List<String>();
        List<Database.DeleteResult> deleteResults;
        List<String> deletedIdsList = new List<String>();
        for (Product2 product : recordsToDelete) {
            deletedIdsList.add(product.ExtId__c);
        }
        List<Product2> productsForDelete = [
                SELECT Id
                FROM Product2
                WHERE ExtId__c IN :deletedIdsList
        ];
        if (!productsForDelete.isEmpty()) {
            deleteResults = Database.delete(productsForDelete, false);
            for (Integer i = 0; i < deleteResults.size(); i++) {
                if (!deleteResults[i].isSuccess()) {
                    failedIds.add(String.valueOf(productsForDelete.get(i).ExtId__c));
                }
            }
        }
        return failedIds;
    }

    private static List<String> undeleteRecievedProducts(List<Product2> undeletedProductsList) {
        List<String> failedIds = new List<String>();
        List<Database.UndeleteResult> unDeleteResults;
        List<String> undeletedIdsList = new List<String>();
        for (Product2 p : undeletedProductsList) {
            undeletedIdsList.add(p.ExtId__c);
        }
        List<Product2> productsFromRecycleBin = [
                SELECT Id, Name, ExtId__c
                FROM Product2
                WHERE ExtId__c IN :undeletedIdsList AND IsDeleted = TRUE
                ALL ROWS
        ];
        if (!productsFromRecycleBin.isEmpty()) {
            unDeleteResults = Database.undelete(productsFromRecycleBin, false);
            for (Integer i = 0; i < unDeleteResults.size(); i++) {
                if (!unDeleteResults[i].isSuccess()) {
                    failedIds.add(String.valueOf(productsFromRecycleBin.get(i).ExtId__c));
                }
            }
        }
        return failedIds;
    }

}