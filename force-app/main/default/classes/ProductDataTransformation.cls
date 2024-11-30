public with sharing class ProductDataTransformation {
    public class ProductData {
        public String buyBackno;
        public String sku;
        public String prodDesc;
        public String store;
        public String unit;
        public Decimal maxQty;
        public Decimal fullPalqty;
        public Decimal netpr;
        public String stras;
        public String ort01;
        public String pstlz;
        public String regio;
        public String definco;
        public String cmir;
        public String dateFrom;
        public String dateTo;
    }
    
    public void performCalloutAndDataTransformation(){
        // Deserialize the JSON string into a list of ProductData objects
        List<ProductData> products = (List<ProductData>) JSON.deserialize(jsonData, List<ProductData>.class);
        
    }
}