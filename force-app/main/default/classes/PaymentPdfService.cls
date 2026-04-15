public with sharing class PaymentPdfService {
    
    @testVisible
    static Boolean forceFail = false;
    
    @AuraEnabled
    public static Id savePaymentPdf(Id paymentId) {
        
        try {
            
            if (Test.isRunningTest() && forceFail) {
                return null;
            }
            
            PageReference pdfPage = Page.PaymentPdfRenderer;
            pdfPage.getParameters().put('id', paymentId);
            
            Blob pdfBlob;
            
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Payment_' + paymentId;
            cv.PathOnClient = 'Payment_' + paymentId + '.pdf';
            cv.VersionData = pdfBlob;
            insert cv;
            
            cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = cv.ContentDocumentId;
            link.LinkedEntityId = paymentId;
            link.ShareType = 'V';
            link.Visibility = 'AllUsers';
            insert link;
            
            return cv.ContentDocumentId;
            
        } catch (Exception e) {
            return null;
        }
    }
}