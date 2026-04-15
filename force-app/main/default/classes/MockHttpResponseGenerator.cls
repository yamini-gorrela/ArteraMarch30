@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    Public Static Boolean respondWithError = false;
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint() == 'https://integrations.eclouds.co:8443/api/v1/claim'){
            if(respondWithError){
				system.debug('Entered in error');
                res.setStatusCode(400);
				res.setBody('Error');                
            }else{
            	res.setBody('{"example":"test"}');  
            	res.setStatusCode(200);
            }
        }else if(req.getEndpoint() == 'https://integrations.eclouds.co:8443/api/v1/verification'){
            system.debug('Enetered in verification');
            res.setStatusCode(200);
            res.setBody('[{"name":"999","data":[{"file":"123904.dat.4170143.999","claim_id":"a385f00000052r5AAA","message":{"Status":"Validated"}}]},{"name":"277","data":[{"file":"123904.dat.4170147.277","claim_id":"a385f00000052r5AAA","message":{"status":"Rejected","items":[{"name":"ABILITYNETWORK","first_name":"","identification_code":"411973195","entity":"Clearinghouse","type":"Facility","code_qualifier":"","trace_number":"","references":[],"details":[]},{"name":"EATING_DISORDER_RECOVERY_SPECIALIST","first_name":"","identification_code":"821687876","entity":"Receiver","type":"Facility","code_qualifier":"","trace_number":"123904","references":[{"type":"PayerClaimNumber","number":"G4521278810"},{"type":"BillingType","number":"11"}],"payment":{"type":"Rejected","qty":"1","amount_type":"Returned","amount":"330"},"service_date_from":"20220306","service_date_to":"20220313","details":[{"category_code":"A2","status_code":"20","date":"20220924","amount":"330","note":""}]},{"name":"EATING_DISORDER_RECOVERY_SPECIALIST","first_name":"","identification_code":"1881928539","entity":"BillingProvider","type":"Facility","code_qualifier":"Medicare","trace_number":"","references":[],"details":[]},{"name":"MEGHAN","first_name":"LEONHARDT","identification_code":"VQA449W01913","entity":"Patient","type":"Person","code_qualifier":"MemberIdentificationNumber","trace_number":"","references":[],"details":[{"category_code":"A2","status_code":"20","date":"20220924","amount":"330.00","note":"REJECTEDFORPROCESSING."}]}]}}]}]');
        }else if(req.getEndpoint() == 'https://integrations.eclouds.co:8443/api/v1/oauth'){
			res.setStatusCode(200);
            res.setBody('{"access_token":"eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJqdGkiOiJPcHhkVTZnMjc2SlRPUzNyYk51MEVnIiwiaXNzIjoiZUNsb3VkcyIsInN1YiI6IlNGMkVIUiBwcm92aWRlciIsIm5iZiI6MTY2NzM4Mjc2MiwiZXhwIjoxNjY3Mzg2NDIyLCJpYXQiOjE2NjczODI4MjIsImF1ZCI6Ik9hdXRoIDIgVVJMIGVuZHBvaW50In0.GO1Iz9ncfooZqFnMGx-AIYXOnNF3hydf84jg5wnffLMlQLWKt7H02cKOxdp2YnF1lq40w5Byc0JhEk8PVnsnnvgjwtsUCdCrHPvqg778pgJdSHSuOmP-rNh_Brav9RUGe4_Qq06Cno3hRrIuaYKdoNW19sJU1WcMqKIp2Da7MwCrbc10dKHTmZ0H7YvRKVWfObST0CSUWAAEiCRBFa-iu6gPXDHXTlRzKC"}');
            system.debug('enetered in access token');
        }else if(req.getEndpoint() == 'https://integrations.eclouds.co:8443/api/v1/confirmation'){
            system.debug('Entered in confirmation');
            res.setStatusCode(200);
            res.setBody('{"data":[{"file":"ALLSTATE_20240208_0.835","message":{"body":{"transCode":"H","totalPayment":"0","creditDebitFlag":"C","paymentCode":"NON","paymentDate":"20240208","payerInfo":{"name":"Allstate","npi":"","address1":"PO BOX 2874","address2":"","city":"Clinton","state":"IA","zip":"527332874"},"payeeInfo":{"name":"CENTER FOR PHYSICAL MEDICINE","npi":"1568914117","address1":"2601 CATTLEMEN ROAD SUITE 400","address2":"","city":"SARASOTA","state":"FL","zip":"342326233","taxID":"812888089"},"claims":[{"claimNo":"C-00072A385F000001M7TQAAQ","paidBy":"1","chargeAmt":"522","paidAmt":"0","status":"Adjusted","patientAmt":"","referenceId":"92364627-0","claimServiceDateStart":"20240108","claimReceivedDate":"20240206","patientLastName":"MARTIN","insuredFirstName":"HUGO","patientId":"0740254578","patientEntityType":"Person","services":[{"codeType":"HC","code":"97112","chargeAmt":"117","paidAmt":"0","revenueCode":"","paidUnit":"1","serviceDate":"20240108","adjustmentsList":[{"group":"Payor Initiated Reduction","reasonCode":"149","amount":"117"}]},{"codeType":"HC","code":"97150","chargeAmt":"60","paidAmt":"0","revenueCode":"","paidUnit":"1","serviceDate":"20240108","adjustmentsList":[{"group":"Payor Initiated Reduction","reasonCode":"149","amount":"60"}]},{"codeType":"HC","code":"98940","chargeAmt":"93","paidAmt":"0","revenueCode":"","paidUnit":"1","serviceDate":"20240108","adjustmentsList":[{"group":"Payor Initiated Reduction","reasonCode":"149","amount":"93"}]},{"codeType":"HC","code":"97012","chargeAmt":"50","paidAmt":"0","revenueCode":"","paidUnit":"1","serviceDate":"20240108","adjustmentsList":[{"group":"Payor Initiated Reduction","reasonCode":"149","amount":"50"}]},{"codeType":"HC","code":"97110","chargeAmt":"202","paidAmt":"0","revenueCode":"","paidUnit":"2","serviceDate":"20240108","adjustmentsList":[{"group":"Payor Initiated Reduction","reasonCode":"149","amount":"202"}]}]}]}}}]}');

        }else{
        	res.setBody('{"example":"test"}');  
            res.setStatusCode(200);
        }
        
        
        return res;
    }
}