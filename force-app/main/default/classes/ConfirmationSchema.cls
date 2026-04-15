/*
@TestClass 
*/
public class ConfirmationSchema {
    
    public class Services {
        public String codeType {get;set;} 
        public String code {get;set;} 
        public String chargeAmt {get;set;} 
        public String paidAmt {get;set;} 
        public String revenueCode {get;set;} 
        public String paidUnit {get;set;} 
        public String serviceID {get;set;} 
        public String serviceDate {get;set;}
        public List<String> rarcList {get;set;} 
        public List<AdjustmentsList> adjustmentsList {get;set;} 
        
        public Services(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'codeType') {
                            codeType = parser.getText();
                        } else if (text == 'code') {
                            code = parser.getText();
                        } else if (text == 'chargeAmt') {
                            chargeAmt = parser.getText();
                        } else if (text == 'paidAmt') {
                            paidAmt = parser.getText();
                        } else if (text == 'revenueCode') {
                            revenueCode = parser.getText();
                        } else if (text == 'paidUnit') {
                            paidUnit = parser.getText();
                        } else if (text == 'serviceID') {
                            serviceID = parser.getText();
                        } else if (text == 'serviceDate') {
                            serviceDate = parser.getText();
                        } else if (text == 'rarcList') {
                            rarcList = arrayOfStrings(parser);
                        } else if (text == 'adjustmentsList') {
                            adjustmentsList = arrayOfAdjustmentsList(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Services consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Claims {
        public String claimNo {get;set;} 
        public String paidBy {get;set;} 
        public String chargeAmt {get;set;} 
        public String paidAmt {get;set;} 
        public String status {get;set;} 
        public String patientAmt {get;set;} 
        public String referenceId {get;set;} 
        public String claimServiceDateStart {get;set;} 
        public String claimServiceDateEnd {get;set;} 
        public String claimReceivedDate {get;set;} 
        public String patientFirstName {get;set;} 
        public String patientLastName {get;set;} 
        public String patientId {get;set;} 
        public String patientEntityType {get;set;} 
        public String renderingProviderFirstName {get;set;} 
        public String renderingProviderLastName {get;set;} 
        public String renderingProviderId {get;set;} 
        public String renderingProviderEntityType {get;set;} 
        public List<Services> services {get;set;} 
        
        public Claims(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'claimNo') {
                            claimNo = parser.getText();
                        } else if (text == 'paidBy') {
                            paidBy = parser.getText();
                        } else if (text == 'chargeAmt') {
                            chargeAmt = parser.getText();
                        } else if (text == 'paidAmt') {
                            paidAmt = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'patientAmt') {
                            patientAmt = parser.getText();
                        } else if (text == 'referenceId') {
                            referenceId = parser.getText();
                        } else if (text == 'claimServiceDateStart') {
                            claimServiceDateStart = parser.getText();
                        } else if (text == 'claimServiceDateEnd') {
                            claimServiceDateEnd = parser.getText();
                        } else if (text == 'claimReceivedDate') {
                            claimReceivedDate = parser.getText();
                        } else if (text == 'patientFirstName') {
                            patientFirstName = parser.getText();
                        } else if (text == 'patientLastName') {
                            patientLastName = parser.getText();
                        } else if (text == 'patientId') {
                            patientId = parser.getText();
                        } else if (text == 'patientEntityType') {
                            patientEntityType = parser.getText();
                        } else if (text == 'renderingProviderFirstName') {
                            renderingProviderFirstName = parser.getText();
                        } else if (text == 'renderingProviderLastName') {
                            renderingProviderLastName = parser.getText();
                        } else if (text == 'renderingProviderId') {
                            renderingProviderId = parser.getText();
                        } else if (text == 'renderingProviderEntityType') {
                            renderingProviderEntityType = parser.getText();
                        } else if (text == 'services') {
                            services = arrayOfServices(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Claims consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class PayeeInfo {
        public String name {get;set;} 
        public String npi {get;set;} 
        public String address1 {get;set;} 
        public String address2 {get;set;} 
        public String city {get;set;} 
        public String state {get;set;} 
        public String zip {get;set;} 
        public String taxID {get;set;} 
        
        public PayeeInfo(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'npi') {
                            npi = parser.getText();
                        } else if (text == 'address1') {
                            address1 = parser.getText();
                        } else if (text == 'address2') {
                            address2 = parser.getText();
                        } else if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'zip') {
                            zip = parser.getText();
                        } else if (text == 'taxID') {
                            taxID = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'PayeeInfo consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Message {
        public Body body {get;set;} 
        
        public Message(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'body') {
                            body = new Body(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Message consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class PayerInfo {
        public String name {get;set;} 
        public String npi {get;set;} 
        public String address1 {get;set;} 
        public String address2 {get;set;} 
        public String city {get;set;} 
        public String state {get;set;} 
        public String zip {get;set;} 
        
        public PayerInfo(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'npi') {
                            npi = parser.getText();
                        } else if (text == 'address1') {
                            address1 = parser.getText();
                        } else if (text == 'address2') {
                            address2 = parser.getText();
                        } else if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'zip') {
                            zip = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'PayerInfo consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Data {
        public String file {get;set;} 
        public Message message {get;set;} 
        
        public Data(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'file') {
                            file = parser.getText();
                        } else if (text == 'message') {
                            message = new Message(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class AdjustmentsList {
        public String group_Z {get;set;} // in json: group
        public String reasonCode {get;set;} 
        public String amount {get;set;} 
        
        public AdjustmentsList(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'group') {
                            group_Z = parser.getText();
                        } else if (text == 'reasonCode') {
                            reasonCode = parser.getText();
                        } else if (text == 'amount') {
                            amount = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'AdjustmentsList consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public class Body {
        public String transCode {get;set;} 
        public String totalPayment {get;set;} 
        public String creditDebitFlag {get;set;} 
        public String paymentCode {get;set;} 
        public String paymentDate {get;set;} 
        public PayerInfo payerInfo {get;set;} 
        public PayeeInfo payeeInfo {get;set;} 
        public List<Claims> claims {get;set;} 
        
        public Body(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'transCode') {
                            transCode = parser.getText();
                        } else if (text == 'totalPayment') {
                            totalPayment = parser.getText();
                        } else if (text == 'creditDebitFlag') {
                            creditDebitFlag = parser.getText();
                        } else if (text == 'paymentCode') {
                            paymentCode = parser.getText();
                        } else if (text == 'paymentDate') {
                            paymentDate = parser.getText();
                        } else if (text == 'payerInfo') {
                            payerInfo = new PayerInfo(parser);
                        } else if (text == 'payeeInfo') {
                            payeeInfo = new PayeeInfo(parser);
                        } else if (text == 'claims') {
                            claims = arrayOfClaims(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Body consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Data> data {get;set;} 
    
    public ConfirmationSchema(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'data') {
                        data = arrayOfData(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'ConfirmationSchema consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    /*public class AdjustmentsList_Z {
public String group_Z {get;set;} // in json: group
public String reasonCode {get;set;} 
public String amount {get;set;} 

public AdjustmentsList_Z(JSONParser parser) {
while (parser.nextToken() != System.JSONToken.END_OBJECT) {
if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
String text = parser.getText();
if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
if (text == 'group') {
group_Z = parser.getText();
} else if (text == 'reasonCode') {
reasonCode = parser.getText();
} else if (text == 'amount') {
amount = parser.getText();
} else {
System.debug(LoggingLevel.WARN, 'AdjustmentsList_Z consuming unrecognized property: '+text);
consumeObject(parser);
}
}
}
}
}
}*/
    
    /*public class Services_Z {
public String codeType {get;set;} 
public String code {get;set;} 
public String chargeAmt {get;set;} 
public String paidAmt {get;set;} 
public String revenueCode {get;set;} 
public String paidUnit {get;set;} 
public String serviceDate {get;set;} 
public List<AdjustmentsList_Z> adjustmentsList {get;set;} 

public Services_Z(JSONParser parser) {
while (parser.nextToken() != System.JSONToken.END_OBJECT) {
if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
String text = parser.getText();
if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
if (text == 'codeType') {
codeType = parser.getText();
} else if (text == 'code') {
code = parser.getText();
} else if (text == 'chargeAmt') {
chargeAmt = parser.getText();
} else if (text == 'paidAmt') {
paidAmt = parser.getText();
} else if (text == 'revenueCode') {
revenueCode = parser.getText();
} else if (text == 'paidUnit') {
paidUnit = parser.getText();
} else if (text == 'serviceDate') {
serviceDate = parser.getText();
} else if (text == 'adjustmentsList') {
adjustmentsList = arrayOfAdjustmentsList_Z(parser);
} else {
System.debug(LoggingLevel.WARN, 'Services_Z consuming unrecognized property: '+text);
consumeObject(parser);
}
}
}
}
}
}*/
    
    
    public static ConfirmationSchema parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ConfirmationSchema(parser);
    }
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                           curr == System.JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    
    
    
    
    
    private static List<Claims> arrayOfClaims(System.JSONParser p) {
        List<Claims> res = new List<Claims>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Claims(p));
        }
        return res;
    }
    
    
    
    private static List<Services> arrayOfServices(System.JSONParser p) {
        List<Services> res = new List<Services>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Services(p));
        }
        return res;
    }
    
    
    private static List<AdjustmentsList> arrayOfAdjustmentsList(System.JSONParser p) {
        List<AdjustmentsList> res = new List<AdjustmentsList>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AdjustmentsList(p));
        }
        return res;
    }
    
    
    
    
    
    
    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }
    public static List<String> arrayOfStrings(JSONParser parser) {
        List<String> result = new List<String>();
        while (parser.nextToken() != System.JSONToken.END_ARRAY) {
            if (parser.getCurrentToken() == System.JSONToken.VALUE_STRING) {
                result.add(parser.getText());
            }
        }
        return result;
    }
    
    
}