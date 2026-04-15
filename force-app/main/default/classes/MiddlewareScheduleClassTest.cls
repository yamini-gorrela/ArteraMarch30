@IsTest
public class MiddlewareScheduleClassTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Claim records
        Id patientId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        AcctSeed__Accounting_Variable__c accvar = new AcctSeed__Accounting_Variable__c();
        accvar.Name = 'test1';
        accvar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accvar;
        
        
        Account testPatient = new Account();
        testPatient.LastName = 'test';
        testPatient.Accounting_Variable__c = accvar.Id;
        testPatient.RecordTypeId =patientId;
        insert testPatient;
        
        
        
        // Create a single Claim__c record
        Claim__c testClaim = new Claim__c();
        testClaim.Patient__c = testPatient.Id;
        insert testClaim;
        
        // Create multiple Claim__c records
        List<Claim__c> testClaims = new List<Claim__c>();
        for (Integer i = 0; i < 3; i++) {
            testClaims.add(new Claim__c(
                Patient__c = testPatient.Id // Use variable, NOT a string
                // Claim_Number__c = 'CLMINV-' + String.valueOf(i).padLeft(18, '0') // Fix number formatting
            ));
        }
        insert testClaims;
        
        
        // Create test CodeSet records
        List<CodeSet> testCodeSets = new List<CodeSet>();
        testCodeSets.add(new CodeSet(Code = 'RARC1',Name='test'));
        testCodeSets.add(new CodeSet(Code = 'RARC2',Name='test'));
        testCodeSets.add(new CodeSet(Code = 'ADJ1',Name='test'));
        insert testCodeSets;
    }
    
    
    public static String createTestJSONData() {
        // Create the full JSON structure
        String jsonData = '[{' +
            '"name": "Test Validation",' +
            '"data": [' +
            '{' +
            '"file": "testfile1.json",' +
            '"claim_id": "001000000000001AAA",' +
            '"message": {' +
            '"status": "Approved",' +
            '"items": [' +
            '{' +
            '"name": "Test Item 1",' +
            '"first_name": "John",' +
            '"identification_code": "ID123",' +
            '"entity": "Entity1",' +
            '"type": "Type1",' +
            '"code_qualifier": "Qualifier1",' +
            '"trace_number": "12345",' +
            '"service_date_from": "2023-01-01",' +
            '"service_date_to": "2023-01-31",' +
            '"payment": {' +
            '"type": "Payment Type 1",' +
            '"qty": "1",' +
            '"amount": "100.00",' +
            '"amount_type": "Amount Type 1"' +
            '},' +
            '"references": [' +
            '{' +
            '"type": "Reference Type 1",' +
            '"number": "REF001"' +
            '}' +
            '],' +
            '"details": [' +
            '{' +
            '"category_code": "CAT001",' +
            '"status_code": "STAT001",' +
            '"date": "2023-01-15",' +
            '"amount": "50.00",' +
            '"note": "Test detail note"' +
            '}' +
            ']' +
            '},' +
            '{' +
            '"name": "Test Item 2",' +
            '"first_name": "Jane",' +
            '"identification_code": "ID456",' +
            '"entity": "Entity2",' +
            '"type": "Type2",' +
            '"code_qualifier": "Qualifier2",' +
            '"trace_number": "67890",' +
            '"service_date_from": "2023-02-01",' +
            '"service_date_to": "2023-02-28",' +
            '"payment": {' +
            '"type": "Payment Type 2",' +
            '"qty": "2",' +
            '"amount": "200.00",' +
            '"amount_type": "Amount Type 2"' +
            '}' +
            // No references or details for second item
            '}' +
            ']' +
            '}' +
            '},' +
            '{' +
            '"file": "testfile2.json",' +
            '"claim_id": "001000000000002AAA",' +
            '"message": {' +
            '"status": "Rejected"' +
            // No items for second validation to test null handling
            '}' +
            '}' +
            ']' +
            '}]';
        
        return jsonData;
    } 
    @isTest
    public static void scheduleMeTest(){
        Claim__c ClaimRecord = [Select Id From Claim__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MiddlewareMockResponse(ClaimRecord.Id));
        String sch = '0 0 23 * * ?'; 
        Test.startTest();
        // MiddlewareScheduleClass sh1 = new MiddlewareScheduleClass();
        
        // system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
    
    
    @IsTest
    static void testExecute() {
        Claim__c ClaimRecord = [Select Id From Claim__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MiddlewareMockResponse(ClaimRecord.Id));
        
        Test.startTest();
        MiddlewareScheduleClass scheduler = new MiddlewareScheduleClass();
        MiddlewareScheduleClass.getUniqueReferenceId();
        MiddlewareScheduleClass.processConfirmations('test');
        MiddlewareScheduleClass.correctCapitalizedId('test');
        Date myDate = Date.today();  
        String dateString = String.valueOf(myDate).replace('-', '');  
        
        Date parsedDate = MiddlewareScheduleClass.parseStringToDate(dateString);
        
        
        //  scheduler.execute(null);
        //System.schedule('Immediate Test Job', '0 0 ? * * *', scheduler);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testExecuteTwo() {
        Claim__c ClaimRecord = [Select Id From Claim__c limit 1];
        Test.setMock(HttpCalloutMock.class, new MiddlewareMockResponse(ClaimRecord.Id));
        
        Test.startTest();
        String jsonData = createTestJSONData();
        List<ValidationSchema> data = (List<ValidationSchema>)JSON.deserialize(jsonData,List<ValidationSchema>.class);
        MiddlewareScheduleClass.validationData res = new MiddlewareScheduleClass.validationData();
        MiddlewareScheduleClass.processValidations('test');
        
        MiddlewareScheduleClass.processValidationLines('277',data[0].data,res);
        MiddlewareScheduleClass.scheduleMe();
        Test.stopTest();
    }

}