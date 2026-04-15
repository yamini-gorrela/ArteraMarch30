/*
@TestClass createClaimFromOppContoller_Tc
*/
public class createClaimFromOppContoller {
    ApexPages.StandardSetController setCon;
    public List<Opportunity> newOppList { get; set; }
    public List<Opportunity> nullopplist { get; set; }
    public boolean toastValue{get;set;}
    public string currentRecordId {get; set;}
    public String errorMsg { get; set; }
    public Boolean errorValue { get; set; }
    public Boolean hideButton { get; set; }
    public Boolean hidenewlist { get; set; }
    public Boolean hidenulllist { get; set; }
    
    public createClaimFromOppContoller(ApexPages.StandardSetController controller) {
        setCon = controller;
        Id BillingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing Opportunity').getRecordTypeId();
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        Set<Id> oppIds = new Set<Id>();
        Set<Id> oppIdsWithExistingClaims = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Claim__c> claimList = new List<Claim__c> ();
        newOppList = new List<Opportunity>();
        nullopplist = new List<Opportunity>();
        errorValue = false;
        hideButton = true;
        hidenewlist = true;
        hidenulllist = true;
        if(setCon.getSelected().size() <= 0){
            errorValue = true;
            errorMsg = 'Please select atleast one single record';
            hideButton = true;
        }else{
            for(sObject opp:setCon.getSelected()){
                oppIds.add(opp.Id);
            }
            if(oppIds.size()>0){
                oppList = [Select Id,Name,Claim_Indicator_Code__c,Payer__r.Submitter_Id__c,AccountId,status__c,RecordTypeId,RecordType.Name,Payer__c,Payer__r.Name,Provider__c,Provider__r.Name,Subscriber__c,Subscriber__r.Name,Location__c,Location__r.Name,Service_Date__c,Sales_Order__c,Sales_Order__r.Contact__c,Sales_Order__r.Contact__r.Name,Sales_Order__r.Contact__r.NPI__c,Sales_Order__r.Contact__r.FirstName,Sales_Order__r.Contact__r.LastName,Sales_Order__r.Contact__r.MailingCity,Sales_Order__r.Contact__r.MailingStateCode,Sales_Order__r.Contact__r.MailingStreet,Sales_Order__r.Contact__r.MailingState,Sales_Order__r.Contact__r.MailingPostalCode,Sales_Order__r.Patient_Name1__c,
                           Account.FirstName,Account.LastName,Account.PersonBirthdate,Location__r.Phone,Location__r.Full_Name__pc,Subscriber__r.FirstName,Subscriber__r.LastName,Subscriber__r.BillingCity,Subscriber__r.BillingState,Subscriber__r.BillingStreet,Subscriber__r.BillingPostalCode,Subscriber__r.BillingStateCode,Account.BillingCity,Account.BillingState,
                           Account.HealthCloudGA__Gender__pc,Account.BillingStreet,Account.BillingPostalCode,Account.BillingStateCode,Payer__r.Payer_Code__c,Provider__r.City,Provider__r.State,Provider__r.Street,Provider__r.PostalCode,Provider__r.FirstName,Provider__r.LastName,Provider__r.NPI__c,Provider__r.Taxonomy_Code__c,Provider__r.Phone,
                           Payer_Type__c,Account.PersonGender,Type_of_Insurance__c from Opportunity where Id IN: oppIds];
            }
            
            if(oppIds.size()>0){
                claimList = [SELECT Id, Opportunity__c FROM Claim__c WHERE Opportunity__c IN :oppIds];
            }
            
            
            if(claimList.size()>0){
                for (Claim__c claim : claimList) {
                    oppIdsWithExistingClaims.add(claim.Opportunity__c);
                }
            }
            if(oppList.size()>0){
                for (Opportunity opp : oppList) {
                    if (opp.RecordTypeId != BillingRecordTypeId) {
                        nullopplist.add(opp);
                        errorMsg = 'Record Type must be Billing.';
                        errorValue = true;
                    } else if (opp.Service_Date__c != null && opp.Service_Date__c > Date.today()) {
                        nullopplist.add(opp);
                        errorMsg = 'Service Date cannot be in the future.';
                        errorValue = true;
                    } else if (opp.Status__c != 'Ready for Claim') {
                        nullopplist.add(opp);
                        errorMsg = 'Status must be Ready for Claim.';
                        errorValue = true;
                    } else if (opp.Payer__c == null || opp.Provider__c == null || opp.Subscriber__c == null || opp.Location__c == null || opp.Service_Date__c == null) {
                        nullopplist.add(opp);
                        errorMsg = 'Mandatory fields (Payer, Provider, Subscriber, Location, Service Date) must not be empty.';
                        errorValue = true;
                    } else if (oppIdsWithExistingClaims.contains(opp.Id)) {
                        nullopplist.add(opp);
                        errorMsg = 'Claim already exists for this Billing Opportunity.';
                        errorValue = true;
                    } else {
                        newOppList.add(opp);
                    }
                }
            }
            
            if (!newOppList.isEmpty()) {
                hidenewlist = false;
                hideButton = false;
            }
            
            if (!nullopplist.isEmpty()) {
                hidenulllist = false;
            }
        }
    }
    
    public void createClaims(){
        Set<Id> oppIds = new Set<Id>();
        Set<Id>oppCE_Ids = new Set<Id>();
        Map<Id,Id> oppClaimMap = new Map<Id,Id>();
        Map<Id,String> oppClaimDiagnosisMap = new Map<Id,String>();
        Map<Id,Id> oppCEMap = new Map<Id,Id>();
        Map<String,String> oppIdClaimSubmittedto = new Map<String,String>();
        Map<Id,Date> oppIdClaimServicedate= new Map<Id,Date>();
        List<OpportunityLineItem> oppLineitemsList = new List<OpportunityLineItem>();
        List<Claim__c> claimList = new List<Claim__c>();
        List<Claim_Line__c> clLineList = new List<Claim_Line__c>();
        List<MemberPlan> memberplanlist = new List<MemberPlan>();
        List<MemberPlan> subscribermemberplanlist = new List<MemberPlan>();
        Map<String, MemberPlan> patientIdToMemberPlanMap = new Map<String, MemberPlan>();
        Set<Id> PayerIds = new Set<Id>();
        Set<Id> patientIds = new Set<Id>();
        system.debug('newOppList---->'+ newOppList);
        if(newOppList.size()>0){
            for(Opportunity opp:newOppList){
                if(opp.Payer__c!=null){
                    PayerIds.add(opp.Payer__c);  
                }
                if(opp.AccountId!=null){
                    patientIds.add(opp.AccountId);  
                }
            }
            if (!patientIds.isEmpty() && !PayerIds.isEmpty()) {
                memberplanlist =[Select Id,PayerId,RelationshipToSubscriber,MemberId,MemberNumber,Status from MemberPlan where MemberId IN:patientIds AND Status='Active' AND PayerId IN:PayerIds ORDER BY CreatedDate DESC];
            }
            for (MemberPlan mp : memberplanlist) {
                if (!patientIdToMemberPlanMap.containsKey(mp.MemberId+'-'+mp.PayerId)) {
                    patientIdToMemberPlanMap.put(mp.MemberId+'-'+mp.PayerId, mp);
                }
            }
            if (!patientIds.isEmpty()) {
                subscribermemberplanlist = [Select Id,SubscriberId,Status from MemberPlan where SubscriberId IN:patientIds AND Status='Active' ORDER BY CreatedDate DESC];
            }
            if(newOppList.size()>0){
                system.debug('newOppList===='+newOppList);
                for(Opportunity opp:newOppList){
                    Claim__c cl = new Claim__c();
                    cl.Opportunity__c = opp.Id;
                    cl.Payer_Type__c = opp.Payer_Type__c;
                    cl.Type_of_Insurance__c = opp.Type_of_Insurance__c;
                    cl.Claim_Indicator_Code__c = opp.Claim_Indicator_Code__c;
                    //cl.Type_of_Insurance__c = 'Other';
                    cl.Submitted_Date__c = system.today();
                    cl.Accident_Date__c	= opp.Service_Date__c;
                    cl.Service_Date__c = opp.Service_Date__c;
                    if (patientIdToMemberPlanMap.containsKey(opp.AccountId+'-'+opp.Payer__c)) {
                        cl.Insureds_ID_Number__c = patientIdToMemberPlanMap.get(opp.AccountId+'-'+opp.Payer__c).MemberNumber;
                    }
                    if(opp.Payer__r.Name == 'Self Pay'){
                        cl.Submitted_To__c = 'Patient';
                    }else{
                        cl.Submitted_To__c = 'Insurance';
                    }
                    if(opp.Payer__c!=null){
                        cl.Payer__c = opp.Payer__c;
                    }
                    cl.Submitter_Id__c = opp.Payer__r.Submitter_Id__c;
                    if(opp.Sales_Order__r.Contact__r.Name!=null && opp.Sales_Order__r.Contact__r.NPI__c!=null){
                        cl.Original_Ref_No__c = opp.Sales_Order__r.Contact__r.Name+'-'+opp.Sales_Order__r.Contact__r.NPI__c;
                    }
                    if(opp.Sales_Order__r.Contact__r.Name!=null){
                        cl.Referring_Provider_Name__c = opp.Sales_Order__r.Contact__r.LastName;  
                    }
                    if(opp.Sales_Order__r.Contact__r.FirstName!=null){
                        cl.Referring_Provider_First_Name__c = opp.Sales_Order__r.Contact__r.FirstName;  
                    }
                    if(opp.Sales_Order__r.Contact__r.NPI__c!=null){
                        cl.Referring_Provider_NPI__c = opp.Sales_Order__r.Contact__r.NPI__c;  
                    }
                    if(opp.Sales_Order__r.Contact__r.MailingCity!=null){
                        cl.Referring_Provider_Address_City__c = opp.Sales_Order__r.Contact__r.MailingCity;  
                    }
                    if(opp.Sales_Order__r.Contact__r.MailingStreet!=null){
                        cl.Referring_Provider_Address_Street__c = opp.Sales_Order__r.Contact__r.MailingStreet;  
                    }
                    if(opp.Sales_Order__r.Contact__r.MailingState!=null){
                        cl.Referring_Provider_Address_State__c = opp.Sales_Order__r.Contact__r.MailingStateCode;  
                    }
                    if(opp.Sales_Order__r.Contact__r.MailingPostalCode!=null){
                        cl.Referring_Provider_Address_Zip_Code__c = opp.Sales_Order__r.Contact__r.MailingPostalCode;  
                    }
                    if (patientIdToMemberPlanMap.containsKey(opp.AccountId+'-'+opp.Payer__c)) {
                        cl.X1a_Member_ID__c = patientIdToMemberPlanMap.get(opp.AccountId+'-'+opp.Payer__c).Id;
                    }
                    if(opp.Sales_Order__r.Patient_Name1__c!=null){
                        cl.Patient__c = opp.Sales_Order__r.Patient_Name1__c;
                    }
                    cl.Patients_First_Name__c = opp.Account.FirstName;
                    cl.Patients_Last_Name__c = opp.Account.LastName;
                    cl.Patients_Birth_Date__c = opp.Account.PersonBirthdate;
                    cl.Sex__c = opp.Account.PersonGender;
                    cl.X31_Signature_of_Physician_or_Supplier__c = 'ARTERA INC.';
                    cl.X32_Service_Phone__c	= opp.Location__r.Phone;
                    //cl.X33_Service_Provider_Name__c = opp.Location__r.Full_Name__pc;
                    cl.Insureds_First_Name__c = opp.Subscriber__r.FirstName;
                    cl.Insureds_Last_Name__c = opp.Subscriber__r.LastName;
                    cl.Location__c = opp.Location__c;
                    cl.Insureds_Address_City__c = opp.Subscriber__r.BillingCity;
                    cl.Insureds_Address_State__c = opp.Subscriber__r.BillingStateCode;
                    cl.Insureds_Address_Street__c = opp.Subscriber__r.BillingStreet;
                    cl.Insureds_Address_Zip_Code__c = opp.Subscriber__r.BillingPostalCode;
                    cl.Patients_Address_City__c = opp.Account.BillingCity;
                    cl.Patients_Address_State__c = opp.Account.BillingStateCode;
                    cl.Patients_Address_Street__c = opp.Account.BillingStreet;
                    cl.Patients_Address_Zip_Code__c = opp.Account.BillingPostalCode;
                    if (patientIdToMemberPlanMap.containsKey(opp.AccountId+'-'+opp.Payer__c)) {
                        cl.Patients_relationship_to_the_insured__c = patientIdToMemberPlanMap.get(opp.AccountId+'-'+opp.Payer__c).RelationshipToSubscriber;
                    }
                    cl.Payer_Code__c = opp.Payer__r.Payer_Code__c;
                    cl.Rendering_Provider_City__c = 'Jacksonville';
                    cl.Rendering_Provider_State__c = 'FL';
                    cl.Rendering_Provider_Street__c = '6800 Southpoint Pkwy Ste 950';
                    cl.Rendering_Provider_Zip__c = '322168203';
                    cl.Rendering_Provider_First_Name__c = opp.Provider__r.FirstName;
                    //cl.Rendering_Provider_Name__c = opp.Location__r.Full_Name__pc;
                    cl.Rendering_Provider_NPI__c = '1285363010';
                    cl.Rendering_Provider_Taxonomy_Code__c = '291U00000X';
                    cl.Rendering_Provider_Phone__c = opp.Location__r.Phone;
                    claimList.add(cl);
                    oppIds.add(opp.Id);
                }
                system.debug('claimList---->'+claimList);
            }
            if(claimList.size()>0){
                insert claimList;
            }
            if(oppIds.size()>0){
                oppLineitemsList = [Select Id,OpportunityId,Opportunity.Sales_Order__c,Opportunity.Service_Date__c,Opportunity.Sales_Order__r.Contact__c,Opportunity.Sales_Order__r.Contact__r.NPI__c,Diag_1__c,Diag_2__c,Diag_3__c,Diag_4__c,ProductCode,ListPrice,TotalPrice,Adj_Amount__c,Allowed_Amount__c,Total_Payment_ReceivedA__c,Balance__c,Payment_Pending_with__c,Claim_Status__c from OpportunityLineItem where OpportunityId IN: oppIds];
            }   
            if(claimList.size()>0){
                toastValue = true;
                for(Claim__c cl: claimList){
                    if(cl.Opportunity__c!=null){
                        oppClaimMap.put(cl.Opportunity__c, cl.Id);
                    }
                    
                    if(cl.Opportunity__c!=null && cl.Submitted_To__c!=null){
                        oppIdClaimSubmittedto.put(cl.Opportunity__c,cl.Submitted_To__c);
                    }
                    if(cl.Opportunity__c!=null && cl.Service_Date__c!=null){
                        oppIdClaimServicedate.put(cl.Opportunity__c,cl.Service_Date__c);
                    }
                }
            }
            List<CodeSet> codeSetList = [SELECT Id, Name FROM CodeSet WHERE Name = 'C61' LIMIT 1];
            
            if(oppLineitemsList.size()>0){
                for(OpportunityLineItem oppLine:oppLineitemsList){
                    Claim_Line__c clLine= new Claim_Line__c();
                    clLine.Claim__c = oppClaimMap.get(oppLine.OpportunityId);
                    clLine.Opportunity_Product__c = oppLine.Id;
                    clLine.Date_from_of_Service__c = oppLine.Opportunity.Service_Date__c;
                    clLine.Date_to_of_Service__c = oppLine.Opportunity.Service_Date__c;
                    clLine.Diag_1__c=codeSetList[0].Id;
                    clLine.Diag_2__c=oppLine.Diag_2__c;
                    clLine.Product_Code__c=oppLine.ProductCode;
                    clLine.List_Price__c=oppLine.ListPrice;
                    clLine.Total_Price__c=oppLine.TotalPrice;
                    clLine.Allowed_Amount__c=oppLine.Allowed_Amount__c;
                    clLine.Adj_Amount__c=oppLine.Adj_Amount__c;
                    clLine.Payment_Pending_with__c=oppLine.Payment_Pending_with__c;
                    clLine.Total_Payment_ReceivedA__c=oppLine.Total_Payment_ReceivedA__c;
                    clLine.Balance__c=oppLine.Balance__c;
                    clLine.Place_of_Service__c	= '81';
                    clLine.CPT_HCPCS__c = '0376U';
                    clLine.Sales_Price__c	=1725;
                    clLine.Quantity__c = 1;
                    if(oppLine.Opportunity.Sales_Order__r.Contact__r.NPI__c != null){
                        //clLine.Rendering_Provider_ID_NPI__c = oppLine.Opportunity.Sales_Order__r.Contact__r.NPI__c;
                    }
                    //clLine.Modifier_s__c ='NA';
                    //clLine.Diagnosis_pointers__c = 'A';
                    clLineList.add(clLine);
                    oppLine.Claim_Status__c = 'Ready for Claim';
                    oppLine.Payment_Pending_with__c= oppIdClaimSubmittedto.get(oppLine.OpportunityId);
                }
            }
            if(clLineList.size()>0){
                insert clLineList;
                update oppLineitemsList;
            }
            system.debug('ToastValue---->'+ toastValue);
        }
    }
    
    public pageReference methodOne(){
        Schema.DescribeSObjectResult result = Opportunity.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o');
        pageRef.setRedirect(true);
        return pageRef ;
    }
}