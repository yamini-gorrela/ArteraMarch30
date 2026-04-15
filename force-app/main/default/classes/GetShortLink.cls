public class GetShortLink {
    
    public static string invokeAPICall(string merchantId, string requestBody) {
        system.debug('!!request::'+requestBody);

        String returnShortLink;
        String nameSpace = 'AVPAY__';
        String scopeType = 'createLink';
        String token = AuthviaTokenGenerator.getV3MerchantGenerateToken(merchantId, 'createLink');
        string endPointUrl = 'https://api.authvia.com/v3/secure-links';
        
        try {
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            if (requestMap.containsKey('destination')) {
                String destination = String.valueOf(requestMap.get('destination'));
                String finalRedirectUrl = followRedirect(destination);
                if (!String.isBlank(finalRedirectUrl)) {
                    requestMap.put('destination', finalRedirectUrl); // Step 3: Replace it
                }
            }
            
            String updatedRequestBody = JSON.serialize(requestMap);            
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            request.setEndpoint(endPointUrl);
            if(token != null){
                request.setHeader('Authorization', 'Bearer'+' '+token);   
            }
            request.setHeader('Content-type', 'application/json');
            request.setMethod('POST');
            request.setTimeout(60000);
            if (updatedRequestBody != null) {
                request.setBody(updatedRequestBody);
            }
            system.debug('!!updatedRequestBody::'+updatedRequestBody);
            HttpResponse res = http.send(request);
            System.debug('!!res: ' + res.getStatus() + ', ' + res.getBody());
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (resMap.containsKey('address')) {
                    returnShortLink = String.valueOf(resMap.get('address'));
                }
            } else {
                System.debug('!!error:: ' + res.getStatus() + ', ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('!!Exception: ' + e.getMessage());
        }
        return returnShortLink;
    }
    
    @InvocableMethod(label='Get Short Link' description='Gets the short link')
    public static  List<FlowResponse> invokeApex(List<FlowRequest> requests) {
        List<FlowResponse> responses = new List<FlowResponse>();
        for (FlowRequest request : requests) {
            FlowResponse resp = new FlowResponse();
            resp.shortLink = invokeAPICall(request.merchantId, request.requestBody);
            responses.add(resp);
        }
        return responses;
        
    }
    
    public static String followRedirect(String inputUrl) {
        String finalUrl = inputUrl;
        Http http = new Http();
        
        for (Integer i = 0; i < 5; i++) { // max 5 redirects
            HttpRequest req = new HttpRequest();
            req.setEndpoint(finalUrl);
            req.setMethod('GET');
            req.setTimeout(10000);
            
            HttpResponse res = http.send(req);
            
            Integer statusCode = res.getStatusCode();
            
            // Check for redirect status
            if (statusCode == 301 || statusCode == 302 || statusCode == 307 || statusCode == 308) {
                finalUrl = res.getHeader('Location');
                if (String.isBlank(finalUrl)) {
                    break; // no location to redirect
                }
            } else {
                // not a redirect, assume final destination
                break;
            }
        }
        
        return finalUrl;
    }
    
    public class FlowRequest {
        @InvocableVariable(label='Merchant Id' description='merchant Id')
        public String merchantId;
        
        @InvocableVariable(label='Request' description='requestBody')
        public String requestBody;
    }
    
    public class FlowResponse {
        @InvocableVariable(label='Short Link' description='The generated short link')
        public String shortLink;
    }
}