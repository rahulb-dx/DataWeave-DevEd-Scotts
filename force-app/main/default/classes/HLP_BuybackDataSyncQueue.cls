public inherited sharing class HLP_BuybackDataSyncQueue implements Queueable {    

    private String payer;
    private static Boolean mulesoftFailure = false;
    private static List<Credit__c> creditRecords;
    private static List<CreditItem__c> creditItemRecords;
    private static Set<String> creditAccountStores;
    private static Set<String> productSkuSet;

    // Constructor to pass the payer value
    public HLP_BuybackDataSyncQueue(String payer){
        this.payer = payer;
    }

    /**
     * @description This tracks the status of the callout made to SAP via MuleSoft has succeeded or has failed due to any technical snag.
     */
    private static Boolean mulesoftFailure = false;
    private static List<Credit__c> creditRecords;
    private static List<CreditItem__c> creditItemRecords;
    private static Set<String> creditAccountStores;
    private static Set<String> productSkuSet;

    /**
    * @description The execute method for Queueable interface which will run asynchronously
    * @param context - The context for the Queueable job execution
    */
    public void execute(QueueableContext context) {
        mulesoftFailure = false;
        try {
            productSkuSet = new Set<String> {};
            creditAccountStores = new Set<String> {};            

            Boolean isSandbox = [SELECT IsSandbox FROM Organization WHERE Id =:UserInfo.getOrganizationId() WITH SYSTEM_MODE LIMIT 1].IsSandbox;
            String mulesoftMetadataInstance =  (isSandbox) ? 'Buyback_Pull_From_SAP_NonProd' : 'Buyback_Pull_From_SAP_PRODUCTION';
            MuleSoftApi__mdt apiMDT = MuleSoftApi__mdt.getInstance(mulesoftMetadataInstance);
            HttpResponse responseBody = new Http().send(draftCalloutRequestForBuyBack(apiMDT, payer));

            processRequestResponse(responseBody);

            Map<String, Credit__c> creditStoreMapping = new Map<String, Credit__c> {};
            for(Credit__c creditRecordItem : creditRecords){
                creditStoreMapping.put(payer + '_' + creditRecordItem.REL_Account__c + '_' + creditRecordItem.TXT_BuybackName__c , creditRecordItem);
                creditAccountStores.add(creditRecordItem.REL_Account__c);
            }
            creditRecords = null;

            Map<String, List<CreditItem__c>> creditItemStoreMapping = new Map<String, List<CreditItem__c>> {};
            for (CreditItem__c creditItemRecord : creditItemRecords) {
                String key = payer + creditItemRecord.TXT_TagNumber__c;
                if (!creditItemStoreMapping.containsKey(key)) {
                    creditItemStoreMapping.put(key, new List<CreditItem__c>());
                }
                creditItemStoreMapping.get(key).add(creditItemRecord);
                productSkuSet.add(creditItemRecord.REL_Product__c);
                creditItemRecord.TXT_TagNumber__c = '';
                // nullify the data carriers from DWScript;
                // creditItemRecord.REL_Product__c = '';
                // creditItemRecord.REL_AssortmentProductCMIR__c = '';
            }
            creditItemRecords = null;

        } catch(Exception ex) {
            mulesoftFailure = true;
            System.debug('Error occured at ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' Cause : ' + ex.getCause());
            //HLP_CreateExceptionLogs.createLogRecords(null, new Map<String,Object> {'category'=>'Buyback Job','logType'=>'ERROR','statusCode'=>500,'title'=>' Error occurred when pulling Buyback From SAP','description'=>'Error occured at ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' Cause : ' + ex.getCause()});
        }
    }

    /**
     * @description Method to perform the callout with Callout Details and Payer Details
     * @param apiMDT - metadata record for the callout
     * @param payerDetail - payer details for
     */
    private static HttpRequest draftCalloutRequestForBuyBack(MuleSoftApi__mdt apiMDT, String payerDetail){
        HttpRequest requestDetail = new HttpRequest();
        requestDetail.setEndpoint( apiMDT.TXT_DomainCallout__c + apiMDT.TXT_ApiEndpoint__c + payerDetail);
        requestDetail.setMethod('GET');
        requestDetail.setHeader('Content-Type', 'application/json');
        return requestDetail;
    }

    /**
     * @description Method to process the request body to a list of sobject records -  Credit and Credit Items 
     * @param responseBody - response from the callout made
     */
    private static void processRequestResponse(HttpResponse responseBody){
        mulesoftFailure = true;
        if (responseBody.getStatusCode() == 200) {
            
            System.debug(Limits.getHeapSize());
            Map<String,Object> responseDataMap = (Map<String,Object>) JSON.deserializeUnTyped(responseBody.getBody());
            //String productJSONData = JSON.serialize(responseDataMap.get('products'));

            System.debug(Limits.getHeapSize());
            DataWeave.Script script = new DataWeaveScriptResource.jsonToCreditObject();
            DataWeave.Result dwresult = script.execute(new Map<String, Object>{'records' => JSON.serialize(responseDataMap.get('products'))});
            creditRecords = (List<Credit__c>) dwresult.getValue();

            System.debug(Limits.getHeapSize());
            script = new DataWeaveScriptResource.jsonToCreditItemObject();
            dwresult = script.execute(new Map<String, Object>{'records' => JSON.serialize(responseDataMap.get('products'))});
            creditItemRecords = (List<CreditItem__c>) dwresult.getValue();
            
            System.debug(Limits.getHeapSize());
            mulesoftFailure = false;
        } else if (responseBody.getStatusCode() >= 400) {
            //HLP_CreateExceptionLogs.createLogRecords(null, new Map<String,Object> {'category'=>'Buyback Job','logType'=>'ERROR','statusCode'=>500,'title'=>'Error occurred when pulling Buyback From SAP','description'=> 'Error occured with Status Code ' + responseBody.getStatusCode(), 'response'=> responseBody.getStatus(), 'request'=> '', 'objectName'=>'Credit', 'objectAPIName'=> 'Credit__c'}); 
        }
    }

    // This below code is working for Credit and CreditItem
    // String arr = '[{  "buyBackno": "23LOTABFSBB",  "sku": "23001A1",  "prodDesc": "TB FR SEEDING TRPLE ACTN DU 4M (2759157)",  "store": "1064",  "unit": "EA",  "maxQty": "5000.000",  "fullPalqty": "0.000",  "netpr": "36.32",  "stras": "7420 GARNERS FERRY ROAD",  "ort01": "COLUMBIA",  "pstlz": "29209",  "regio": "SC",  "definco": "FRC",  "cmir": "12345",  "dateFrom": "2024-11-01",  "dateTo": "2024-12-31"},{  "buyBackno": "23LOTABFSBB",  "sku": "23001A1",  "prodDesc": "TB FR SEEDING TRPLE ACTN DU 4M (2759157)",  "store": "1066",  "unit": "EA",  "maxQty": "5000.000",  "fullPalqty": "0.000",  "netpr": "36.32",  "stras": "5412 SUNSET BLVD",  "ort01": "LEXINGTON",  "pstlz": "29072",  "regio": "SC",  "definco": "FRC",  "cmir": "654789",  "dateFrom": "2024-11-01",  "dateTo": "2024-12-31"}]';
    // DataWeave.Script script = new DataWeaveScriptResource.jsonToCreditObject();
    // DataWeave.Result dwresult = script.execute(new Map<String, Object> {'records' => arr});
    // System.debug((List<Credit__c>) dwresult.getValue());

    // DataWeave.Script script = new DataWeaveScriptResource.jsonToCreditItemObject();
    // DataWeave.Result dwresult = script.execute(new Map<String, Object> {'records' => arr});
    // System.debug((List<CreditItem__c>) dwresult.getValue());
}
