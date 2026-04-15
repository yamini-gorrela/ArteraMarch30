public class ClaimTriggerHandler {

    Public Static Boolean isRecursive = false;

    public static void generateClaimsRequest(List<Claim__c> claimList){

        List<claim__c> claimsTOupdate = new List <Claim__c> ();
        List<MiddlewareSchema.ClaimForm> claimsForms = new List<MiddlewareSchema.ClaimForm>();
        Map<Id,MiddlewareSchema.ClaimForm> claimMap = new Map<Id,MiddlewareSchema.ClaimForm>();
        set<Id> allClaimsId = new set<Id>();
        claimList=[select Id,CreatedDate, Claim_Indicator_Code__c,Name,Submitter_Id__c,Referring_Provider_Type__c,Referring_Provider_Name__c,Referring_Provider_First_Name__c,Referring_Provider_Address_Street__c,Referring_Provider_Address_City__c,Referring_Provider_Address_State__c,Referring_Provider_Address_Zip_Code__c,Referring_Provider_Phone__c,Referring_Provider_Taxonomy_code__c,Referring_Provider_NPI__c,Patient_Condition_Related_to_auto_state__c,Innovalan_Reference_Id__c,Casualty__c,CASESAFEID__c,Taxonomy_code_of_Rendering_Provider__c,Rendering_Provider_First_Name__c, Accident_Date__c,X14_Date_of_Current_Illness__c,X1a_Member_ID__c, Payer_Code__c,Payer__r.Payer_Code__c, Payer__c, Payer__r.Name,Payer__r.BillingCity, Payer__r.BillingStreet, Payer__r.BillingState,Payer__r.BillingStateCode, Payer__r.BillingPostalCode, Patients_First_Name__c, Patients_Last_Name__c, Patients_Birth_Date__c, Patient_Account__c, Sex__c, Insureds_First_Name__c, Insureds_Last_Name__c, Patients_Address_Street__c, Patients_Address_State__c, Patients_Address_City__c, Patients_Address_Zip_Code__c, Patients_relationship_to_the_insured__c, Insureds_ID_Number__c, Insureds_Address_Street__c, Insureds_Address_State__c, Insureds_Address_City__c, Insureds_Address_Zip_Code__c, IS_PATIENTS_CONDITION_RELATED_TO_Emp__c, IS_PATIENTS_CONDITION_RELATED_TO_A__c, IS_PATIENTS_CONDITION_RELATED_TO__c, INSUREDS_OR_AUTHORIZED_PERSONS_SIGN__c, REFERRING_OTHER_PHYSICIAN_ID__c, Original_Ref_No__c, PRIOR_AUTHORIZATION__c, (Select Id,Rendering_Provider_ID_TaxonomyCode__c,Claim__r.Rendering_Provider_Type__c,Claim__r.Rendering_Provider_Name__c,Rendering_Provider_ID_NPI__c, Date_from_of_Service__c, Date_to_of_Service__c, Place_of_Service__c, CPT_HCPCS__c, Modifier_s__c, Diagnosis_pointers__c, Sales_Price__c,Total_Price__c, Quantity__c, Diag_1__r.Name, Diag_2__r.Name, Diag_3__r.Name, Diag_4__r.Name, Diag_5__r.Name, Diag_6__r.Name from Claim_Lines__r), FEDERAL_TAX_ID_NUMBER__c, Accept_Assignment__c, Billing_Provider_Name__c, Billing_Provider_Address_Street__c, Billing_Provider_Address_City__c, Billing_Provider_Address_State__c, Billing_Provider_Address_Zip_Code__c, Billing_Provider_Phone__c, Billing_Provider_NPI__c, X16_Unable_to_work_from__c, X16_Unable_to_work_to__c, X18_Hospitalized_from__c, X18_Hospitalized_To__c, X32_Service_Address_Street__c, X32_Service_Address_City__c, X32_Service_Address_State__c, X32_Service_Address_Zip__c, X32_Service_Phone__c, X32_Service_Taxonomy_Code__c, X32_Service_Npi__c ,Billing_Provider_Type__c,X33_Service_Provider_Type__c,X33_Service_Provider_Name__c,Rendering_Provider_Type__c,Rendering_Provider_Name__c,Rendering_Provider_Street__c,Rendering_Provider_City__c,Rendering_Provider_State__c,Rendering_Provider_Phone__c,Rendering_Provider_Zip__c,Rendering_Provider_Taxonomy_Code__c,Rendering_Provider_NPI__c from Claim__c where Id=:claimList ];
        list<Claim__c> submittedClaims = new List<Claim__c>();
        for(Claim__c clm : claimList){
            MiddlewareSchema.ClaimForm claimForm = MiddlewareUtils.getClaimBody(clm);
            claimsForms.add(claimForm);
            claimMap.put(clm.Id,claimForm);
            allClaimsId.add(clm.Id);
        } 

     
        System.debug(claimsForms);

        List<MiddlewareSchema.Claim> claims = new List<MiddlewareSchema.Claim>();
        for(Id claimId: claimMap.keyset()){

            MiddlewareSchema.ClaimForm form = claimMap.get(claimId);
            MiddlewareSchema.Claim data = new MiddlewareSchema.Claim();
            data.claim = new MiddlewareSchema.ClaimWithFile();
            String file = '';
            data.claim.file = file;
            data.claim.body = form;
            claims.add(data);
            claimsTOupdate.add(new Claim__c(Id = claimId ,Claim_Request__c = (JSON.serialize(data))));
        }
   

       if(!claimsTOupdate.isEmpty()){
          isRecursive = true;        
          update claimsTOupdate;
       }
    }

    public static void extratctReferenceId(List<Claim__c> claimList){

        List<claim__c> claimsTOupdate = new List <Claim__c> ();

        for(Claim__c claim : claimList){
         
            ConfirmationSchema resp = ConfirmationSchema.parse(claim.Confirmation_Note_Long__c);
            if(!resp.data.isEmpty()){
                claimsTOupdate.add(new Claim__c (Id = claim.Id ,Innovalan_Reference_Id__c =  resp.data[0]?.message?.body?.claims[0].referenceId));
            }
        }

        if(!claimsTOupdate.isEmpty()){
            update claimsTOupdate;
        }


    }
}