@isTest
private class CMS1500ControllerTest {

    // 🔹 Success Mock
    class CMS1500Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBodyAsBlob(Blob.valueOf('Dummy PDF Content'));
            return res;
        }
    }

    // 🔹 Exception Mock (✅ moved outside method)
    class ExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Mock Exception');
        }
    }

    @isTest
    static void testGenerate_Success() {

        Claim__c claim = new Claim__c(
            Claim_Request__c = '{"test":"data"}'
        );
        insert claim;

        Test.setMock(HttpCalloutMock.class, new CMS1500Mock());

        ApexPages.StandardController sc = new ApexPages.StandardController(claim);
        CMS1500Controller controller = new CMS1500Controller(sc);

        Test.startTest();
        controller.generate();
        Test.stopTest();

        System.assertEquals(true, controller.isSuccess);
        System.assertEquals(200, controller.statusCode);
    }

    @isTest
    static void testGenerate_EmptyRequest() {

        Claim__c claim = new Claim__c();
        insert claim;

        ApexPages.StandardController sc = new ApexPages.StandardController(claim);
        CMS1500Controller controller = new CMS1500Controller(sc);

        Test.startTest();
        controller.generate();
        Test.stopTest();

        System.assertEquals(false, controller.isSuccess);
        System.assert(controller.errorMessage.contains('Claim Request is empty'));
    }

    @isTest
    static void testGenerate_CalloutException() {

        Claim__c claim = new Claim__c(
            Claim_Request__c = '{"test":"data"}'
        );
        insert claim;

        Test.setMock(HttpCalloutMock.class, new ExceptionMock());

        ApexPages.StandardController sc = new ApexPages.StandardController(claim);
        CMS1500Controller controller = new CMS1500Controller(sc);

        Test.startTest();
        controller.generate();
        Test.stopTest();

        System.assertEquals(false, controller.isSuccess);
        System.assert(controller.errorMessage.contains('CalloutException'));
    }
}