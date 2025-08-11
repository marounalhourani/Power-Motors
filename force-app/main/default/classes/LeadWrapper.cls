public with sharing class LeadWrapper {
    public Integer totalSize; // 1
    public Boolean done; // true
    public List<Records> records;

    public class Records {
        public Attributes attributes;
        //you cannot use logoUrl__c
        public String logoUrl; // "https://pbs.twimg.com/media/EiHdOjoX0AEz8Ec.png"
        public Integer NumberOfEmployees; // 150
        public String Foundation_date; // "2008-09-24"
        public BillingAddress BillingAddress;
        public String Description; // "EI-Technologies MENA, by NEO-DIS.COM, is the l...

    }

    public class Attributes {
        public String type; // "Account"
        public String url; // "/services/data/v54.0/sobjects/Account/0018d000...
    }

    public class BillingAddress {
        public String city; // "Metn"
        public String country; // "Lebanon"
        public String geocodeAccuracy;
        public String latitude;
        public String longitude;
        public String postalCode;
        public String state;
        public String street; // "Electricity street Hashem Building, 6th floor"
    }

    public static LeadWrapper parse(String jsonString) {
        return (LeadWrapper) JSON.deserialize(jsonString, LeadWrapper.class);
    }
}
/* Generated at https://www.ratedcalculator.com/software/json-to-apex-converter */ 

