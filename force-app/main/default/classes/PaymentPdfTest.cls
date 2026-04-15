@isTest
private class PaymentPdfTest {
    
    private class PaymentCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setStatusCode(200);
            
            res.setBody('<html><body><h1>Mock PDF Content</h1></body></html>');
            return res;
        }
    }
    
    
    @isTest
    static void testAllPaymentFlow() {
        
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        
        Payment__c pay = new Payment__c(
            Raw_Data__c = '{"transCode":"I","payerID:":"HUMANA"}'
        );
        insert pay;
        
        Test.setCurrentPage(Page.PaymentPdfRenderer);
        ApexPages.currentPage().getParameters().put('id', pay.Id);
        
        Test.startTest();
        PaymentPrintController ctrl = new PaymentPrintController();
        System.assertNotEquals(null, ctrl.htmlContent);
        System.assert(ctrl.htmlContent.contains('Mock PDF Content'));
        
        Id docId = PaymentPdfService.savePaymentPdf(pay.Id);
        System.assertNotEquals(null, docId);
        
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :pay.Id
        ];
        System.assert(links.size() > 0);
        
        Map<String, Object> result = PaymentPdfLauncherController.generate(pay.Id);
        System.assertEquals(true, result.get('success'));
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testHTMLDirectFlow() {
        
        Payment__c pay = new Payment__c(
            Raw_Data__c = '<html><body>Direct HTML</body></html>'
        );
        insert pay;
        
        Test.setCurrentPage(Page.PaymentPdfRenderer);
        ApexPages.currentPage().getParameters().put('id', pay.Id);
        
        Test.startTest();
        
        PaymentPrintController ctrl = new PaymentPrintController();
        
        Test.stopTest();
        
        System.assert(ctrl.htmlContent.contains('Direct HTML'));
    }
    
    
    @isTest
    static void testNoRawData() {
        
        Payment__c pay = new Payment__c(
            Raw_Data__c = null
        );
        insert pay;
        
        Test.startTest();
        
        Map<String, Object> result = PaymentPdfLauncherController.generate(pay.Id);
        
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
    }
    @isTest
    static void testGenerate_PdfFailure() {
        
        Payment__c pay = new Payment__c(
            Raw_Data__c = '<html><body>Test</body></html>'
        );
        insert pay;
        
        PaymentPdfService.forceFail = true;
        
        Test.startTest();
        
        Map<String, Object> result = PaymentPdfLauncherController.generate(pay.Id);
        
        Test.stopTest();
        
        PaymentPdfService.forceFail = false;
    }
    @isTest
    static void testGenerate_Exception() {
        
        Test.startTest();
        
        Map<String, Object> result = PaymentPdfLauncherController.generate(null);
        
        Test.stopTest();
        
        System.assertEquals(false, result.get('success'));
        System.assert(result.get('message') != null);
    }
}