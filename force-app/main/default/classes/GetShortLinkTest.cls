@IsTest
public class GetShortLinkTest {

    // Mock response for Authvia token generation
    private class AuthviaTokenMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('X-Amzn-Trace-Id', 'trace-id');
            res.setHeader('X-REQUEST-ID', 'request-id');
            res.setHeader('Date', 'Tue, 23 Sep 2025 12:00:00 GMT');
            res.setStatusCode(200);
            res.setBody('{"token":"mocked-token"}');
            return res;
        }
    }

    // Mock response for secure link creation
    private class SecureLinkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"address":"https://short.link/example"}');
            return res;
        }
    }

    // Mock response for followRedirect
    private class RedirectMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            // Simulate redirect status
            res.setStatusCode(302);
            res.setHeader('Location', 'https://final.destination.com');
            return res;
        }
    }

    @IsTest
    static void testInvokeAPICall() {
        Test.setMock(HttpCalloutMock.class, new AuthviaTokenMock());
        String token = AuthviaTokenGenerator.getV3MerchantGenerateToken('merchant123','createLink');
        System.assertEquals('mocked-token', token);

        // Now mock the secure link creation
        Test.setMock(HttpCalloutMock.class, new SecureLinkMock());
        String requestBody = '{"destination":"https://original.url.com"}';
        String shortLink = GetShortLink.invokeAPICall('merchant123', requestBody);
        System.assertEquals('https://short.link/example', shortLink);
    }

    @IsTest
    static void testInvokeApex() {
        Test.setMock(HttpCalloutMock.class, new SecureLinkMock());

        GetShortLink.FlowRequest req = new GetShortLink.FlowRequest();
        req.merchantId = 'merchant123';
        req.requestBody = '{"destination":"https://original.url.com"}';

        List<GetShortLink.FlowRequest> requests = new List<GetShortLink.FlowRequest>{req};
        List<GetShortLink.FlowResponse> responses = GetShortLink.invokeApex(requests);

        System.assertEquals(1, responses.size());
        System.assertEquals('https://short.link/example', responses[0].shortLink);
    }

    @IsTest
    static void testFollowRedirect() {
        Test.setMock(HttpCalloutMock.class, new RedirectMock());

        String inputUrl = 'https://redirect.url.com';
        String finalUrl = GetShortLink.followRedirect(inputUrl);

        System.assertEquals('https://final.destination.com', finalUrl);
    }
}