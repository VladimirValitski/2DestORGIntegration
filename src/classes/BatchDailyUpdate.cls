/**
 * Created by vvalitsky on 11/4/2019.
 */

global with sharing class BatchDailyUpdate implements Database.Batchable<sObject>,
        Database.Stateful, Database.AllowsCallouts {

    global final String query;
    global String Access_Token;

    global BatchDailyUpdate() {
        String queryTemplate = 'SELECT {0} FROM {1} WHERE {2}' ;
        List<String> queryValues = new List<String>{
                String.join(getFields(), ','),
                'Product2',
                'LastModifiedDate = TODAY ALL ROWS'
        };
        query = String.format(queryTemplate, queryValues);
        Access_Token = DailyCalloutHandler.getAccessToken();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        String jsonString = JSON.serialize(processProducts(scope), false);
        DailyCalloutHandler.passDailyChangedRecordsOnOrg1(jsonString, Access_Token);
    }

    global void finish(Database.BatchableContext bc) {
    }

    private static List<Product2> processProducts(List<Product2> products) {
        List<Product2> result = new List<Product2>();
        for (Product2 product : products) {
            Map<String, Object> processedProduct = new Map<String, Object>();
            List<String> fieldNames = getFields();
            if (!fieldNames.isEmpty()) {
                for (String fieldName : fieldNames) {
                    processedProduct.put(fieldName, product.get(fieldName));
                }
            }
            result.add((Product2) JSON.deserializeStrict(JSON.serialize(processedProduct), Product2.class));
        }
        return result;
    }

    private static List<String> getFields() {
        List<String> apiNames = new List<String>();
        for (SObjectField field : SObjectType.Product2.fields.getMap().values()) {
            DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.isUpdateable() && fieldDescribe.getType() != Schema.DisplayType.REFERENCE) {
                apiNames.add(fieldDescribe.getName());
            }
        }
        apiNames.add('IsDeleted');
        return apiNames;
    }

}