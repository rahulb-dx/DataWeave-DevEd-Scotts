@IsTest
public with sharing class ObjectProcessingTest {

    // Uses the /dw/csvToContacts.dwl script to convert the csv data to Contact sObjects
    @IsTest
    public static void sObjectsFromDataWeave() {
        // CSV data for Contacts
        Blob data = [SELECT Body FROM StaticResource WHERE Name = 'contacts' LIMIT 1].Body;
        DataWeave.Script script = new DataWeaveScriptResource.csvToContacts();
        DataWeave.Result dwresult = script.execute(new Map<String, Object>{'records' => data});
        List<Contact> results = (List<Contact>) dwresult.getValue();

        Contact codeyContact = results[0];
        Assert.areEqual('James', codeyContact.FirstName);
        Assert.areEqual('Butt', codeyContact.LastName);
        Assert.areEqual('jbutt@gmail.com', codeyContact.Email);
    }
}