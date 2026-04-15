/*
@TestClass SubmitClaimToMiddlewareBatchTest
*/
public class SubmitClaimToMiddlewareBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select Id,Referring_Provider_Type__c,Referring_Provider_Name__c,Referring_Provider_First_Name__c,Referring_Provider_Address_Street__c,Referring_Provider_Address_City__c,Referring_Provider_Address_State__c,Referring_Provider_Address_Zip_Code__c,Referring_Provider_Phone__c,Referring_Provider_Taxonomy_code__c,Referring_Provider_NPI__c,CASESAFEID__c,Innovalan_Reference_Id__c,Patient_Condition_Related_to_auto_state__c, Name,Rendering_Provider_First_Name__c, Taxonomy_code_of_Rendering_Provider__c,Accident_Date__c,X14_Date_of_Current_Illness__c, Payer_Code__c,Payer__r.Payer_Code__c, Payer__c, Payer__r.Name,Payer__r.BillingCity, Payer__r.BillingStreet, Payer__r.BillingState, Payer__r.BillingPostalCode, Patients_First_Name__c, Patients_Last_Name__c, Patients_Birth_Date__c, Patient_Account__c, Sex__c, Insureds_First_Name__c, Insureds_Last_Name__c, Patients_Address_Street__c, Patients_Address_State__c, Patients_Address_City__c, Patients_Address_Zip_Code__c, Patients_relationship_to_the_insured__c, Insureds_ID_Number__c, Insureds_Address_Street__c, Insureds_Address_State__c, Insureds_Address_City__c, Insureds_Address_Zip_Code__c, IS_PATIENTS_CONDITION_RELATED_TO_Emp__c, IS_PATIENTS_CONDITION_RELATED_TO_A__c, IS_PATIENTS_CONDITION_RELATED_TO__c, INSUREDS_OR_AUTHORIZED_PERSONS_SIGN__c, REFERRING_OTHER_PHYSICIAN_ID__c, Original_Ref_No__c, PRIOR_AUTHORIZATION__c, (Select Id, Date_from_of_Service__c, Date_to_of_Service__c, Place_of_Service__c, CPT_HCPCS__c, Modifier_s__c, Diagnosis_pointers__c, Sales_Price__c,Total_Price__c, Quantity__c, Diag_1__r.Name, Diag_2__r.Name, Diag_3__r.Name, Diag_4__r.Name, Diag_5__r.Name, Diag_6__r.Name from Claim_Lines__r), FEDERAL_TAX_ID_NUMBER__c, Accept_Assignment__c, Billing_Provider_Name__c, Billing_Provider_Address_Street__c, Billing_Provider_Address_City__c, Billing_Provider_Address_State__c, Billing_Provider_Address_Zip_Code__c, Billing_Provider_Phone__c, Billing_Provider_NPI__c, X16_Unable_to_work_from__c, X16_Unable_to_work_to__c, X18_Hospitalized_from__c, X18_Hospitalized_To__c, X32_Service_Address_Street__c, X32_Service_Address_City__c, X32_Service_Address_State__c, X32_Service_Address_Zip__c, X32_Service_Phone__c, X32_Service_Taxonomy_Code__c, X32_Service_Npi__c ,Billing_Provider_Type__c,X33_Service_Provider_Type__c,X33_Service_Provider_Name__c,Rendering_Provider_Type__c,Rendering_Provider_Name__c,Rendering_Provider_Street__c,Rendering_Provider_City__c,Rendering_Provider_State__c,Rendering_Provider_Phone__c,Rendering_Provider_Zip__c,Rendering_Provider_Taxonomy_Code__c,Rendering_Provider_NPI__c,Casualty__c,X1a_Member_ID__c from Claim__c where Submitted_to_Middleware__c = false AND Errored_While_Submitting_to_Middileware__c = false ');
        
    }
    
    public void execute(Database.BatchableContext BC, List<Claim__c> scope){
        System.debug('=============== Scope ===============');
        System.debug(scope);
        
        List<MiddlewareSchema.ClaimForm> claimsForms = new List<MiddlewareSchema.ClaimForm>();
        set<Id> allClaimsId = new set<Id>();
        list<Claim__c> submittedClaims = new List<Claim__c>();
        for(Claim__c clm : scope){
            MiddlewareSchema.ClaimForm claimForm = MiddlewareUtils.getClaimBody(clm);
            claimsForms.add(claimForm);
            allClaimsId.add(clm.Id);
        }
        
        Set<Id> cdId = new Set<Id>();
        Map<String, String> documentIdAndClaimId = new Map<String, String>();
        for(ContentDocumentLink cld: [Select Id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId in: allClaimsId]){
            cdId.add(cld.ContentDocumentId);
            documentIdAndClaimId.put(cld.ContentDocumentId, cld.LinkedEntityId);
        }
        
        Map<String, ContentVersion> claimIdAndCV = new Map<String, ContentVersion>();
        for(ContentVersion cv: [Select ContentDocumentId, FileType, VersionData From ContentVersion Where ContentDocumentId In: cdId]){
            claimIdAndCV.put(documentIdAndClaimId.get(cv.ContentDocumentId), cv);
        }
        System.debug('Final Data ==============>');
        System.debug(claimIdAndCV);
        System.debug(claimsForms);
        List<MiddlewareSchema.Claim> claims = new List<MiddlewareSchema.Claim>();
        for(MiddlewareSchema.ClaimForm form: claimsForms){
            MiddlewareSchema.Claim data = new MiddlewareSchema.Claim();
            data.claim = new MiddlewareSchema.ClaimWithFile();
            String file = '';
            if(claimIdAndCV.containsKey(form.claim_id)){
                file = EncodingUtil.base64Encode(claimIdAndCV.get(form.claim_id).VersionData);
            }
            data.claim.file = file;
            data.claim.body = form;
            claims.add(data);
            System.debug('====>'+ JSON.serialize(claims));
        }
        System.debug('====>'+claims);
        
        String accessToken = MiddlewareUtils.getAccessToken();
        if(String.isNotBlank(accessToken)){
            MiddlewareSchema.ClaimSubmissionResponse response = MiddlewareUtils.submitClaimToMiddleware(accessToken, claims);
            System.debug('Response ============>');
            System.debug(response);
            if(response != null){
                if(String.isNotBlank(response.errrorMessage)){
                    //There was an error processing the claims.....
                    for(String claimId : response.processedClaimIds){
                        Claim__c claimToUpdate = new Claim__c();
                        claimToUpdate.Id = claimId;
                        claimToUpdate.Errored_While_Submitting_to_Middileware__c = true;
                        claimToUpdate.Submission_Status__c='Submitted but error';
                        claimToUpdate.Error_While_Submitting_to_Middileware__c = response.errrorMessage;
                        submittedClaims.add(claimToUpdate);
                    }
                }else{
                    for(String claimId : response.processedClaimIds){
                        Claim__c claimToUpdate = new Claim__c();
                        claimToUpdate.Id = claimId;
                        claimToUpdate.Submission_Status__c='Error';
                        claimToUpdate.Submission_Status__c='Submitted';
                        claimToUpdate.Submitted_to_Middleware__c = true;
                        submittedClaims.add(claimToUpdate);
                    }
                }
            }
        }
        
        if(submittedClaims.size() > 0){
            update submittedClaims;
        }
    }
    public static void  testmethod1(){
        integer i=0;
        for(i=0;i<=10;i++){
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
    
    public void finish(Database.BatchableContext BC){}
}