%dw 2.0
input records application/csv
output application/apex

fun convertToDateTimeFormat(value) = 
  if (value == null or value == "")  null
  else value as LocalDateTime {format: "MM/dd/yyyy HH:mm:ss"} as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}
---
records map(record) -> {
 Id:record.Id,
 Name: record['Unique Id'],
 CurrencyField__c: (record.Price) as Number,
 Checbox__c: (record['Is Valid']) as Boolean,
 Date_Field__c: record['Ordered Date'] as Date,
 Date_Time_Field__c : convertToDateTimeFormat(record['Ordered DateTime'])
} as Object {class: "Custom_Sales__c"}
