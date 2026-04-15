@isTest
public class MiddlewareUtilsTest {
    @testSetup static void methodName() {
        String invalidNumbers = '[^0-9]';
        Account acc = new Account(Name='Test');
        insert acc;
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
            X1a_Member_ID__c='Test',
            X19_Additional_Claim_Information_NUCC__c = 'test',
            X14_Date_of_Current_Illness__c = system.today(),
            DIAGNOSIS_OR_NATURE_OF_ILLNESS_OR_INJ__c = 'test injury',
            X15_Other_Date__c =  system.today(),
            X31_Signature_of_Physician_or_Supplier__c = 'test physcisan'
        );
        insert claim;
        
        Claim_Line__c claimLine = new Claim_Line__c(claim__c = claim.Id);
        insert claimLine;
        List<MiddlewareSchema.Services> lstServices= new List<MiddlewareSchema.Services>();
        MiddlewareSchema.Services oServices= new MiddlewareSchema.Services();
        oServices.service_id = claimLine.Id;
        oServices.Date_from_of_service = claimLine.Date_from_of_Service__c;
        oServices.Date_to_of_service = claimLine.Date_to_of_Service__c;
        oServices.Place_of_service = claimLine.Place_of_Service__c;
        oServices.cptb_hcpcs = claimLine.CPT_HCPCS__c;
        oServices.Modifiers = claimLine.Modifier_s__c;
        oServices.Note = claimLine.Diagnosis_pointers__c;
        //oServices.Diagnosis = Diagnosis;
        oServices.Charges = claimLine.Total_Price__c;
        oServices.measure = 'UN';
        oServices.Units = claimLine.Quantity__c;
        lstServices.add(oServices);
        
        MiddlewareSchema.Patient oPatient = new MiddlewareSchema.Patient();
        oPatient.first_name = claim.Patients_First_Name__c;
        oPatient.last_name = claim.Patients_Last_Name__c;
        oPatient.birth_date = claim.Patients_Birth_Date__c;
        oPatient.account = claim.Patient_Account__c;
        oPatient.Sex = claim.Sex__c;
        oPatient.address_street = claim.Patients_Address_Street__c;
        oPatient.address_city = claim.Patients_Address_City__c;
        oPatient.address_state = claim.Patients_Address_State__c;
        oPatient.address_zip_code = claim.Patients_Address_Zip_Code__c;
        oPatient.relationship_to_the_insured= claim.Patients_relationship_to_the_insured__c;
        
        MiddlewareSchema.Subscriber oSubscriber = new MiddlewareSchema.Subscriber();
        oSubscriber.id_number = claim.Insureds_ID_Number__c;
        //oSubscriber.polis_number = '12345';
        oSubscriber.payer_responsibility = 'P';
        oSubscriber.insurance_plan_type = 'BL';
        oSubscriber.insurance_program = 'Silver';
        oSubscriber.first_name = claim.Insureds_First_Name__c;
        oSubscriber.last_name = claim.Insureds_Last_Name__c;
        oSubscriber.birth_date = claim.Patients_Birth_Date__c;
        oSubscriber.Sex = claim.Sex__c;
        oSubscriber.address_street = claim.Insureds_Address_Street__c;
        oSubscriber.address_city = claim.Insureds_Address_City__c;
        oSubscriber.address_state = claim.Insureds_Address_State__c;
        oSubscriber.address_zip_code = claim.Insureds_Address_Zip_Code__c;
        
		MiddlewareSchema.ClaimDates oClaimdates= new MiddlewareSchema.ClaimDates();
        oClaimdates.first_symptoms = System.Today(); //Not Mapped
        oClaimdates.accident = System.Today(); //Not Mapped
        oClaimdates.last_seen_by_doctor = System.Today(); //Not Mapped
        oClaimdates.first_treatment = System.Today(); //Not Mapped
        oClaimdates.unable_to_work_from = claim.X16_Unable_to_work_from__c;
        oClaimdates.unable_to_work_to = claim.X16_Unable_to_work_to__c;
        oClaimdates.hospitalized_from = claim.X18_Hospitalized_from__c;
        oClaimdates.hospitalized_to = claim.X18_Hospitalized_To__c;
        
        MiddlewareSchema.Provider oBillingProvider= new MiddlewareSchema.Provider();
        oBillingProvider.type=claim.Billing_Provider_Type__c;
        oBillingProvider.name=claim.Billing_Provider_Name__c;
        oBillingProvider.address_street=claim.Billing_Provider_Address_Street__c;
        oBillingProvider.address_city=claim.Billing_Provider_Address_City__c;
        oBillingProvider.address_state=claim.Billing_Provider_Address_State__c;
        oBillingProvider.address_zip_code=claim.Billing_Provider_Address_Zip_Code__c !=null ? String.Valueof(claim.Billing_Provider_Address_Zip_Code__c.replaceAll( invalidNumbers,'')) : null;
        oBillingProvider.phone=claim.Billing_Provider_Phone__c;
        oBillingProvider.taxonomy_code=claim.Taxonomy_code_of_Rendering_Provider__c;//Not Mapped
        oBillingProvider.npi=claim.Billing_Provider_NPI__c != null ? String.Valueof(claim.Billing_Provider_NPI__c.replaceAll( invalidNumbers,'')) : null;

        MiddlewareSchema.Provider oServiceProvider= new MiddlewareSchema.Provider();
        oServiceProvider.type=claim.X33_Service_Provider_Type__c;//Not Mapped
        oServiceProvider.name=claim.X33_Service_Provider_Name__c;//Not Mapped
        oServiceProvider.address_street=claim.X32_Service_Address_Street__c;
        oServiceProvider.address_city=claim.X32_Service_Address_City__c;
        oServiceProvider.address_state=claim.X32_Service_Address_State__c;
        oServiceProvider.address_zip_code=claim.X32_Service_Address_Zip__c != null ? String.Valueof(claim.X32_Service_Address_Zip__c.replaceAll( invalidNumbers,'')) :null;
        oServiceProvider.phone=claim.X32_Service_Phone__c;
        oServiceProvider.taxonomy_code= claim.X32_Service_Taxonomy_Code__c !=null ? String.Valueof(claim.X32_Service_Taxonomy_Code__c.replaceAll( invalidNumbers,'')): null;
        oServiceProvider.npi=claim.X32_Service_Npi__c != null ? String.Valueof(claim.X32_Service_Npi__c): null;


        MiddlewareSchema.Provider oRenderingProvider= new MiddlewareSchema.Provider();
        oRenderingProvider.type=claim.Rendering_Provider_Type__c;//Not Mapped
        oRenderingProvider.name=claim.Rendering_Provider_Name__c;//Not Mapped
        oRenderingProvider.address_street=claim.Rendering_Provider_Street__c;
        oRenderingProvider.address_city=claim.Rendering_Provider_City__c;
        oRenderingProvider.address_state=claim.Rendering_Provider_State__c;
        oRenderingProvider.address_zip_code=claim.Rendering_Provider_Zip__c != null ? String.Valueof(claim.Rendering_Provider_Zip__c.replaceAll( invalidNumbers,'')) :null;
        oRenderingProvider.phone=claim.Rendering_Provider_Phone__c;
        oRenderingProvider.taxonomy_code= claim.Rendering_Provider_Taxonomy_Code__c !=null ? String.Valueof(claim.Rendering_Provider_Taxonomy_Code__c.replaceAll( invalidNumbers,'')): null;
        oRenderingProvider.npi=claim.Rendering_Provider_NPI__c != null ? String.Valueof(claim.Rendering_Provider_NPI__c): null;

        MiddlewareSchema.Payer oPayer= new MiddlewareSchema.Payer();
        oPayer.code='claim.Payer__r.Payer_Code__c';
        oPayer.name='test';
        oPayer.address_street='Test';
        oPayer.address_city='Test';
        oPayer.address_state='Test';
        oPayer.address_zip_code='Test';



		MiddlewareSchema.ClaimForm oClaims= new MiddlewareSchema.ClaimForm();
        oClaims.Claim_id='Test';
        oClaims.claim_dates=oClaimdates;
        oClaims.payer=oPayer;
        oClaims.patient=oPatient;
        oClaims.subscriber=oSubscriber;

        oClaims.Is_patient_condition_related_to_emp=true;
        oClaims.Is_patient_condition_related_to_auto=true;
        oClaims.Is_patient_condition_related_to_other=true;
        oClaims.Insured_or_authorized_persons_sign=true;

        //oClaims.Referring_other_physician_id=claim.REFERRING_OTHER_PHYSICIAN_ID__c;
        oClaims.Original_ref_number=claim.Original_Ref_No__c;
        oClaims.Prior_authorization=claim.PRIOR_AUTHORIZATION__c;
        oClaims.Services=lstServices;
        oClaims.Federal_tax_id_number= claim.FEDERAL_TAX_ID_NUMBER__c !=null ? Integer.Valueof(claim.FEDERAL_TAX_ID_NUMBER__c.replaceAll( invalidNumbers,'')):null;
        oClaims.Accept_assignment=claim.Accept_Assignment__c;
        oClaims.billing_provider=oBillingProvider;
        oClaims.service_provider=oServiceProvider;
        oClaims.rendering_provider=oRenderingProvider;

	}
    @isTest
    public static void getCredsTest(){
        Test.startTest();
        MiddlewareUtils.getCreds();
        Test.stopTest();
    }
    @isTest
    public static void getAccessTokenTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        MiddlewareUtils.getAccessToken();
        Test.stopTest();
    }
    @isTest
    public static void getClaimConfirmationsTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String accessToken = MiddlewareUtils.getAccessToken();
        MiddlewareUtils.getClaimConfirmations(accessToken);
        Test.stopTest();
    }
    @isTest
    public static void getClaimValidationsTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String accessToken = MiddlewareUtils.getAccessToken();
        MiddlewareUtils.getClaimValidations(accessToken);
        Test.stopTest();
    }
    @isTest
    public static void getClaimBodyTest(){
        Claim__c claim = [Select Id,CreatedDate,Submitter_Id__c,Referring_Provider_Type__c,Referring_Provider_Name__c,Referring_Provider_First_Name__c,Referring_Provider_Address_Street__c,Referring_Provider_Address_City__c,Referring_Provider_Address_State__c,Referring_Provider_Address_Zip_Code__c,Referring_Provider_Phone__c,Referring_Provider_Taxonomy_code__c,Referring_Provider_NPI__c,CASESAFEID__c,Name,Patient_Condition_Related_to_auto_state__c,
        Innovalan_Reference_Id__c,Casualty__c,X16_Unable_to_work_from__c,Accept_Assignment__c,(Select Id,Claim__r.Rendering_Provider_Type__c,Claim__r.Rendering_Provider_Name__c,Rendering_Provider_ID_TaxonomyCode__c, Rendering_Provider_ID_NPI__c,Diag_1__c,Diag_2__c,Diag_3__c,Diag_4__c,Diag_5__c,Diag_6__c,
            Diagnosis_pointers__c,Modifier_s__c,Date_from_of_Service__c,Date_to_of_Service__c,Place_of_Service__c,CPT_HCPCS__c,Sales_Price__c,Total_Price__c,Quantity__c, Diag_1__r.Name, Diag_2__r.Name, Diag_3__r.Name, Diag_4__r.Name, Diag_5__r.Name, Diag_6__r.Name from
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
            Insureds_Last_Name__c,Sex__c,Insureds_Address_Street__c,Insureds_Address_City__c,Insureds_Address_State__c,
            Accident_Date__c,Claim__c.X14_Date_of_Current_Illness__c,Rendering_Provider_First_Name__c,X1a_Member_ID__c,
            Insureds_Address_Zip_Code__c,X19_Additional_Claim_Information_NUCC__c from claim__c Limit 1];
        Test.startTest();
        MiddlewareUtils.getClaimBody(claim);
        Test.stopTest();
    }
    @isTest
    public static void submitClaimToMiddlewareTest(){
        List<Claim__c> claims = [Select Id,CreatedDate,Submitter_Id__c,Name,Referring_Provider_Type__c,Referring_Provider_Name__c,Referring_Provider_First_Name__c,Referring_Provider_Address_Street__c,Referring_Provider_Address_City__c,Referring_Provider_Address_State__c,Referring_Provider_Address_Zip_Code__c,Referring_Provider_Phone__c,Referring_Provider_Taxonomy_code__c,Referring_Provider_NPI__c,CASESAFEID__c,Patient_Condition_Related_to_auto_state__c,
        Innovalan_Reference_Id__c,Casualty__c,X16_Unable_to_work_from__c,Accept_Assignment__c,(Select Id, Claim__r.Rendering_Provider_Type__c,Claim__r.Rendering_Provider_Name__c,Rendering_Provider_ID_TaxonomyCode__c,Rendering_Provider_ID_NPI__c,Diag_1__c,Diag_2__c,Diag_3__c,Diag_4__c,Diag_5__c,Diag_6__c,
            Diagnosis_pointers__c,Modifier_s__c,Date_from_of_Service__c,Date_to_of_Service__c,Place_of_Service__c,CPT_HCPCS__c,Sales_Price__c,Total_Price__c,Quantity__c,  Diag_1__r.Name, Diag_2__r.Name, Diag_3__r.Name, Diag_4__r.Name, Diag_5__r.Name, Diag_6__r.Name from
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
            Insureds_Last_Name__c,Sex__c,Insureds_Address_Street__c,Insureds_Address_City__c,Insureds_Address_State__c,
            Accident_Date__c,Claim__c.X14_Date_of_Current_Illness__c,X1a_Member_ID__c,
            Insureds_Address_Zip_Code__c,Rendering_Provider_First_Name__c,X19_Additional_Claim_Information_NUCC__c from claim__c];

            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            //content.LinkedEntityId=sub.id;
            content.origin = 'H';
            insert content;
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=claims[0].id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            
            
            insert contentlink;
            update new Claim__c(Id =claims[0].id ,Is_Ready_For_Submission__c = true);
        List<MiddlewareSchema.Claim> claims1 = new List<MiddlewareSchema.Claim>();
        List<MiddlewareSchema.ClaimForm> claimForms = new List<MiddlewareSchema.ClaimForm>();

       

        
        for(Claim__c clm : claims){
            MiddlewareSchema.ClaimForm claimForm = MiddlewareUtils.getClaimBody(clm);
            claimForms.add(claimForm);
        }

        for(MiddlewareSchema.ClaimForm form: claimForms){
            MiddlewareSchema.Claim data = new MiddlewareSchema.Claim();
            data.claim = new MiddlewareSchema.ClaimWithFile();
            String file = '';
           
            data.claim.file = file;
            data.claim.body = form;
            claims1.add(data);
            System.debug('====>'+ JSON.serialize(claims));
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String accessToken = MiddlewareUtils.getAccessToken();
        MiddlewareSchema.ClaimSubmissionResponse testrep= MiddlewareUtils.submitClaimToMiddleware(accessToken, claims1);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // SubmitClaimToMiddlewareBatch obj = new SubmitClaimToMiddlewareBatch();
        // DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
}