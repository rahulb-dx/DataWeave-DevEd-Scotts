public class ContactsInsertDryRun {
    
    public static void insertContactsFromCSV(){
        Blob data = [SELECT Body FROM StaticResource WHERE Name = 'contacts' LIMIT 1].Body;
        DataWeave.Script script = new DataWeaveScriptResource.csvToContacts();
        DataWeave.Result dwresult = script.execute(new Map<String, Object>{'records' => data});
        List<Contact> results = (List<Contact>) dwresult.getValue();
		insert results;
    }

    public static void insertCustomSalesFromCSV(){
        Blob data = [SELECT Body FROM StaticResource WHERE Name = 'CustomSalesData' LIMIT 1].Body;
        DataWeave.Script script = new DataWeaveScriptResource.csvToCustomObject();
        DataWeave.Result dwresult = script.execute(new Map<String, Object>{'records' => data});
        List<Custom_Sales__c> results = (List<Custom_Sales__c>) dwresult.getValue();
		upsert results;
    }
    
    public static void insertCustomSalesFromJSON(){
        Blob data = [SELECT Body FROM StaticResource WHERE Name = 'CustomSalesData' LIMIT 1].Body;
        DataWeave.Script script = new DataWeaveScriptResource.csvToCustomObject();
        DataWeave.Result dwresult = script.execute(new Map<String, Object>{'records' => data, 'myrecord' => data});
        System.debug(JSON.serializePretty(dwresult.getValue()));
        List<Custom_Sales__c> results = (List<Custom_Sales__c>) dwresult.getValue();
		//upsert results;
    }
}