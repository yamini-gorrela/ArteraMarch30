/*
@TestClass MiddlewareUtilsTest
*/
public class MiddlewareUtils extends MiddlewareSchema{
    Public Static Billing_Middleware_Setting__mdt creds = getCreds();
    
    Public Static Billing_Middleware_Setting__mdt getCreds(){
        if(creds == null){
            return [Select id, Endpoint__c, Ehr_AccountId__c, Ehr_Channel__c, Ehr_ClientId__c, Ehr_ClientSecret__c, Ehr_Password__c, Ehr_Username__c, Password__c, Username__c from Billing_Middleware_Setting__mdt where DeveloperName = 'Middleware_Credentials' limit 1];
        }else{
            return creds;
        }
    }
    
    Public Static String getAccessToken(){
        if(creds != null){ 
            AuthenticationBody body = new AuthenticationBody();
            body.ehr_username = creds.Ehr_Username__c;
            body.ehr_password = creds.Ehr_Password__c;
            body.ehr_accountId = creds.Ehr_AccountId__c;
            body.ehr_channel = creds.Ehr_Channel__c;
            body.ehr_clientId = creds.Ehr_ClientId__c;
            body.ehr_clientSecret = creds.Ehr_ClientSecret__c;
            
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(creds.Endpoint__c+'/api/v1/oauth');
            req.setMethod('POST');
            req.setTimeout(120000); 
            
            
            Blob headerValue = Blob.valueOf(creds.Username__c+':'+creds.Password__c);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');   
            req.setBody(JSON.serialize(body)); 
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                AuthResponse resp = (AuthResponse)JSON.deserialize(res.getBody(), AuthResponse.Class);
                return resp.access_token;
            }
        }
        return null;
    }
    
    
    Public Static ClaimSubmissionResponse submitClaimToMiddleware(String accessToken, List<Claim> claimForms){
        if(claimForms.size() > 0){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(creds.Endpoint__c+'/api/v1/claim');
            req.setMethod('POST');
            
            
            req.setHeader('Authorization', 'Bearer '+accessToken);
            req.setHeader('Content-Type', 'application/json');   
            req.setBody(JSON.serialize(claimForms)); 
            req.setTimeout(120000); 
            
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('After Request ==============>');
            System.debug(res);
            if(res.getStatusCode() == 200){
                ClaimSubmissionResponse response = new ClaimSubmissionResponse();
                for(Claim claim : claimForms){
                    response.processedClaimIds.add(claim.claim.body.sfid);
                }
                response.errrorMessage = null;
                return response;
            }else{
                ClaimSubmissionResponse response = new ClaimSubmissionResponse();
                for(Claim claim : claimForms){
                    response.processedClaimIds.add(claim.claim.body.sfid);
                }
                response.errrorMessage = res.getBody();
                return response;
            }
        }
        return null;
    }
    
    Public Static ConfirmationSchema getClaimConfirmations(String accessToken){
        if(String.isNotBlank(accessToken)){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(creds.Endpoint__c+'/api/v1/confirmation');
            req.setMethod('POST');
            
            
            req.setHeader('Authorization', 'Bearer '+accessToken);
            req.setHeader('Content-Type', 'application/json');   
            req.setTimeout(120000); 
            
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                //String jsonStr = '{"data":[{"file":"PAMCARE_20210128_EFT8675309.835_631fae769ef73","message":{"transCode":"I","totalPayment":"391.05","creditDebitFlag":"C","paymentCode":"ACH","paymentDate":"20120131","referenceId":"220288011128307TA","payerInfo":{"name":"BCBSDISNEY","npi":"","address1":"POBLADORD","address2":"","city":"LOSANGELES","state":"CA","zip":"9006"},"payeeInfo":{"name":"UCLAMEDICALCENTER","npi":"1215193883"},"claims":[{"claimNo":"a2V760000000MS6EAM","status":"Confirmed","paidBy":"1","chargeAmt":"225","paidAmt":"225","patientAmt":"","claimServiceDateStart":"20050202","claimServiceDateEnd":"20050203","adjustmentsList":[],"services":[{"codeType":"HC","code":"98765","chargeAmt":"150","paidAmt":"150","revenueCode":"revenue","paidUnit":"1","serviceID":"8911","serviceDate":"20120124","adjustmentsList":[]},{"codeType":"HC","code":"26591","chargeAmt":"75","paidAmt":"75","revenueCode":"","paidUnit":"","serviceDate":"20120124","adjustmentsList":[]}]},{"claimNo":"a2V760000000MS6EAM","status":"Adjusted","paidBy":"1","chargeAmt":"225","paidAmt":"195","patientAmt":"10","claimServiceDateStart":"20050202","adjustmentsList":[{"group":"ContractualObligations","reasonCode":"45","amount":"20"}],"services":[{"codeType":"HC","code":"98765","chargeAmt":"150","paidAmt":"140","revenueCode":"","paidUnit":"","serviceDate":"20120124","adjustmentsList":[{"group":"PatientResponsibility","reasonCode":"3","amount":"10"}]},{"codeType":"HC","code":"26591","chargeAmt":"75","paidAmt":"75","revenueCode":"","paidUnit":"","serviceDate":"20120124","adjustmentsList":[]}]}]}}]}';
                
                ConfirmationSchema resp = ConfirmationSchema.parse(res.getBody());
                
                return resp;
            }
        }
        return null;
    }
    
    Public Static List<ValidationSchema> getClaimValidations(String accessToken){
        if(String.isNotBlank(accessToken)){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(creds.Endpoint__c+'/api/v1/verification');
            req.setMethod('POST');
            req.setTimeout(120000); 
            
            
            
            req.setHeader('Authorization', 'Bearer '+accessToken);
            req.setHeader('Content-Type', 'application/json');   
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                //String jsonStr = '[{"name":"999","data":[{"file":"123904.dat.4170143.999","claim_id":"a2V760000000MS6EAM","message":{"Status":"Validated"}}]},{"name":"277","data":[{"file":"123904.dat.4170147.277","claim_id":"a2V760000000MS6EAM","message":{"status":"Rejected","items":[{"name":"ABILITYNETWORK","first_name":"","identification_code":"411973195","entity":"Clearinghouse","type":"Facility","code_qualifier":"","trace_number":"","references":[],"details":[]},{"name":"EATING_DISORDER_RECOVERY_SPECIALIST","first_name":"","identification_code":"821687876","entity":"Receiver","type":"Facility","code_qualifier":"","trace_number":"123904","references":[{"type":"PayerClaimNumber","number":"G4521278810"},{"type":"BillingType","number":"11"}],"payment":{"type":"Rejected","qty":"1","amount_type":"Returned","amount":"330"},"service_date_from":"20220306","service_date_to":"20220313","details":[{"category_code":"A2","status_code":"20","date":"20220924","amount":"330","note":""}]},{"name":"EATING_DISORDER_RECOVERY_SPECIALIST","first_name":"","identification_code":"1881928539","entity":"BillingProvider","type":"Facility","code_qualifier":"Medicare","trace_number":"","references":[],"details":[]},{"name":"MEGHAN","first_name":"LEONHARDT","identification_code":"VQA449W01913","entity":"Patient","type":"Person","code_qualifier":"MemberIdentificationNumber","trace_number":"","references":[],"details":[{"category_code":"A2","status_code":"20","date":"20220924","amount":"330.00","note":"REJECTEDFORPROCESSING."}]}]}}]}]';
                //List<ValidationSchema> resp = ValidationSchema.parse(res.getBody());
                
                List<ValidationSchema> resp = ValidationSchema.parse(res.getBody());
                return resp;
            }
        }
        return null;
    }
    
    
    Public Static ClaimForm getClaimBody(Claim__c claim){
        String invalidNumbers = '[^0-9]';
        List<Services> lstServices= new List<Services>();
        
        for(Claim_Line__c claimLine: claim.Claim_Lines__r){
            List<String> Diagnosis=new List<String>{
                claimLine.Diag_1__r.Name != null ? claimLine.Diag_1__r.Name : ''
                    ,claimLine.Diag_2__r.Name != null ? claimLine.Diag_2__r.Name : ''
                        ,claimLine.Diag_3__r.Name != null ? claimLine.Diag_3__r.Name : '' 
                            ,claimLine.Diag_4__r.Name != null ? claimLine.Diag_4__r.Name : ''
                                ,claimLine.Diag_5__r.Name != null ? claimLine.Diag_5__r.Name : ''
                                    ,claimLine.Diag_6__r.Name != null ? claimLine.Diag_6__r.Name : ''};
                                        
            Provider oRenderingProvider= new Provider();
            oRenderingProvider.type = claimLine.Claim__r.Rendering_Provider_Type__c	;// To be replaced
            oRenderingProvider.name = claimLine.Claim__r.Rendering_Provider_Name__c;// To be replaced
            oRenderingProvider.first_name = '';
            oRenderingProvider.address_street ='';// To be replaced
            oRenderingProvider.address_city = '';// To be replaced
            oRenderingProvider.address_state = '';// To be replaced
            oRenderingProvider.address_zip_code = null;// To be replaced
            oRenderingProvider.phone ='';// To be replaced
            oRenderingProvider.taxonomy_code = claimLine.Rendering_Provider_ID_TaxonomyCode__c != null ? String.Valueof(claimLine.Rendering_Provider_ID_TaxonomyCode__c): null; // To be replaced
            oRenderingProvider.npi = claimLine.Rendering_Provider_ID_NPI__c != null ? String.Valueof(claimLine.Rendering_Provider_ID_NPI__c): null;
            
            Services oServices= new Services();
            oServices.service_id = claimLine.Id;
            oServices.Date_from_of_service = claimLine.Date_from_of_Service__c ;
            oServices.Date_to_of_service = claimLine.Date_to_of_Service__c ;
            oServices.Place_of_service = claimLine.Place_of_Service__c !=null ? claimLine.Place_of_Service__c : '';
            oServices.cptb_hcpcs = claimLine.CPT_HCPCS__c !=null ? claimLine.CPT_HCPCS__c : '';
            oServices.clia_id = '10D2258449';
            oServices.Modifiers =  claimLine.Modifier_s__c !=null ?  claimLine.Modifier_s__c : '';
            oServices.Note = claimLine.Diagnosis_pointers__c !=null ? claimLine.Diagnosis_pointers__c : '' ;
            oServices.Diagnosis = Diagnosis;
            oServices.Charges = claimLine.Total_Price__c !=null ?  claimLine.Total_Price__c : 0.0;
            oServices.measure = 'UN';
            oServices.Units = claimLine.Quantity__c !=null ? claimLine.Quantity__c : 0;
            oServices.rendering_provider = oRenderingProvider;
            lstServices.add(oServices);
        }
        
        
        ClaimDates oClaimdates= new ClaimDates();
        //oClaimdates.first_symptoms = claim.Accident_Date__c ; //Not Mapped
        oClaimdates.accident = claim.X14_Date_of_Current_Illness__c; //Not Mapped
        //oClaimdates.last_seen_by_doctor = System.Today(); //Not Mapped
        //oClaimdates.first_treatment = System.Today(); //Not Mapped
        oClaimdates.unable_to_work_from = claim.X16_Unable_to_work_from__c ;
        oClaimdates.unable_to_work_to = claim.X16_Unable_to_work_to__c ;
        oClaimdates.hospitalized_from = claim.X18_Hospitalized_from__c ;
        oClaimdates.hospitalized_to = claim.X18_Hospitalized_To__c ;
        
        
        Patient oPatient = new Patient();
        oPatient.first_name = claim.Patients_First_Name__c !=null ?  claim.Patients_First_Name__c :'';
        oPatient.last_name = claim.Patients_Last_Name__c !=null ?  claim.Patients_Last_Name__c :'';
        oPatient.birth_date = claim.Patients_Birth_Date__c ;
        oPatient.account = claim.Patient_Account__c !=null ?  claim.Patient_Account__c :'';
        oPatient.Sex = claim.Sex__c !=null ?  claim.Sex__c :'';
        oPatient.address_street = claim.Patients_Address_Street__c !=null ?  claim.Patients_Address_Street__c :'';
        oPatient.address_city = claim.Patients_Address_City__c !=null ?  claim.Patients_Address_City__c :'';
        oPatient.address_state = claim.Patients_Address_State__c !=null ?  claim.Patients_Address_State__c :'';
        oPatient.address_zip_code = claim.Patients_Address_Zip_Code__c !=null ?  claim.Patients_Address_Zip_Code__c :'';
        oPatient.relationship_to_the_insured= claim.Patients_relationship_to_the_insured__c !=null ?  claim.Patients_relationship_to_the_insured__c :'';
        
        
        Subscriber oSubscriber = new Subscriber();
        oSubscriber.policy_number = '';
        oSubscriber.claim_casualty_number  = claim.Casualty__c !=null ?  claim.Casualty__c :'';
        oSubscriber.id_number = claim.Insureds_ID_Number__c !=null ?  claim.Insureds_ID_Number__c :'';
        //oSubscriber.polis_number = '12345';
        oSubscriber.payer_responsibility = 'P';
        if (claim.Payer__r.Name == System.Label.BCBS_Payer) {
            oSubscriber.insurance_plan_type = claim.Claim_Indicator_Code__c;
        } else {
            oSubscriber.insurance_plan_type = '11';
        }

        
        //oSubscriber.insurance_program = 'Silver';
        oSubscriber.first_name = claim.Insureds_First_Name__c !=null ?  claim.Insureds_First_Name__c :'';
        oSubscriber.last_name = claim.Insureds_Last_Name__c !=null ?  claim.Insureds_Last_Name__c :'';
        oSubscriber.birth_date = claim.Patients_Birth_Date__c ;
        oSubscriber.Sex = claim.Sex__c !=null ?  claim.Sex__c :'';
        oSubscriber.address_street = claim.Insureds_Address_Street__c !=null ?  claim.Insureds_Address_Street__c :'';
        oSubscriber.address_city = claim.Insureds_Address_City__c !=null ?  claim.Insureds_Address_City__c :'';
        oSubscriber.address_state = claim.Insureds_Address_State__c !=null ?  claim.Insureds_Address_State__c :'';
        oSubscriber.address_zip_code = claim.Insureds_Address_Zip_Code__c !=null ?  claim.Insureds_Address_Zip_Code__c :'';
        
        
        Provider oBillingProvider= new Provider();
        oBillingProvider.type=claim.Billing_Provider_Type__c !=null ?  claim.Billing_Provider_Type__c :'';
        oBillingProvider.name=claim.Billing_Provider_Name__c !=null ?  claim.Billing_Provider_Name__c :'';
        oBillingProvider.address_street=claim.Billing_Provider_Address_Street__c !=null ?  claim.Billing_Provider_Address_Street__c :'';
        oBillingProvider.address_city=claim.Billing_Provider_Address_City__c !=null ?  claim.Billing_Provider_Address_City__c :'';
        oBillingProvider.address_state=claim.Billing_Provider_Address_State__c !=null ?  claim.Billing_Provider_Address_State__c :'';
        oBillingProvider.address_zip_code=claim.Billing_Provider_Address_Zip_Code__c !=null ? String.Valueof(claim.Billing_Provider_Address_Zip_Code__c.replaceAll( invalidNumbers,'')) : '';
        oBillingProvider.phone=claim.Billing_Provider_Phone__c!=null ?  claim.Billing_Provider_Phone__c :'';
        oBillingProvider.taxonomy_code=claim.Taxonomy_code_of_Rendering_Provider__c != null ? claim.Taxonomy_code_of_Rendering_Provider__c: '' ;//Not Mapped
        oBillingProvider.npi=claim.Billing_Provider_NPI__c != null ? String.Valueof(claim.Billing_Provider_NPI__c.replaceAll( invalidNumbers,'')) : '';
        
        Provider oServiceProvider= new Provider();
        oServiceProvider.type=claim.X33_Service_Provider_Type__c !=null ?  claim.X33_Service_Provider_Type__c :'';//Not Mapped
        oServiceProvider.name=claim.X33_Service_Provider_Name__c !=null ?  claim.X33_Service_Provider_Name__c :'';//Not Mapped
        oServiceProvider.address_street=claim.X32_Service_Address_Street__c !=null ?  claim.X32_Service_Address_Street__c :'';
        oServiceProvider.address_city=claim.X32_Service_Address_City__c !=null ?  claim.X32_Service_Address_City__c :'';
        oServiceProvider.address_state=claim.X32_Service_Address_State__c !=null ?  claim.X32_Service_Address_State__c :'';
        oServiceProvider.address_zip_code=claim.X32_Service_Address_Zip__c != null ? String.Valueof(claim.X32_Service_Address_Zip__c.replaceAll( invalidNumbers,'')) :'';
        oServiceProvider.phone=claim.X32_Service_Phone__c !=null ?  claim.X32_Service_Phone__c :'';
        oServiceProvider.taxonomy_code= claim.X32_Service_Taxonomy_Code__c !=null ? claim.X32_Service_Taxonomy_Code__c: '';
        oServiceProvider.npi=claim.X32_Service_Npi__c != null ? String.Valueof(claim.X32_Service_Npi__c): '';
        
        
        
        Provider oRenderingProvider= new Provider();
        oRenderingProvider.type=claim.Rendering_Provider_Type__c;//Not Mapped
        oRenderingProvider.name=claim.Rendering_Provider_Name__c;//Not Mapped
        oRenderingProvider.first_name=claim.Rendering_Provider_First_Name__c;//Not Mapped
        oRenderingProvider.address_street=claim.Rendering_Provider_Street__c;
        oRenderingProvider.address_city=claim.Rendering_Provider_City__c;
        oRenderingProvider.address_state=claim.Rendering_Provider_State__c;
        oRenderingProvider.address_zip_code=claim.Rendering_Provider_Zip__c != null ? String.Valueof(claim.Rendering_Provider_Zip__c.replaceAll( invalidNumbers,'')) :'';
        oRenderingProvider.phone=claim.Rendering_Provider_Phone__c;
        oRenderingProvider.taxonomy_code= claim.Rendering_Provider_Taxonomy_Code__c !=null ? claim.Rendering_Provider_Taxonomy_Code__c: '';
        oRenderingProvider.npi=claim.Rendering_Provider_NPI__c != null ? String.Valueof(claim.Rendering_Provider_NPI__c): '';
        
        Provider oReferringProvider= new Provider();
        oReferringProvider.type=claim.Referring_Provider_Type__c;//Not Mapped
        oReferringProvider.name=claim.Referring_Provider_Name__c;//Not Mapped
        oReferringProvider.first_name=claim.Referring_Provider_First_Name__c;
        //oReferringProvider.address_street=claim.Referring_Provider_Address_Street__c;
        //oReferringProvider.address_city=claim.Referring_Provider_Address_City__c	;
        //oReferringProvider.address_state=claim.Referring_Provider_Address_State__c;
        //oReferringProvider.address_zip_code=claim.Referring_Provider_Address_Zip_Code__c	 != null ? String.Valueof(claim.Referring_Provider_Address_Zip_Code__c	.replaceAll( invalidNumbers,'')) :'';
        //oReferringProvider.phone=claim.Referring_Provider_Phone__c;
        //oReferringProvider.taxonomy_code= claim.Referring_Provider_Taxonomy_code__c	 !=null ? claim.Referring_Provider_Taxonomy_code__c	: '';
        oReferringProvider.npi=claim.Referring_Provider_NPI__c	 != null ? String.Valueof(claim.Referring_Provider_NPI__c): '';
        
        
        Payer oPayer= new Payer();
        oPayer.code=claim.Payer__r.Payer_Code__c;
        oPayer.name=claim.Payer__r.Name !=null ?  claim.Payer__r.Name :'';
        oPayer.address_street=claim.Payer__r.BillingStreet !=null ?  claim.Payer__r.BillingStreet :'';
        oPayer.address_city=claim.Payer__r.BillingCity !=null ?  claim.Payer__r.BillingCity :'';
        oPayer.address_state=claim.Payer__r.BillingStateCode !=null ?  claim.Payer__r.BillingStateCode :'';
        oPayer.address_zip_code=claim.Payer__r.BillingPostalCode !=null ?  claim.Payer__r.BillingPostalCode :'';
        
        
        ClaimForm oClaims= new ClaimForm();
        oClaims.Claim_id=claim.Name;
        oClaims.date_created = claim.CreatedDate.date();
        oClaims.submitter_code=claim.Submitter_Id__c;
        oClaims.sfid=claim.Id;
        oClaims.claim_dates=oClaimdates;
        oClaims.medical_record_number = claim.Name;
        oClaims.is_patient_condition_related_to_auto_state = claim.patient_condition_related_to_auto_state__c;
        // oClaims.Payer_code=claim.Payer__r.Payer_Code__c;
        // oClaims.Payer=claim.Payer__r.Name !=null ?  claim.Payer__r.Name :'';
        oClaims.patient=oPatient;
        oClaims.subscriber=oSubscriber;
        oClaims.payer=oPayer;
        
        oClaims.Is_patient_condition_related_to_emp=Boolean.valueOf(claim.IS_PATIENTS_CONDITION_RELATED_TO_Emp__c);
        oClaims.Is_patient_condition_related_to_auto=Boolean.valueOf(claim.IS_PATIENTS_CONDITION_RELATED_TO_A__c);
        oClaims.Is_patient_condition_related_to_other=Boolean.valueOf(claim.IS_PATIENTS_CONDITION_RELATED_TO__c);
        oClaims.Insured_or_authorized_persons_sign=true;
        
        //oClaims.Referring_other_physician_id=claim.REFERRING_OTHER_PHYSICIAN_ID__c != null ? claim.REFERRING_OTHER_PHYSICIAN_ID__c : '';
        //oClaims.Original_ref_number = claim.Original_Ref_No__c !=null ? claim.Original_Ref_No__c : '';
        oClaims.Original_ref_number = claim.Innovalan_Reference_Id__c !=null ? claim.Innovalan_Reference_Id__c : '';
        oClaims.Prior_authorization=claim.PRIOR_AUTHORIZATION__c !=null ?  claim.PRIOR_AUTHORIZATION__c:''; 
        oClaims.Services=lstServices;
        oClaims.Federal_tax_id_number= claim.FEDERAL_TAX_ID_NUMBER__c !=null ? Integer.Valueof(claim.FEDERAL_TAX_ID_NUMBER__c.replaceAll( invalidNumbers,'')):null;
        oClaims.Accept_assignment=claim.Accept_Assignment__c !=null ?  claim.Accept_Assignment__c :'';
        oClaims.billing_provider=oBillingProvider;
        oClaims.service_provider=oServiceProvider;
        oClaims.rendering_provider=oRenderingProvider;
        oClaims.referring_provider=oReferringProvider;
        return oClaims;
    }
    
    
}