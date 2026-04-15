@isTest
private class CaseExtractHandlerTest {

    private static Case makeCase(String subject) {
        return new Case(
            Subject = subject,
            Origin = 'Phone',
            Status = 'New'
        );
    }

    @isTest static void testExtractFound() {
        Case c = makeCase('Order ref 000123 arrived');
        insert c;

        Case insertedCase = [
            SELECT Id, Subject, Extrac__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals('000123', insertedCase.Extrac__c);
    }

    @isTest static void testNoMatchClears() {
        Case c = makeCase('No digits here');
        insert c;

        Case fetched = [SELECT Id, Extrac__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(null, fetched.Extrac__c);
    }

    @isTest static void testUpdateChangesNumber() {
        Case c = makeCase('Has 111111');
        insert c;

        c.Subject = 'Updated to 222222';
        update c;

        Case fetched = [SELECT Extrac__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('222222', fetched.Extrac__c);
    }

    // --- NEW TESTS FOR FAX EXTRACTION ---

    @isTest static void testFaxExtractOnInsert() {
        Case c = makeCase('A fax has arrived from: \'(940) 218-1207\'');
        insert c;

        Case fetched = [SELECT Extracted_Fax__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('9402181207', fetched.Extracted_Fax__c,
            'Should extract digits-only fax number');
    }

    @isTest static void testFaxClearsWhenNotMatching() {
        Case c = makeCase('A fax has arrived from: (940) 218-1207'); // no quotes, should not match
        insert c;

        Case fetched = [SELECT Extracted_Fax__c FROM Case WHERE Id = :c.Id];
        System.assertEquals(null, fetched.Extracted_Fax__c,
            'Should be null if subject does not match exact format');
    }

    @isTest static void testFaxUpdatesWhenSubjectChanges() {
        Case c = makeCase('A fax has arrived from: \'(111) 111-1111\'');
        insert c;

        c.Subject = 'A fax has arrived from: \'(222) 222-2222\'';
        update c;

        Case fetched = [SELECT Extracted_Fax__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('2222222222', fetched.Extracted_Fax__c,
            'Should update extracted fax when subject changes');
    }
}