@isTest
public class ClaimTriggerHandlerTest {

    @testSetup
    static void setupData() {
        // Insert dummy Payer or other required related objects if necessary
    }

    @isTest
    static void testGenerateClaimsRequest() {
         Account acc = new Account(Name='Test');
        insert acc;
        // Step 1: Insert a claim with required fields and Is_Ready_For_Submission__c = false
       claim__c claim = new claim__c(
            X16_Unable_to_work_from__c = system.today(),
            X16_Unable_to_work_to__c = system.today()+10,
            X18_Hospitalized_from__c = system.today(),
            X18_Hospitalized_To__c = system.today()+9,
            Patients_First_Name__c = 'Test',
            Patients_Last_Name__c = 'Claim',
            Patients_Birth_Date__c = system.today()-5678,
            Patient_Account__c = acc.Id,
            Patients_Address_Street__c = 'Test Street',
            Patients_Address_City__c = 'Test City',
            Patients_Address_State__c = 'Test State',
            Patients_Address_Zip_Code__c = '123456',
            Patients_relationship_to_the_insured__c = 'Test',
            Insureds_ID_Number__c = '126868889976',
            Insureds_First_Name__c = 'Test First',
            Insureds_Last_Name__c = 'Test Last',
            Sex__c = 'Male',
            Insureds_Address_Street__c = 'Test Street',
            Insureds_Address_City__c = 'Test City',
            Insureds_Address_State__c = 'Test State',
            Insureds_Address_Zip_Code__c = '56654777',
            Payer_Code__c = '7676766',
            Casualty__c = '26182',
           X31_Signature_of_Physician_or_Supplier__c = 'test'
        );
        insert claim;

        // Step 2: Add a child Claim Line (required for generateClaimsRequest to work properly)
        Claim_Line__c clLine = new Claim_Line__c(
            Claim__c = claim.Id,
            Date_from_of_Service__c = Date.today(),
            Date_to_of_Service__c = Date.today().addDays(2),
            CPT_HCPCS__c = '12345'
        );
        insert clLine;

        // Step 3: Update to trigger generateClaimsRequest
        claim.Is_Ready_For_Submission__c = true;

        Test.startTest();
        update claim;
        Test.stopTest();

        // Step 4: Verify Claim_Request__c is set
        Claim__c updated = [SELECT Claim_Request__c FROM Claim__c WHERE Id = :claim.Id];
        System.assertNotEquals(null, updated.Claim_Request__c, 'Claim_Request__c should be set');
    }

    @isTest
    static void testExtractReferenceId() {
         Account acc = new Account(Name='Test');
        insert acc;
        // Step 1: Create a valid JSON string for confirmation note
        String confirmationNote = '{"data":[{"message":{"body":{"claims":[{"referenceId":"REF-001"}]}}}]}';

        // Step 2: Insert a claim with initial null confirmation note
        claim__c claim = new claim__c(
            X16_Unable_to_work_from__c = system.today(),
            X16_Unable_to_work_to__c = system.today()+10,
            X18_Hospitalized_from__c = system.today(),
            X18_Hospitalized_To__c = system.today()+9,
            Patients_First_Name__c = 'Test',
            Patients_Last_Name__c = 'Claim',
            Patients_Birth_Date__c = system.today()-5678,
            Patient_Account__c = acc.Id,
            Patients_Address_Street__c = 'Test Street',
            Patients_Address_City__c = 'Test City',
            Patients_Address_State__c = 'Test State',
            Patients_Address_Zip_Code__c = '123456',
            Patients_relationship_to_the_insured__c = 'Test',
            Insureds_ID_Number__c = '126868889976',
            Insureds_First_Name__c = 'Test First',
            Insureds_Last_Name__c = 'Test Last',
            Sex__c = 'Male',
            Insureds_Address_Street__c = 'Test Street',
            Insureds_Address_City__c = 'Test City',
            Insureds_Address_State__c = 'Test State',
            Insureds_Address_Zip_Code__c = '56654777',
            Payer_Code__c = '7676766',
            Casualty__c = '26182',
            X31_Signature_of_Physician_or_Supplier__c = 'test'
        );
        insert claim;

        // Step 3: Update confirmation note to trigger extractReferenceId
        claim.Confirmation_Note_Long__c = confirmationNote;

        Test.startTest();
        update claim;
        Test.stopTest();

        // Step 4: Validate reference ID was extracted
        Claim__c updated = [SELECT Innovalan_Reference_Id__c FROM Claim__c WHERE Id = :claim.Id];
        System.assertEquals('REF-001', updated.Innovalan_Reference_Id__c, 'Reference ID should be populated');
    }
}