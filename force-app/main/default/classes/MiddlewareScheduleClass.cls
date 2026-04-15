/*
@TestClass MiddlewareScheduleClassTest
*/
//MiddlewareScheduleClass.scheduleMe() ;
public with sharing class MiddlewareScheduleClass implements Schedulable, Database.AllowsCallouts {
    public static String CRON_EXP = '0 0 0/6 1/1 * ? *'; // Runs for every six hour
    public static String scheduleMe() {
        return System.schedule('Schedule job which will run every 6 hours to process confirmations', CRON_EXP, new MiddlewareScheduleClass());
    }
    public void execute(SchedulableContext sc) {
        ID jobID = System.enqueueJob(new MiddleWareQueuebleJob());
        // database.executebatch(new SubmitClaimToMiddlewareBatch());
    }
    public class MiddleWareQueuebleJob implements Queueable, Database.AllowsCallouts {
        public MiddleWareQueuebleJob()
        {
            
        }
        public void execute(QueueableContext qc)
        {
            String accessToken = MiddlewareUtils.getAccessToken();
            MiddlewareScheduleClass.processConfirmations(accessToken);
            // MiddlewareScheduleClass.processValidations(accessToken);
        }
    }
    
    
    public Static void processConfirmations(String accessToken){
        ConfirmationSchema resp = MiddlewareUtils.getClaimConfirmations(accessToken);
        if(resp != null){
            try{
                List<Monitor_Confirmation_Data__c> mcd = new List<Monitor_Confirmation_Data__c>();
                mcd.add(new Monitor_Confirmation_Data__c(Response_Data__c = JSON.serialize(resp)));
                if(!mcd.isEmpty()){
                    insert mcd;
                }
            }catch(Exception Ex){
                
            }
            List<ConfirmationSchema.Data> allData = resp.data;
            if(allData.size() > 0){
                Map<String, Payment__c> paymentsMap = new Map<String, Payment__c>();
                Map<String, Map<String, Payment_Service__c>> paymentServicesForPaymentMap = new Map<String, Map<String, Payment_Service__c>>();
                
                Map<String, List<Adjustments_List__c>> paymentRelatedAdjustments = new Map<String, List<Adjustments_List__c>>();
                Map<String, List<Adjustments_List__c>> paymentServiceRelatedAdjustments = new Map<String, List<Adjustments_List__c>>();
                
                // New map to store RARC records for each Payment_Service
                Map<String, List<RARC__c>> paymentServiceRARCs = new Map<String, List<RARC__c>>();
                Map<String, Id> codeSetMap = new Map<String, Id>();
                for(CodeSet codeSet : [SELECT Id, Code FROM CodeSet WHERE Code != null]) {
                    codeSetMap.put(codeSet.Code, codeSet.Id);
                }
                system.debug('codeSetMap--->'+codeSetMap);
                Id recordId;
                for(ConfirmationSchema.Data data : allData){
                    if(data.message != null && data.message.body.claims != null && data.message.body.claims.size() > 0){
                        for(ConfirmationSchema.Claims claim : data.message.body.claims){
                            if(claim.claimNo.startsWith('C-') || claim.claimNo.startsWith('CLMINV-')){
                                try { 
                                    recordId = Id.valueOf(correctCapitalizedId(claim.claimNo.right(18)));
                                    System.debug('recordId >>>'+recordId);
                                    Payment__c payment = new Payment__c();
                                    payment.Trans_Code__c = data.message.body.transCode;
                                    payment.Total_Payment__c = String.isNotBlank(data.message.Body.totalPayment) ? Decimal.valueOf(data.message.body.totalPayment) : null;
                                    payment.Credit_Debit_Flag__c = data.message.body.creditDebitFlag;
                                    payment.Payment_Code__c = data.message.body.paymentCode;
                                    payment.Payment_Date__c = MiddlewareScheduleClass.parseStringToDate(data.message.body.paymentDate);
                                    payment.Reference_Id__c = data.message.body.claims[0].referenceId;
                                    
                                    if(data.message.body.payerInfo != null){
                                        payment.Payer_Name__c = data.message.body.payerInfo.name;
                                        payment.Payer_NPI__c = data.message.body.payerInfo.npi;
                                        payment.Payer_Address_1__c = data.message.body.payerInfo.address1;
                                        payment.Payer_Address_2__c = data.message.body.payerInfo.address2;
                                        payment.Payer_City__c = data.message.body.payerInfo.city;
                                        payment.Payer_State__c = data.message.body.payerInfo.state;
                                        payment.Payer_Zip__c = data.message.body.payerInfo.zip;
                                    }
                                    
                                    if(data.message.body.payeeInfo != null){
                                        payment.Payee_Name__c = data.message.body.payeeInfo.name;
                                        payment.Payee_NPI__c = data.message.body.payeeInfo.npi;
                                    }
                                    
                                    payment.Claim__c = recordId;
                                    payment.Status__c = claim.status;
                                    payment.Paid_By__c = String.isNotBlank(claim.paidBy) ? Decimal.valueOf(claim.paidBy) : null;
                                    payment.Charge_Amount__c = String.isNotBlank(claim.chargeAmt) ? Decimal.valueOf(claim.chargeAmt) : null;
                                    payment.Paid_Amount__c = String.isNotBlank(claim.paidAmt) ? Decimal.valueOf(claim.paidAmt) : null;
                                    payment.Patient_Amount__c = String.isNotBlank(claim.patientAmt) ? Decimal.valueOf(claim.patientAmt) : null;
                                    payment.Claim_Service_Date_Start__c = MiddlewareScheduleClass.parseStringToDate(claim.claimServiceDateStart);
                                    payment.Claim_Service_Date_End__c = MiddlewareScheduleClass.parseStringToDate(claim.claimServiceDateEnd);
                                    payment.Amount__c = String.isNotBlank(claim.paidAmt) ? Decimal.valueOf(claim.paidAmt) : null;
                                    payment.Unallocation__c = String.isNotBlank(claim.paidAmt) ? Decimal.valueOf(claim.paidAmt) : null;
                                    payment.Allocation__c = 0;
                                    payment.payment_method__c = 'EFT';
                                    
                                    String paymentIdentifier = MiddlewareScheduleClass.getUniqueReferenceId();
                                    paymentsMap.put(paymentIdentifier, payment);
                                    
                                    // Handle services and RARC lists
                                    if(claim.services != null && claim.services.size() > 0){
                                        Map<String, Payment_Service__c> paymentServiceMap = new Map<String, Payment_Service__c>();
                                        for(ConfirmationSchema.Services service : claim.services){
                                            Payment_Service__c serviceRecord = new Payment_Service__c();
                                            serviceRecord.Code_Type__c = service.codeType;
                                            serviceRecord.Code__c = service.code;
                                            serviceRecord.Charge_Amount__c = String.isNotBlank(service.chargeAmt) ? Decimal.valueOf(service.chargeAmt) : null;
                                            serviceRecord.Paid_Amount__c = String.isNotBlank(service.paidAmt) ? Decimal.valueOf(service.paidAmt) : null;
                                            serviceRecord.Revenue_Code__c = service.revenueCode;
                                            serviceRecord.Paid_Unit__c = service.paidUnit;
                                            serviceRecord.Service_Id__c = service.serviceID;
                                            serviceRecord.Service_Date__c = MiddlewareScheduleClass.parseStringToDate(service.serviceDate);
                                            
                                            String paymentServiceIdentifier = MiddlewareScheduleClass.getUniqueReferenceId();
                                            paymentServiceMap.put(paymentServiceIdentifier, serviceRecord);
                                            
                                            // Handle RARC List (only create RARC records linked to CodeSet)
                                            if(service.rarcList != null && !service.rarcList.isEmpty()){
                                                List<RARC__c> rarcRecords = new List<RARC__c>();
                                                for(String rarcValue : service.rarcList){
                                                    // Only create RARC record if there’s a matching CodeSet
                                                    if(codeSetMap.containsKey(rarcValue)){
                                                        RARC__c rarcRecord = new RARC__c();
                                                        rarcRecord.Code_Set__c = codeSetMap.get(rarcValue); // Link to CodeSet
                                                        rarcRecords.add(rarcRecord);
                                                    }
                                                    system.debug('rarcRecords--->'+rarcRecords);
                                                }
                                                if(!rarcRecords.isEmpty()){
                                                    paymentServiceRARCs.put(paymentServiceIdentifier, rarcRecords);
                                                }
                                            }
                                            
                                            system.debug('paymentServiceRARCs--->'+paymentServiceRARCs);
                                            // Payment Service Adjustments (existing logic)
                                            if(service.adjustmentsList != null && service.adjustmentsList.size() > 0){
                                                paymentServiceRelatedAdjustments.put(paymentServiceIdentifier, new List<Adjustments_List__c>());
                                                
                                                for(ConfirmationSchema.AdjustmentsList adjustment : service.adjustmentsList){
                                                    Adjustments_List__c adjustmentRecord = new Adjustments_List__c();
                                                    adjustmentRecord.Group__c = adjustment.group_Z;
                                                    adjustmentRecord.Reason_Code__c = adjustment.reasonCode;
                                                    if(codeSetMap.containsKey(adjustment.reasonCode)){
                                                        adjustmentRecord.Code_Set__c = codeSetMap.get(adjustment.reasonCode);
                                                    }
                                                    adjustmentRecord.Amount__c = String.isNotBlank(adjustment.amount) ? Decimal.valueOf(adjustment.amount) : null;
                                                    paymentServiceRelatedAdjustments.get(paymentServiceIdentifier).add(adjustmentRecord);
                                                }
                                            }
                                        }
                                        
                                        paymentServicesForPaymentMap.put(paymentIdentifier, paymentServiceMap);
                                    }
                                    
                                    // Existing adjustment logic for payment
                                    if(claim.services != null && claim.services.size() > 0){
                                        for(ConfirmationSchema.Services service : claim.services){
                                            if(service.adjustmentsList != null && service.adjustmentsList.size() > 0){
                                                paymentRelatedAdjustments.put(paymentIdentifier, new List<Adjustments_List__c>());
                                                for(ConfirmationSchema.AdjustmentsList adjustment : service.adjustmentsList){
                                                    Adjustments_List__c adjustmentRecord = new Adjustments_List__c();
                                                    adjustmentRecord.Group__c = adjustment.group_Z;
                                                    adjustmentRecord.Reason_Code__c = adjustment.reasonCode;
                                                    if(codeSetMap.containsKey(adjustment.reasonCode)){
                                                        adjustmentRecord.Code_Set__c = codeSetMap.get(adjustment.reasonCode);
                                                    }
                                                    adjustmentRecord.Amount__c = String.isNotBlank(adjustment.amount) ? Decimal.valueOf(adjustment.amount) : null;
                                                    paymentRelatedAdjustments.get(paymentIdentifier).add(adjustmentRecord);
                                                }
                                            }
                                        }
                                    }
                                    
                                } catch (Exception e) {
                                    System.debug('Test 3>>>>'+e.getMessage());
                                }
                            }
                        }
                    }
                }
                
                if(paymentsMap.size() > 0){
                    insert paymentsMap.values();
                    
                    List<Adjustments_List__c> finalAdjustmentList = new List<Adjustments_List__c>();
                    List<RARC__c> finalRARCList = new List<RARC__c>(); // New list for RARC records
                    
                    if(paymentServicesForPaymentMap.size() > 0){
                        Map<String, Payment_Service__c> finalPaymentServiceMap = new Map<String, Payment_Service__c>();
                        for(String paymentKey : paymentsMap.keySet()){
                            Map<String, Payment_Service__c> relatedPaymentServiceMap = paymentServicesForPaymentMap.get(paymentKey);
                            for(String paymentServiceKey : relatedPaymentServiceMap.keySet()){
                                relatedPaymentServiceMap.get(paymentServiceKey).Payment__c = paymentsMap.get(paymentKey).Id;
                                finalPaymentServiceMap.put(paymentServiceKey, relatedPaymentServiceMap.get(paymentServiceKey));
                            }
                        }
                        
                        if(finalPaymentServiceMap.size() > 0){
                            insert finalPaymentServiceMap.values();
                        }
                        
                        // Process RARC records
                        if(paymentServiceRARCs.size() > 0){
                            for(String paymentServiceKey : paymentServiceRARCs.keySet()){
                                for(RARC__c rarc : paymentServiceRARCs.get(paymentServiceKey)){
                                    rarc.Payment_Service__c = finalPaymentServiceMap.get(paymentServiceKey).Id;
                                    finalRARCList.add(rarc);
                                }
                                system.debug('finalRARCList--->'+finalRARCList);
                            }
                        }
                        
                        // Existing logic for payment service adjustments
                        if(paymentServiceRelatedAdjustments.size() > 0){
                            for(String paymentServiceKey : paymentServiceRelatedAdjustments.keySet()){
                                for(Adjustments_List__c AL : paymentServiceRelatedAdjustments.get(paymentServiceKey)){
                                    AL.Payment_Service__c = finalPaymentServiceMap.get(paymentServiceKey).Id;
                                    if(codeSetMap.containsKey(AL.Reason_Code__c)){
                                        AL.Code_Set__c = codeSetMap.get(AL.Reason_Code__c);
                                    }
                                    finalAdjustmentList.add(AL);
                                }
                            }
                        }
                    }
                    
                    // Existing logic for payment adjustments
                    if(paymentRelatedAdjustments.size() > 0){
                        for(String paymentKey : paymentRelatedAdjustments.keySet()){
                            for(Adjustments_List__c AL : paymentRelatedAdjustments.get(paymentKey)){
                                AL.Payment__c = paymentsMap.get(paymentKey).Id;
                                if(codeSetMap.containsKey(AL.Reason_Code__c)){
                                    AL.Code_Set__c = codeSetMap.get(AL.Reason_Code__c);
                                }
                                finalAdjustmentList.add(AL);
                            }
                        }
                    }
                    
                    // Insert all records
                    if(!finalAdjustmentList.isEmpty()){
                        insert finalAdjustmentList;
                    }
                    if(!finalRARCList.isEmpty()){
                        insert finalRARCList; // Insert RARC records
                    }
                }
            }
        }
    }
    
    public static Id correctCapitalizedId(String input) {
        String keyString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345', result = '';
        Integer i = 0, s = 15;
        
        if (input.length() != 18) {
            return null;
        }
        
        for (String seq : input.split('(?<=\\G.{5})')) {
            Integer chk = keyString.indexOf(input.mid(s++,1));
            i = 0;
            for (String chr : seq.split('')) {
                result += seq.length() != 5  ? '' : (chk & (i == 0 ? ++i : (i*=2))) == 0 ? chr.toLowerCase() : chr;
            }
        }
        return Id.valueOf(result);
    }
    Public Static Void processValidations(String accessToken){
        List<ValidationSchema> resp = MiddlewareUtils.getClaimValidations(accessToken);
        
        if(resp != null){
            List<ValidationSchema.data> level1Data = new List<ValidationSchema.data>();
            List<ValidationSchema.data> level2Data = new List<ValidationSchema.data>();
            if(resp.size() > 0){
                for(ValidationSchema response : resp){
                    if('999'.equalsIgnoreCase(response.name)){
                        level1Data = response.data;
                    }else if('277'.equalsIgnoreCase(response.name)){
                        level2Data = response.data;
                    }
                }
            }
            
            validationData dataMaps = new validationData();
            
            dataMaps = MiddlewareScheduleClass.processValidationLines('999', level1Data, dataMaps);
            dataMaps = MiddlewareScheduleClass.processValidationLines('277', level2Data, dataMaps);
            
            
            system.debug(level1Data);
            system.debug(level2Data);
            
            if(dataMaps.validations.size() > 0){
                //Insert the validation records before we proceed to add line items to the validation lines.....
                insert dataMaps.validations.values();
                
                Map<String, Claim_Validation_Line__c> finalValidationLineMap = new Map<String, Claim_Validation_Line__c>();
                for(String validationUniqueReference : dataMaps.validations.keySet()){
                    
                    if(dataMaps.validationLines.containsKey(validationUniqueReference)){
                        Map<String, Claim_Validation_Line__c> relatedLineMap = dataMaps.validationLines.get(validationUniqueReference);
                        for(String validationLineReference : relatedLineMap.keySet()){
                            relatedLineMap.get(validationLineReference).Claim_Validation__c = dataMaps.validations.get(validationUniqueReference).Id;
                            finalValidationLineMap.put(relatedLineMap.get(validationLineReference).Unique_Reference__c, relatedLineMap.get(validationLineReference));
                        }
                    }
                }
                
                
                if(finalValidationLineMap.size() > 0){
                    Insert finalValidationLineMap.values();
                    
                    
                    if(finalValidationLineMap.size() > 0){
                        List<Claim_Validation_Reference__c> finalReferenceList = new List<Claim_Validation_Reference__c>();
                        for(String validationLineUniqueReference : finalValidationLineMap.keySet()){
                            if(dataMaps.ValidationReferences.containsKey(validationLineUniqueReference)){
                                for(Claim_Validation_Reference__c ref : dataMaps.ValidationReferences.get(validationLineUniqueReference)){
                                    ref.Claim_Validation_Line__c = finalValidationLineMap.get(validationLineUniqueReference).Id;
                                    finalReferenceList.add(ref);
                                }
                            }
                        }
                        
                        if(finalReferenceList.size() > 0){
                            Insert finalReferenceList;
                        }
                    }
                    
                    
                    
                    if(dataMaps.ValidationDetails.size() > 0){
                        List<Claim_Validation_Line_Details__c> finalDetailList = new List<Claim_Validation_Line_Details__c>();
                        for(String validationLineUniqueReference : finalValidationLineMap.keySet()){
                            if(dataMaps.ValidationDetails.containsKey(validationLineUniqueReference)){
                                for(Claim_Validation_Line_Details__c ref : dataMaps.ValidationDetails.get(validationLineUniqueReference)){
                                    ref.Claim_Validation_Line__c = finalValidationLineMap.get(validationLineUniqueReference).Id;
                                    finalDetailList.add(ref);
                                }
                            }
                        }
                        
                        if(finalDetailList.size() > 0){
                            Insert finalDetailList;
                        }
                    }
                } 
            }
        }
    }
    
    Public Static validationData processValidationLines(String validationLevel, List<ValidationSchema.data> levelData , validationData dataMaps){
        
        if(levelData.size() > 0){
            for(ValidationSchema.data data : levelData){
                Claim_Validation__c claimValidation = new Claim_Validation__c();
                claimValidation.Claim__c =Id.valueOf(data.claim_id, true) ;
                claimValidation.Status__c = data?.message?.status;
                claimValidation.Validation_Level__c = validationLevel;
                claimValidation.Unique_Reference__c = MiddlewareScheduleClass.getUniqueReferenceId();
                dataMaps.validations.put(claimValidation.Unique_Reference__c, claimValidation);
                
                
                //Once the validation level records are proccessed, we process the validation line items....
                
                if(data.message != null && data.message.items != null && data.message.items.size() > 0){
                    Map<String, Claim_Validation_Line__c> validationLineMap = new Map<String, Claim_Validation_Line__c>();
                    for(ValidationSchema.Items item : data.message.items){
                        Claim_Validation_Line__c validationLine = new Claim_Validation_Line__c();
                        validationLine.Name = item.name;
                        validationLine.First_Name__c = item.first_name;
                        validationLine.Identification_Code__c = item.identification_code;
                        validationLine.Entity__c = item.entity;
                        validationLine.Type__c = item.type;
                        validationLine.Code_Qualifier__c = item.code_qualifier;
                        validationLine.Trace_Number__c = String.isNotBlank(item.trace_number) ? Decimal.valueOf(item.trace_number) : null;
                        validationLine.Payment_Type__c = item?.payment?.type;
                        validationLine.Payment_Qty__c = String.isNotBlank(item?.payment?.qty) ? Decimal.valueOf(item?.payment?.qty) : null;
                        validationLine.Payment_Amount__c = String.isNotBlank(item?.payment?.amount) ? Decimal.valueOf(item?.payment?.amount) : null;
                        validationLine.Payment_Amount_Type__c = item?.payment?.amount_type;
                        
                        validationLine.Service_Date_From__c = MiddlewareScheduleClass.parseStringToDate(item.service_date_from);
                        validationLine.Service_Date_To__c = MiddlewareScheduleClass.parseStringToDate(item.service_date_to);
                        validationLine.Unique_Reference__c = MiddlewareScheduleClass.getUniqueReferenceId();
                        
                        validationLineMap.put(validationLine.Unique_Reference__c, validationLine);
                        
                        
                        
                        // If there are any references, we need to process them as well....
                        if(item.references!= null && item.references.size() > 0){
                            List<Claim_Validation_Reference__c> ValidationReferenceList = new List<Claim_Validation_Reference__c>();
                            for(ValidationSchema.References reference: item.references){
                                Claim_Validation_Reference__c validationReference = new Claim_Validation_Reference__c();
                                validationReference.Reference_Number__c = reference.number_Z;
                                validationReference.Reference_Type__c = reference.type;
                                ValidationReferenceList.add(validationReference);
                            }
                            
                            dataMaps.ValidationReferences.put(validationLine.Unique_Reference__c, ValidationReferenceList);
                        }
                        
                        
                        // If there are any details, we need to process them as well....
                        if(item.details != null && item.details.size() > 0){
                            List<Claim_Validation_Line_Details__c> ValidationDetailList = new List<Claim_Validation_Line_Details__c>();
                            for(ValidationSchema.Details detail: item.details){
                                Claim_Validation_Line_Details__c validationDetail = new Claim_Validation_Line_Details__c();
                                validationDetail.Category_Code__c = detail.category_code;
                                validationDetail.Status_Code__c = detail.status_code;
                                validationDetail.Date__c = MiddlewareScheduleClass.parseStringToDate(detail.date_Z);
                                validationDetail.Amount__c = String.isNotBlank(detail.amount) ? Decimal.valueOf(detail.amount) : null;
                                validationDetail.Note__c = detail.note;
                                
                                ValidationDetailList.add(validationDetail);
                            }
                            
                            dataMaps.ValidationDetails.put(validationLine.Unique_Reference__c, ValidationDetailList);
                        }
                    }
                    dataMaps.validationLines.put(claimValidation.Unique_Reference__c, validationLineMap);
                }
            }
        }
        
        return dataMaps;
    }
    
    
    public static String getUniqueReferenceId(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
    
    Public Static Date parseStringToDate(String dateString){ //accepted Format YYYYMMDD only
        if(String.isNotBlank(dateString) && dateString.length() == 8){
            String year = dateString.substring(0, 4);
            String month = dateString.substring(4, 6);
            String day = dateString.substring(6, 8);
            
            return Date.valueOf(year+'-'+month+'-'+day);
        }
        return null;
    }
    
    
    Public Class validationData{
        Public Map<String, Claim_Validation__c> validations;
        Public Map<String, Map<String, Claim_Validation_Line__c>> validationLines;
        
        Public Map<String, List<Claim_Validation_Reference__c>> ValidationReferences;
        Public Map<String, List<Claim_Validation_Line_Details__c>> ValidationDetails;
        
        Public validationData(){
            validations = new Map<String, Claim_Validation__c>();
            validationLines = new Map<String, Map<String, Claim_Validation_Line__c>>();
            ValidationReferences = new Map<String, List<Claim_Validation_Reference__c>>();
            ValidationDetails = new Map<String, List<Claim_Validation_Line_Details__c>>();
        }
    }
}