@IsTest
public class AuthviaTokenGeneratorTest {

    // Mock class to simulate HTTP response
    private class AuthviaMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('X-Amzn-Trace-Id', 'trace-id-example');
            res.setHeader('X-REQUEST-ID', 'request-id-example');
            res.setHeader('Date', 'Tue, 23 Sep 2025 12:00:00 GMT');
            res.setStatusCode(200);
            
            // Sample JSON response with a token
            res.setBody('{"token":"mocked-token-value"}');
            return res;
        }
    }

    @IsTest
    static void testGetV3MerchantGenerateToken() {
        // Set mock response for HTTP callout
        Test.setMock(HttpCalloutMock.class, new AuthviaMockResponse());
        
        String merchantId = 'testMerchant123';
        String scopeType = 'createLink';
        
        Test.startTest();
        String token = AuthviaTokenGenerator.getV3MerchantGenerateToken(merchantId, scopeType);
        Test.stopTest();
        
        System.assertNotEquals(null, token, 'Token should not be null');
        System.assertEquals('mocked-token-value', token, 'Token value should match mock response');
    }

    @IsTest
    static void testV3GenerateMerchantRequestBody() {
        String merchantId = 'testMerchant123';
        String scopeType = 'createLink';
        
        String jsonBody = AuthviaTokenGenerator.V3GenerateMerchantRequestBody(merchantId, scopeType);
        System.assertNotEquals(null, jsonBody, 'JSON body should not be null');
        System.assert(jsonBody.contains(merchantId), 'JSON body should contain merchantId');
        System.assert(jsonBody.contains('secure_links:create'), 'JSON body should contain scope');
    }

    @IsTest
    static void testParseMethod() {
        String jsonResponse = '{"token":"test-token-123"}';
        String token = AuthviaTokenGenerator.parse(jsonResponse);
        System.assertEquals('test-token-123', token, 'Parse method should extract token correctly');
    }
}