public with sharing class PaymentPrintController {
    
    public String htmlContent { get; set; }
    
    public PaymentPrintController() {
        Id paymentId = ApexPages.currentPage().getParameters().get('id');
        
        if (paymentId != null) {
            Payment__c pay = [
                SELECT Raw_Data__c
                FROM Payment__c
                WHERE Id = :paymentId
                LIMIT 1
            ];
            
            htmlContent = processData(pay.Raw_Data__c);
        }
    }
    
    public String processData(String rawData) {
        try {
            String html;
            
            if (rawData != null && rawData.trim().startsWith('<')) {
                html = rawData;
            } 
            else {
                if (rawData != null) {
                    rawData = rawData.replace('"payerID:"', '"payerID"');
                }
                
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint('https://integrations.eclouds.co:8445/api2/billing_doc?payment=true');
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer AKaIGijJbu6GhaQuY55B3Ec4SD9hSVPBjOKRTDfZLladw4ZGRSWalHABJGhkaWfJ');
                req.setHeader('Content-Type', 'application/json');
                
                req.setBody(rawData);
                
                HttpResponse res = http.send(req);
                
                System.debug('STATUS: ' + res.getStatusCode());
                System.debug('RESPONSE: ' + res.getBody());
                
                if (res.getStatusCode() != 200) {
                    return '<h2>API Error:</h2><pre>' + res.getBody() + '</pre>';
                }
                
                html = res.getBody();
            }
            
            html = makeHtmlPdfSafe(html);
            
            return html;
            
        } catch (Exception e) {
            return '<h2>Error:</h2>' + e.getMessage();
        }
    }
    
    public String makeHtmlPdfSafe(String html) {
        
        if (String.isBlank(html)) return '';
        html = html.replaceAll('display\\s*:\\s*flex;', '');
        html = html.replaceAll('justify-content\\s*:\\s*space-between;', '');

        html = html.replace('class="row"', 'style="width:100%; overflow:hidden;"');
        html = html.replace('class="left"', 'style="width:60%; float:left;"');
        html = html.replace('class="right box"', 'style="width:38%; float:right; border:1px solid #000; padding:6px;"');
        html = html.replace('class="right"', 'style="width:38%; float:right;"');

        html = html.replaceAll('<table', '<table style="width:100%; border-collapse:collapse;"');
        html = html.replaceAll('<td', '<td style="border:1px solid #000; padding:4px;"');
        html = html.replaceAll('<th', '<th style="border:1px solid #000; padding:4px; background:#e9e6df;"');
        
        html = html.replaceAll(
            '(\\w+:\\d+)\\s*<span[^>]*>(.*?)</span><br>',
            '<div>$1</div><div>$2</div>'
        );
        
        return html;
    }
}