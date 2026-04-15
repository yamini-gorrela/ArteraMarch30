public with sharing class CMS1500Controller {

    public Boolean isSuccess { get; set; }
    public String errorMessage { get; set; }
    public Integer statusCode { get; set; } // ✅ To store HTTP status code for debugging

    private Id claimId;

    public CMS1500Controller(ApexPages.StandardController std) {
        this.claimId = std.getId();
    }

    public PageReference generate() {

        isSuccess = false;
        statusCode = null; // reset each time

        try {
            System.debug('===== CMS1500 PROCESS START =====');

            // Fetch Claim Record
            Claim__c claimRec = [
                SELECT Id, Name, Claim_Request__c
                FROM Claim__c
                WHERE Id = :claimId
                LIMIT 1
            ];

            System.debug('Claim Id: ' + claimRec.Id);

            if (String.isBlank(claimRec.Claim_Request__c)) {
                errorMessage = 'Claim Request is empty';
                System.debug('ERROR: Claim Request is empty');
                return null;
            }

            String body = claimRec.Claim_Request__c;

            // Remove '=' if present
            if (body.startsWith('=')) {
                body = body.substring(1);
            }

            System.debug('Request Body: ' + body);

            // HTTP Callout
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://integrations.eclouds.co:8445/api2/billing_doc?cms1500=true');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer AKaIGijJbu6GhaQuY55B3Ec4SD9hSVPBjOKRTDfZLladw4ZGRSWalHABJGhkaWfJ');
            req.setBody(body);

            System.debug('Sending HTTP Request...');

            HttpResponse res;
            try {
                res = http.send(req);
                statusCode = res.getStatusCode();
                System.debug('Response Status Code: ' + statusCode);
                System.debug('FULL Response Body: ' + res.getBody());
            } catch (CalloutException ce) {
                errorMessage = 'CalloutException: ' + ce.getMessage();
                System.debug('CALLOUT EXCEPTION: ' + ce.getMessage());
                return null;
            }

            if (statusCode == 200) {

                isSuccess = true;
                System.debug('✅ PDF Response Detected');

                Blob fileBlob = res.getBodyAsBlob();
                System.debug('Blob Size: ' + fileBlob.size());

                // Create File
                ContentVersion cv = new ContentVersion();
                cv.Title = 'CMS1500_' + claimRec.Name;
                cv.PathOnClient = 'CMS1500.pdf';
                cv.VersionData = fileBlob;
                insert cv;
                System.debug('ContentVersion Inserted: ' + cv.Id);

                // Get ContentDocumentId
                ContentVersion insertedCV = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :cv.Id
                    LIMIT 1
                ];

                // Link File to Claim
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = insertedCV.ContentDocumentId;
                cdl.LinkedEntityId = claimRec.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                insert cdl;

                System.debug('File Linked Successfully');

                // ✅ Add Success Message
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'CMS 1500 form is successfully generated'
                ));

                return null;

            } else {
                errorMessage = 'Error: ' + statusCode + ' - ' + res.getBody();
                System.debug('ERROR RESPONSE: ' + errorMessage);
            }

        } catch (Exception e) {
            errorMessage = 'Exception: ' + e.getMessage();
            System.debug('GENERAL EXCEPTION: ' + e.getMessage());
        }

        System.debug('===== CMS1500 PROCESS END FAILED =====');
        return null;
    }
}