global with sharing class PaymentPdfLauncherController {
    
    public PaymentPdfLauncherController(ApexPages.StandardController controller) {}
    
    @RemoteAction
    global static Map<String, Object> generate(Id paymentId) {
        
        Map<String, Object> res = new Map<String, Object>();
        
        try {
            Payment__c pay = [
                SELECT Raw_Data__c
                FROM Payment__c
                WHERE Id = :paymentId
                LIMIT 1
            ];
            
            if (String.isBlank(pay.Raw_Data__c)) {
                res.put('success', false);
                res.put('message', 'Cannot proceed to print payment: No data available.');
                return res;
            }
            
            Id docId = PaymentPdfService.savePaymentPdf(paymentId);
            
            if (docId != null) {
                res.put('success', true);
                res.put('documentId', docId);
                res.put('message', 'PDF generated successfully and saved to Files.');
            } else {
                res.put('success', false);
                res.put('message', 'Error generating PDF.');
            }
            
        } catch (Exception e) {
            res.put('success', false);
            res.put('message', 'Error: ' + e.getMessage());
        }
        
        return res;
    }
}