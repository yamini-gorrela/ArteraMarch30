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
            } else {
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint('https://integrations.eclouds.co:8445/api2/billing_doc?payment=true');
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer XXXXX');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(rawData);
                
                HttpResponse res = http.send(req);
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
        
        html = html.replaceAll('<style[\\s\\S]*?</style>', '');
        
        html = html.replaceAll('<!DOCTYPE[^>]*>', '');
        html = html.replaceAll('<html[^>]*>', '');
        html = html.replaceAll('</html>', '');
        html = html.replaceAll('<head>[\\s\\S]*?</head>', '');
        html = html.replaceAll('<body[^>]*>', '');
        html = html.replaceAll('</body>', '');
        
        html = html.replace('<div class="row">', '<table width="100%"><tr>');
        html = html.replace('<div class="left">', '<td width="60%" valign="top">');
        html = html.replace('<div class="right box">', '<td width="40%" valign="top"><table border="1" width="100%"><tr><td>');
        html = html.replace('<div class="right">', '<td width="40%" valign="top">');
        html = html.replace('</div></div>', '</td></tr></table>');
        html = html.replace('</div>', '</td>');
        
        html = html.replace('<div class="adjustment-box">', '<div>');
        
        html = html.replaceAll('margin-left\\s*:\\s*auto;', '');
        
        html = html.replaceAll(
            '<table',
            '<table style="width:100%; border-collapse:collapse; page-break-inside:avoid;"'
        );
        
        html = html.replaceAll(
            '<td',
            '<td style="border:1px solid black; padding:4px;"'
        );
        
        html = html.replaceAll(
            '<th',
            '<th style="border:1px solid black; padding:4px; background:#e9e6df;"'
        );
        
        html = html.replaceAll(
            '(\\w+:\\d+)\\s*<span[^>]*>(.*?)</span><br>',
            '<div>$1</div><div style="text-align:right;">$2</div>'
        );
        
        html = html.replaceAll('display\\s*:\\s*flex;', '');
        html = html.replaceAll('justify-content\\s*:\\s*space-between;', '');
        html = html.replaceAll('float\\s*:\\s*right;', '');
        
        return html;
    }
}