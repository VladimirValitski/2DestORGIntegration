/**
 * Created by vvalitsky on 10/9/2019.
 */

public with sharing class DailyCalloutHandler {

    private static final String TEMPLATE_BODY =
            'grant_type=password&client_id={0}&client_secret={1}&username={2}&password={3}';
    private static Integer counter = 0;
    public static String Access_Token {
        get {
            if (Access_Token == null) {
                System.debug(counter++);
                Access_Token = getAccessToken();
            }
            return Access_Token;
        }
        private set;
    }

    public static Org2Data__mdt orgData {
        get {
            if (orgData == null) {
                orgData = [
                        SELECT clientId__c, clientSecret__c, endPointAuth__c, endPointProducts__c,
                                password__c, userName__c
                        FROM Org2Data__mdt
                        WHERE DeveloperName = 'DataOrg2'
                ][0];
            }
            return orgData;
        }
        private set;
    }

    public static void passDailyChangedRecordsOnOrg1(String jsonString, String Access_Token) {
        List<Id> failedIds = new List<Id>();
        if (jsonString.length() != 0 && Access_Token.length() != 0) {
            failedIds = calloutProductsToOrg1(Access_Token, jsonString);
        }
        if (!failedIds.isEmpty()) {
            ErrorUpdateDataMailer.sendReport(failedIds);
        }
    }

    public static String getAccessToken() {
        String endPoint = orgData.endPointAuth__c;
        List<String> bodyVariables = new List<String>{
                orgData.clientId__c,
                orgData.clientSecret__c,
                orgData.userName__c,
                orgData.password__c
        };
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(String.format(TEMPLATE_BODY, bodyVariables));
        request.setEndpoint(endPoint);
        try {
            response = http.send(request);
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    Access_Token = parser.getText();
                }
            }
        } catch (System.CalloutException e) {
            // do smth
        }
        return Access_Token;
    }

    static List<String> calloutProductsToOrg1(String Access_Token, String jsonString) {
        List<String> failedIds = new List<String>();
        String endPointProd = orgData.endPointProducts__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setEndpoint(endPointProd);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + Access_Token);
        request.setBody(jsonString);
        try {
            response = http.send(request);
        } catch (System.CalloutException e) {
            // do smth
        }
        if (response.getStatusCode() == 202) {
            failedIds = (List<String>)
                    JSON.deserializeStrict(response.getBody(), List<String>.class);
        }
        return failedIds;
    }

}