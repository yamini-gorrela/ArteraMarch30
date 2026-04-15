@isTest
private class PaymentPdfTest {
    
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setBody('<html><body><h1>Test HTML</h1></body></html>');
            res.setStatusCode(200);
            return res;
        }
    }
    
    static Payment__c createPayment(Boolean withData) {
        Payment__c p = new Payment__c();
        if (withData) {
            p.Raw_Data__c = '<html><body>Test Payment</body></html>';
        }
        insert p;
        return p;
    }
    
    @isTest
    static void testPrintController_withHtml() {
        
        Payment__c p = createPayment(true);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', p.Id);
        PaymentPrintController ctrl = new PaymentPrintController();
        
        Test.stopTest();
        
        System.assertNotEquals(null, ctrl.htmlContent);
    }
    
    @isTest
    static void testPrintController_withCallout() {
        
        Payment__c p = new Payment__c(Raw_Data__c = '{"test":"data"}');
        insert p;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', p.Id);
        PaymentPrintController ctrl = new PaymentPrintController();
        
        Test.stopTest();
        
        System.assertNotEquals(null, ctrl.htmlContent);
    }
    
    @isTest
    static void testSavePaymentPdf() {
        
        Payment__c p = createPayment(true);
        
        Test.startTest();
        
        Id docId = PaymentPdfService.savePaymentPdf(p.Id);
        
        Test.stopTest();
        
        System.assertNotEquals(null, docId);
        
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :p.Id
        ];
        
        System.assert(links.size() > 0);
    }
    
    @isTest
    static void testLauncher_success() {
        
        Payment__c p = createPayment(true);
        
        Test.startTest();
        
        Map<String, Object> res =
            PaymentPdfLauncherController.generate(p.Id);
        
        Test.stopTest();
        
        System.assertEquals(true, res.get('success'));
        System.assertNotEquals(null, res.get('documentId'));
    }
    
    @isTest
    static void testLauncher_noData() {
        
        Payment__c p = createPayment(false);
        
        Test.startTest();
        
        Map<String, Object> res =
            PaymentPdfLauncherController.generate(p.Id);
        
        Test.stopTest();
        
        System.assertEquals(false, res.get('success'));
        System.assertEquals(
            'Cannot proceed to print payment: No data available.',
            res.get('message')
        );
    }
    @isTest
    static void testLauncher_pdfFailure() {
        
        Payment__c p = new Payment__c(Raw_Data__c = '<html>Test</html>');
        insert p;
        
        PaymentPdfService.forceFail = true;
        
        Test.startTest();
        
        Map<String, Object> res =
            PaymentPdfLauncherController.generate(p.Id);
        
        Test.stopTest();
        
        System.assertEquals(false, res.get('success'));
        System.assertEquals('Error generating PDF.', res.get('message'));
    }
}