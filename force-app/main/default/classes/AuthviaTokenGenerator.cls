public class AuthviaTokenGenerator {
    public static String getV3MerchantGenerateToken(String merchantId,String scopeType) {
        string endPointUrl = 'https://api.authvia.com/v3/tokens';
        
        String jsonBody = V3GenerateMerchantRequestBody(merchantId,scopeType);
        System.debug('!!jsonBody::'+jsonBody);
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointUrl);   
        req.setHeader('Content-type', 'application/json');
        req.setBody(jsonBody); 
        req.setMethod('POST');
        HttpResponse res;
        res = h.send(req);
        string amzTraceId = res.getHeader('X-Amzn-Trace-Id');
        string reqId = res.getHeader('X-REQUEST-ID');
        string dt = res.getHeader('Date');
        System.debug('!!res::'+res.getBody());   
        return parse(res.getBody());
    }
    
    public static String V3GenerateMerchantRequestBody(String merchantId,String scopeType){
        String nameSpace = 'AVPAY__';
        
        Datetime dt = Datetime.now();
        Long l = dt.getTime()/1000;
        Integer timestamp = Integer.valueOf(l);
        String secretf = AVPAY.GenerateNewHmac.generateAppSignature(timestamp);
        String secretValue = '855366aabffhfff476418729343';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('client_id','d517aff5-ed95-4657-8e28-1196393eb56a');  
        gen.writeStringField('signature_value',secretValue);
        gen.writeNumberField('timestamp',timestamp);
        gen.writeStringField('signature',secretf);
        gen.writeStringField('audience','api.authvia.com/v3');
        if(scopeType == 'createLink'){
            gen.writeStringField('scope','secure_links:create secure_links:read secure_links:update');
        }
        gen.writeStringField('expiration','3h'); 
        gen.writeStringField('role','merchant');
        gen.writeStringField('merchantId',merchantId);
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    public static String parse(String json){
        string token;
        Map<String, String> m = (Map<String, String>) System.JSON.deserialize(json,  Map<String, String>.class);
        token = m.get('token');
        return token;
    }
}