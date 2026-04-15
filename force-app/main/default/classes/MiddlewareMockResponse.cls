@isTest
global class MiddlewareMockResponse implements HttpCalloutMock {
    
    private string recordId;
    private string json;
    
    global MiddlewareMockResponse(string recordId){
        this.recordId = recordId;
        
         String jsonData = '[' +
            '{' +
                '"codeType": "CPT",' +
                '"code": "99213",' +
                '"chargeAmt": "150.00",' +
                '"paidAmt": "120.00",' +
                '"revenueCode": "0520",' +
                '"paidUnit": "1",' +
                '"serviceID": "SVC001",' +
                '"serviceDate": "2023-05-15",' +
                '"rarcList": ["N130", "N432"],' +
                '"adjustmentsList": [' +
                    '{"group": "CO", "reasonCode": "45", "amount": "20.00"},' +
                    '{"group": "PR", "reasonCode": "2", "amount": "10.00"}' +
                ']' +
            '},' +
            '{' +
                '"codeType": "HCPCS",' +
                '"code": "J3420",' +
                '"chargeAmt": "250.00",' +
                '"paidAmt": "200.00",' +
                '"revenueCode": "0636",' +
                '"paidUnit": "2",' +
                '"serviceID": "SVC002",' +
                '"serviceDate": "2023-05-16",' +
                '"rarcList": ["N362"],' +
                '"adjustmentsList": [' +
                    '{"group": "CO", "reasonCode": "96", "amount": "30.00"},' +
                    '{"group": "OA", "reasonCode": "18", "amount": "20.00"}' +
                ']' +
            '}' +
        ']';
        
        json = jsonData;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        
        
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data": [{"message": {"body": {"claims": [{"claimNo": "C-'+recordId+'","status": "Approved", "paidAmt": "100.00","services" : '+json+' }],"payerInfo" : {"name":"Test","npi":"Testnpi", "address1":"TestAdd1", "address2":"TestAdd2", "city":"TestCity", "state":"TestState","zip":"002210"},"payeeInfo" : {"name":"Test1","npi":"Testnpi1"} }}}]}');
        res.setStatusCode(200);
        return res;
        
    }
}