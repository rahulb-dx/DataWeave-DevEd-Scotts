%dw 2.0
input records application/csv
output application/apex
---
records map(record) -> {
 Id:record.Id,
 Name: record['Unique Id'],
 CurrencyField__c: (record.Price) as Number,
 Checbox__c: (record['Is Valid']) as Boolean,
 Date_Field__c: (record['Ordered Date']) as Date,
} as Object {class: "Custom_Sales__c"}
