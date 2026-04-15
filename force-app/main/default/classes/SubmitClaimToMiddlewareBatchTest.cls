@isTest
public class SubmitClaimToMiddlewareBatchTest {
    @testSetup static void methodName() {
        String invalidNumbers = '[^0-9]';
        Account acc = new Account(Name='Test');
        insert acc;
        claim__c claim = new claim__c(
            Errored_While_Submitting_to_Middileware__c = false,
            Submitted_to_Middleware__c = false,
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
            Payer_Code__c = '7676766'
        );
        insert claim;
        
        Claim_Line__c claimLine = new Claim_Line__c(claim__c = claim.Id);
        insert claimLine;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=claim.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
    }
    @isTest
    public static void SubmitClaimToMiddlewareBatchTest1(){
        Claim__c claim = [Select Id,X16_Unable_to_work_from__c,Accept_Assignment__c,(Select Id, Diag_1__c,Diag_2__c,Diag_3__c,Diag_4__c,Diag_5__c,Diag_6__c,
                                                                                     Diagnosis_pointers__c,Modifier_s__c,Date_from_of_Service__c,Date_to_of_Service__c,Place_of_Service__c,CPT_HCPCS__c,Sales_Price__c,Quantity__c from
                                                                                     Claim_Lines__r),
                          X16_Unable_to_work_to__c,PRIOR_AUTHORIZATION__c,FEDERAL_TAX_ID_NUMBER__c,
                          X18_Hospitalized_from__c ,IS_PATIENTS_CONDITION_RELATED_TO__c,INSUREDS_OR_AUTHORIZED_PERSONS_SIGN__c,REFERRING_OTHER_PHYSICIAN_ID__c,Original_Ref_No__c,
                          X18_Hospitalized_To__c,Payer_Code__c,Payer__r.Name,IS_PATIENTS_CONDITION_RELATED_TO_Emp__c,IS_PATIENTS_CONDITION_RELATED_TO_A__c,
                          Patients_First_Name__c,Rendering_Provider_Phone__c,Rendering_Provider_Taxonomy_Code__c,Rendering_Provider_NPI__c,
                          Patients_Last_Name__c ,Rendering_Provider_City__c,Rendering_Provider_State__c,Rendering_Provider_Zip__c,
                          Patients_Birth_Date__c,Rendering_Provider_Type__c,Rendering_Provider_Name__c,Rendering_Provider_Street__c,
                          Patient_Account__c,X32_Service_Phone__c,X32_Service_Taxonomy_Code__c,X32_Service_Npi__c,
                          Patients_Address_Street__c,X32_Service_Address_State__c,X32_Service_Address_Zip__c,
                          Patients_Address_City__c,X32_Service_Address_Street__c,X32_Service_Address_City__c,
                          Patients_Address_State__c,X33_Service_Provider_Type__c,X33_Service_Provider_Name__c,
                          Patients_Address_Zip_Code__c,Taxonomy_code_of_Rendering_Provider__c,Billing_Provider_NPI__c,
                          Patients_relationship_to_the_insured__c,Billing_Provider_Address_Zip_Code__c,Billing_Provider_Phone__c,
                          Insureds_ID_Number__c ,Billing_Provider_Address_City__c,Billing_Provider_Address_State__c,
                          Insureds_First_Name__c,Billing_Provider_Type__c,Billing_Provider_Name__c,Billing_Provider_Address_Street__c,
                          Insureds_Last_Name__c,Sex__c,Insureds_Address_Street__c,Insureds_Address_City__c,Insureds_Address_State__c,Casualty__c,
                          Insureds_Address_Zip_Code__c,Referring_Provider_Type__c,Referring_Provider_Name__c,Referring_Provider_First_Name__c,Referring_Provider_Address_Street__c,Referring_Provider_Address_City__c,Referring_Provider_Address_State__c,Referring_Provider_Address_Zip_Code__c,Referring_Provider_Phone__c,Referring_Provider_Taxonomy_code__c,Referring_Provider_NPI__c from claim__c];
        
        Test.startTest();
        SubmitClaimToMiddlewareBatch.testmethod1();
        MockHttpResponseGenerator.respondWithError = true;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        try{
            SubmitClaimToMiddlewareBatch obj = new SubmitClaimToMiddlewareBatch();
            DataBase.executeBatch(obj); 
        }catch(Exception Ex){
            
        }
        
        
        Test.stopTest();
    }
    @isTest
    public static void SubmitClaimToMiddlewareBatchTest2(){
        Claim__c claim = [Select Id,X16_Unable_to_work_from__c,Accept_Assignment__c,(Select Id, Diag_1__c,Diag_2__c,Diag_3__c,Diag_4__c,Diag_5__c,Diag_6__c,
                                                                                     Diagnosis_pointers__c,Modifier_s__c,Date_from_of_Service__c,Date_to_of_Service__c,Place_of_Service__c,CPT_HCPCS__c,Sales_Price__c,Quantity__c from
                                                                                     Claim_Lines__r),
                          X16_Unable_to_work_to__c,PRIOR_AUTHORIZATION__c,FEDERAL_TAX_ID_NUMBER__c,
                          X18_Hospitalized_from__c ,IS_PATIENTS_CONDITION_RELATED_TO__c,INSUREDS_OR_AUTHORIZED_PERSONS_SIGN__c,REFERRING_OTHER_PHYSICIAN_ID__c,Original_Ref_No__c,
                          X18_Hospitalized_To__c,Payer_Code__c,Payer__r.Name,IS_PATIENTS_CONDITION_RELATED_TO_Emp__c,IS_PATIENTS_CONDITION_RELATED_TO_A__c,
                          Patients_First_Name__c,Rendering_Provider_Phone__c,Rendering_Provider_Taxonomy_Code__c,Rendering_Provider_NPI__c,
                          Patients_Last_Name__c ,Rendering_Provider_City__c,Rendering_Provider_State__c,Rendering_Provider_Zip__c,
                          Patients_Birth_Date__c,Rendering_Provider_Type__c,Rendering_Provider_Name__c,Rendering_Provider_Street__c,
                          Patient_Account__c,X32_Service_Phone__c,X32_Service_Taxonomy_Code__c,X32_Service_Npi__c,
                          Patients_Address_Street__c,X32_Service_Address_State__c,X32_Service_Address_Zip__c,
                          Patients_Address_City__c,X32_Service_Address_Street__c,X32_Service_Address_City__c,
                          Patients_Address_State__c,X33_Service_Provider_Type__c,X33_Service_Provider_Name__c,
                          Patients_Address_Zip_Code__c,Taxonomy_code_of_Rendering_Provider__c,Billing_Provider_NPI__c,
                          Patients_relationship_to_the_insured__c,Billing_Provider_Address_Zip_Code__c,Billing_Provider_Phone__c,
                          Insureds_ID_Number__c ,Billing_Provider_Address_City__c,Billing_Provider_Address_State__c,
                          Insureds_First_Name__c,Billing_Provider_Type__c,Billing_Provider_Name__c,Billing_Provider_Address_Street__c,
                          Insureds_Last_Name__c,Sex__c,Insureds_Address_Street__c,Insureds_Address_City__c,Insureds_Address_State__c,Casualty__c,
                          Insureds_Address_Zip_Code__c,Referring_Provider_Type__c,Referring_Provider_Name__c,Referring_Provider_First_Name__c,Referring_Provider_Address_Street__c,Referring_Provider_Address_City__c,Referring_Provider_Address_State__c,Referring_Provider_Address_Zip_Code__c,Referring_Provider_Phone__c,Referring_Provider_Taxonomy_code__c,Referring_Provider_NPI__c from claim__c];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SubmitClaimToMiddlewareBatch.testmethod1();
        try{
            SubmitClaimToMiddlewareBatch obj = new SubmitClaimToMiddlewareBatch();
            DataBase.executeBatch(obj); 
        }catch(Exception Ex){
            
        }
        
        Test.stopTest();
    }
}