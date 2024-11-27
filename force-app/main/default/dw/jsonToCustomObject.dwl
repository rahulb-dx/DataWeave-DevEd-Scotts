Credit Script

%dw 2.0
input records application/json
output application/apex

fun convertToDateTimeFormat(value) = 
  if (value == null or value == "")  null
  else value as LocalDateTime {format: "MM/dd/yyyy HH:mm:ss"} as DateTime {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}
---
records map(record) -> {
 TXT_BuybackName__c: record['buyBackno'],
 REL_Account__c : record['store'],
 SEL_TransportContract__c : record['definco'],
 DTE_ValidTo__c : convertToDateTimeFormat(record['dateTo']),
 DTE_ValidFrom__c : convertToDateTimeFormat(record['dateFrom'])
} as Object {class: 'Credit__c'}


Credit Item Script

%dw 2.0
input records application/json
output application/apex

fun convertToNumber(value) =
  if (value == null or value == "")  0 
  else value as Number

---
records map(record) -> {
 REL_AssortmentProductCMIR__c: record['sku'],
 CUR_Price__c : convertToNumber(record['netpr']),
 NUM_PalletQuantity__c : convertToNumber(record['fullPalqty']),
 TXT_UoM__c : record['unit'],
 NUM_MaxQuantity__c : convertToNumber(record['maxQty']), 
} as Object {class: 'CreditItem__c'}