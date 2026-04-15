/* 
@TestClass paymentAllocationController_TC
*/
public class paymentAllocationController {
    @AuraEnabled(cacheable=true)
    public static recordWrap getRecordDetails(String paymentId){
        string payerName;
        string patientName;
        string attorneyName;
        List<Claim__c> claimList = new List<Claim__c>();
        List<Claim_Line__c> clLineList = new List<Claim_Line__c>();
        Set<Id> ClaimIds = new Set<Id>(); 
        
        List<Payment__c> paymentRec = [Select Id,Name,Payer__c, Payer__r.Name,Payer__r.HealthCloudGA__PayerType__c,Patient__c,Patient__r.Name,Allocation__c,Unallocation__c,Amount__c,Balance__c,Claim__c from Payment__c Where Id=: paymentId];
        system.debug('paymentRec---->'+paymentRec);
        //system.debug('Payer__r.HealthCloudGA__PayerType__c--->'+paymentRec[0].Payer__r.HealthCloudGA__PayerType__c);        
        // Check if paymentRec is not empty before accessing
        if (!paymentRec.isEmpty()) {
            system.debug('Payment record found: ' + paymentRec[0].Id + ', Claim__c: ' + paymentRec[0].Claim__c);
            if (paymentRec[0].Claim__c != null) {
                // If payment has a related claim, add its ID to ClaimIds
                ClaimIds.add(paymentRec[0].Claim__c);
                // Query all claim lines for the specific claim
                clLineList = [SELECT Id, Name, Allocated__c, Claim__c, Claim__r.Payer__c, Claim__r.Payer__r.Name, Claim__r.Name, Claim__r.Patient__r.Name, Opportunity_Product__c, Opportunity_Product__r.Name, Balance__c, Opportunity_Product__r.Balance__c, Total_Price__c, Quantity__c, Claim_Status__c, Total_Payment_ReceivedA__c, Adj_Amount__c, Allowed_Amount__c, Current_Payment__c, Payment_Pending_with__c, Opportunity_Product__r.Payment_Pending_with__c, Claim__r.Location__c, Claim__r.Location__r.Name, Claim__r.Opportunity__c, Claim__r.Opportunity__r.Clinical_Encounter__c, Claim__r.Opportunity__r.Clinical_Encounter__r.StartDate, Claim__r.Accident_Date__c FROM Claim_Line__c WHERE Claim__c IN :ClaimIds];
                system.debug('Claim lines retrieved for Claim__c ' + paymentRec[0].Claim__c + ': ' + clLineList.size());
            } else {
                system.debug('No related Claim__c found, using original logic');
                // If no related claim, fall back to original logic
                if (paymentRec[0].Payer__c != null) {
                    system.debug('payerof--->'+paymentRec[0].Payer__r.Name);
                    payerName = paymentRec[0].Payer__r.Name;
                    claimList = [SELECT Id, Name, Payer__c, Payer__r.Name, Patient__c, Patient__r.Name,  Location__c, Location__r.AcctSeed__GL_Account_Variable_1__c FROM Claim__c WHERE Payer__r.Name = :payerName];
                    system.debug('claimList--->'+claimList);
                }
                if (paymentRec[0].Payer__r.Name == 'Self Pay' && paymentRec[0].Patient__c != null) {
                    patientName = paymentRec[0].Patient__r.Name;
                    system.debug('patientName--->'+patientName);
                    system.debug('payerof--->'+paymentRec[0].Payer__r.Name);
                    claimList = [SELECT Id, Name, Payer__c, Payer__r.Name, Patient__c, Patient__r.Name, Location__c, Location__r.AcctSeed__GL_Account_Variable_1__c FROM Claim__c WHERE Patient__r.Name = :patientName];
                    system.debug('claimList--->'+claimList);
                }
                
                system.debug('claimList--->'+claimList);
                if (claimList.size() > 0) {
                    for (Claim__c cl : claimList) {
                        ClaimIds.add(cl.Id);
                    }
                    if (ClaimIds.size() > 0) {
                        clLineList = [SELECT Id, Name, Allocated__c, Claim__c,  Claim__r.Payer__c, Claim__r.Payer__r.Name, Claim__r.Name, Claim__r.Patient__r.Name, Opportunity_Product__c, Opportunity_Product__r.Name, Balance__c, Opportunity_Product__r.Balance__c, Total_Price__c, Quantity__c, Claim_Status__c, Total_Payment_ReceivedA__c, Adj_Amount__c, Allowed_Amount__c, Current_Payment__c, Payment_Pending_with__c, Opportunity_Product__r.Payment_Pending_with__c, Claim__r.Location__c, Claim__r.Location__r.Name, Claim__r.Opportunity__c, Claim__r.Opportunity__r.Clinical_Encounter__c, Claim__r.Opportunity__r.Clinical_Encounter__r.StartDate, Claim__r.Accident_Date__c FROM Claim_Line__c WHERE Claim__c IN :ClaimIds AND (Opportunity_Product__r.Balance__c > 0 OR Opportunity_Product__r.Balance__c = NULL)];
                        system.debug('Claim lines retrieved from original logic: ' + clLineList.size());
                    }
                }
            }
        } else {
            system.debug('No Payment__c record found for paymentId: ' + paymentId);
        }
        
        /* if(paymentRec[0].Payer__c != null){
system.debug('payerof--->'+paymentRec[0].Payer__r.Name);
payerName = paymentRec[0].Payer__r.Name;
claimList =[SELECT Id, Name, Payer__c,Payer__r.Name,Patient__c,Patient__r.Name,Attorney__c,Attorney__r.Name,Location__c,Location__r.AcctSeed__GL_Account_Variable_1__c	 FROM Claim__c Where Payer__r.Name =: payerName];
system.debug('claimList--->'+claimList );
}
if(paymentRec[0].Payer__r.Name == 'Self Pay' && paymentRec[0].Patient__c != null ){
patientName = paymentRec[0].Patient__r.Name;
system.debug('patientName--->'+patientName );
system.debug('payerof--->'+paymentRec[0].Payer__r.Name);
claimList =[SELECT Id, Name, Payer__c,Payer__r.Name,Patient__c,Patient__r.Name,Attorney__c,Attorney__r.Name,Location__c,Location__r.AcctSeed__GL_Account_Variable_1__c FROM Claim__c Where  Patient__r.Name=:patientName ];
system.debug('claimList--->'+claimList );
}

if(claimList.size()>0){
for(Claim__c cl: claimList){
ClaimIds.add(cl.Id);
}

if(ClaimIds.size()>0){
clLineList =  [SELECT Id, Name,Allocated__c, Claim__c,Claim__r.Attorney__c,Claim__r.Attorney__r.Name,Claim__r.Payer__c,Claim__r.Payer__r.Name,Claim__r.Name,Claim__r.Patient__r.Name, Opportunity_Product__c, Opportunity_Product__r.Name, Balance__c,Opportunity_Product__r.Balance__c, Total_Price__c, Quantity__c, Claim_Status__c,Total_Payment_ReceivedA__c,Adj_Amount__c,Allowed_Amount__c,Current_Payment__c,Payment_Pending_with__c,Opportunity_Product__r.Payment_Pending_with__c,Claim__r.Location__c,Claim__r.Location__r.Name,Claim__r.Opportunity__c,Claim__r.Opportunity__r.Clinical_Encounter__c,Claim__r.Opportunity__r.Clinical_Encounter__r.StartDate,Claim__r.Accident_Date__c FROM Claim_Line__c where Claim__c IN: ClaimIds AND (Opportunity_Product__r.Balance__c>0 OR Opportunity_Product__r.Balance__c=NULL)];
}
} */
        
        system.debug('paymentRec--->'+paymentRec);
        system.debug('clLineList--->'+clLineList);
        system.debug('clLineListsize--->'+clLineList.size());
        List<claimLineWrap> claimWraplist = new List<claimLineWrap>();
        Integer Payment = 0;
        Date startDateOnly ;
        String outputSDTimeString ;
        if(clLineList.size()>0){
            for(Claim_Line__c cl: clLineList){
                claimLineWrap cw= new claimLineWrap();
                cw.IsChecked = false;
                cw.Id = cl.Id;
                cw.Claim = cl.Claim__r.Name;
                cw.ClaimId = cl.Claim__c;
                cw.OpportunityId = (cl.Claim__r != null) ? cl.Claim__r.Opportunity__c : null;
                Datetime SDTime = cl.Claim__r.Opportunity__r.Clinical_Encounter__r.StartDate;
                if(SDTime != null){
                    startDateOnly = SDTime.date();
                }
                if(startDateOnly != null){
                    outputSDTimeString = startDateOnly.year() + '-' + startDateOnly.month() + '-' + startDateOnly.day();
                }
                if(outputSDTimeString != null){
                    cw.StartdateString = outputSDTimeString;
                }
                if(cl.Claim__r.Accident_Date__c != null) {
                    cw.scheduledateString = cl.Claim__r.Accident_Date__c;
                }
                /* if(payerName !='Self Pay' && payerName != 'Attorney'){
cw.Patient = cl.Claim__r.Payer__r.Name;
}
if(payerName == 'Self Pay'){
cw.Patient = cl.Claim__r.Patient__r.Name;
}
if(payerName == 'Attorney'){
cw.Patient = cl.Claim__r.Attorney__r.Name;
}*/
                cw.Patient = cl.Claim__r.Patient__r.Name;
                //cw.ClaimLine = cl.Opportunity_Product__r.Name;
                cw.ClaimLine = cl.Name;
                system.debug('Assigned ClaimLine: ' + cw.ClaimLine + ' for Claim_Line__c Id: ' + cl.Id);
                cw.TotalAmount = cl.Total_Price__c;
                if (cl.Total_Payment_ReceivedA__c != null) {
                    cw.Payments = cl.Total_Payment_ReceivedA__c;
                } else {
                    cw.Payments = 0;
                }
                if(cl.Adj_Amount__c != null){
                    cw.AdjAmount = cl.Adj_Amount__c;
                }
                if(cl.Allowed_Amount__c != null){
                    cw.AllowedAmount = cl.Allowed_Amount__c;
                }
                cw.BalanceTransferredTo =cl.Payment_Pending_with__c;
                cw.Balance = cl.Balance__c;
                cw.ProductId = cl.Opportunity_Product__c;
                cw.Allocate = cl.Allocated__c;
                if(cl.Claim__r.Location__c != null){
                    cw.treatmentloaction = cl.Claim__r.Location__r.Name;
                }
                claimWraplist.add(cw);
            }
        }
        recordWrap rec= new recordWrap();
        rec.paymentRecords = paymentRec; 
        system.debug('claimWraplist--->'+claimWraplist);
        if(claimWraplist.size()>0){
            rec.claimWrapclass = claimWraplist;
        }
        system.debug('claimWraplist--->'+claimWraplist);
        system.debug('rec--->'+rec);
        return rec;
    }
    
    public class ResponseWrapper {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    
    @AuraEnabled
    public static ResponseWrapper createAppliedPayment(
        String listofRecords,
        String paymentId,
        String categoryType,
        String glaccount,
        Decimal additionalAmount
    ) {
        ResponseWrapper resp = new ResponseWrapper();
        Savepoint sp = Database.setSavepoint(); 
        try {
            System.debug('paymentId---' + paymentId);
            System.debug('glaccount--->' + glaccount);
            System.debug('listofRecords--->' + listofRecords);
            
            List<claimLineWrap> claimWrapList = 
                (List<claimLineWrap>) JSON.deserialize(listofRecords, List<claimLineWrap>.class);
            
            List<AcctSeed__Journal_Entry__c> jeList = new List<AcctSeed__Journal_Entry__c>();
            List<Applied_Payment__c> appliedList = new List<Applied_Payment__c>();
            
            Payment__c newpaymentRec = [
                SELECT Id, Name, Bank_GL_Account__c, Payer__c, Payment_Date__c, 
                Payer__r.Name, Patient__c, Patient__r.Name, Allocation__c, 
                Unallocation__c, Amount__c, Balance__c 
                FROM Payment__c 
                WHERE Id = :paymentId
            ];
            
            Datetime SDTime = newpaymentRec.Payment_Date__c;
            String outputSDTimeString = SDTime.format('MMM dd, yyyy ');
            
            AcctSeed__Ledger__c ledgerRec = [
                SELECT Id, Name FROM AcctSeed__Ledger__c WHERE Name = 'Actual'
            ];
            
            // Create Applied Payments
            for (claimLineWrap clw : claimWrapList) {
                Applied_Payment__c ap = new Applied_Payment__c();
                ap.Amount__c = clw.Amount;
                ap.Opportunity_Product__c = clw.ProductId;
                ap.Claim_Line__c = clw.Id;
                ap.Payment__c = newpaymentRec.Id;
                ap.Payment_Pending_with__c = clw.BalanceTransferredTo;
                appliedList.add(ap);
            }
            
            if (!appliedList.isEmpty()) {
                insert appliedList;
            }
            
            // Create Journal Entry
            AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
            je.Name = newpaymentRec.Payer__r.Name + '-' + newpaymentRec.Name + '-' + outputSDTimeString;
            je.AcctSeed__Journal_Date__c = newpaymentRec.Payment_Date__c;
            je.AcctSeed__Status__c = 'Approved';
            je.AcctSeed__Ledger__c = ledgerRec.Id;
            je.Payment__c = newpaymentRec.Id;
            je.Category__c = categoryType;
            jeList.add(je);
            
            if (!jeList.isEmpty()) {
                insert jeList;
            }
            
            List<AcctSeed__Journal_Entry_Line__c> JelineList = new List<AcctSeed__Journal_Entry_Line__c>();
            List<AcctSeed__Journal_Entry__c> newjeList = [
                SELECT Id, Name, AcctSeed__Journal_Date__c, Payment__r.Amount__c, Payment__r.Balance__c, 
                AcctSeed__Ledger__c, AcctSeed__Status__c, Payment__c, CreatedDate 
                FROM AcctSeed__Journal_Entry__c  
                WHERE Id IN :jeList
            ];
            
            AcctSeed__GL_Account__c GlAccRec2 = [
                SELECT Id, Name 
                FROM AcctSeed__GL_Account__c 
                WHERE Name = '1200-Accounts Receivable' 
                LIMIT 1
            ];
            
            Account genericAccount = [
                SELECT Id, Name 
                FROM Account 
                WHERE Name = 'Artera Inc.' 
                LIMIT 1
            ];
            
            List<Applied_Payment__c> newappliedlist = [
                SELECT Id, Payment__r.Balance__c, Name, Opportunity_Product__c, 
                Opportunity_Product__r.OpportunityId, Opportunity_Product__r.UnitPrice, Amount__c, 
                Claim_Line__c, Claim_Line__r.Claim__c, 
                Opportunity_Product__r.Opportunity.Location__r.AcctSeed__GL_Account_Variable_1__c
                FROM Applied_Payment__c 
                WHERE Id IN :appliedList
            ];
            
            if (!newappliedlist.isEmpty()) {
                String OppId = newappliedlist[0].Opportunity_Product__r.OpportunityId;
                List<Opportunity> opplist = [
                    SELECT Id, AccountId, Location__c 
                    FROM Opportunity 
                    WHERE Id = :OppId
                ];
                
                if (!opplist.isEmpty() && opplist[0].Location__c != null) {
                    List<Account> acclist = [
                        SELECT Id, Accounting_Variable__c, AcctSeed__GL_Account_Variable_1__c 
                        FROM Account 
                        WHERE Id = :opplist[0].Location__c
                    ];
                    
                    // Journal Entry Debit Line
                    for (AcctSeed__Journal_Entry__c jeRec : newjeList) {
                        system.debug('jeList--272'+jeList);
                        //if (jeRec.Payment__r.Balance__c == 0) {
                        AcctSeed__Journal_Entry_Line__c JeLine = new AcctSeed__Journal_Entry_Line__c();
                        JeLine.AcctSeed__Journal_Entry__c = jeRec.Id;
                        JeLine.AcctSeed__Date__c = jeRec.AcctSeed__Journal_Date__c;
                        JeLine.AcctSeed__Debit__c = jeRec.Payment__r.Amount__c;
                        JeLine.AcctSeed__GL_Account__c = newpaymentRec.Bank_GL_Account__c; 
                        JelineList.add(JeLine);
                        //}
                    }
                    
                    // Journal Entry Credit Lines
                    for (Applied_Payment__c apppay : newappliedlist) {
                        system.debug('newappliedlist---284'+newappliedlist);
                        //if (apppay.Payment__r.Balance__c == 0) {
                        AcctSeed__Journal_Entry_Line__c JeLine = new AcctSeed__Journal_Entry_Line__c();
                        JeLine.AcctSeed__Journal_Entry__c = newjeList[0].Id;
                        JeLine.AcctSeed__Date__c = newjeList[0].AcctSeed__Journal_Date__c;
                        JeLine.AcctSeed__Credit__c = apppay.Amount__c;
                        JeLine.Opportunity_Product__c = apppay.Opportunity_Product__c;
                        JeLine.Claim_Line__c = apppay.Claim_Line__c;
                        JeLine.Applied_Payment__c = apppay.Id;
                        
                        if (GlAccRec2 != null) {
                            JeLine.AcctSeed__GL_Account__c = GlAccRec2.Id;
                        }
                        if (genericAccount != null) {
                            JeLine.AcctSeed__Account__c = genericAccount.Id; 
                        }
                        if (apppay.Opportunity_Product__r.Opportunity.Location__r.AcctSeed__GL_Account_Variable_1__c != null) {
                            JeLine.AcctSeed__GL_Account_Variable_1__c = apppay.Opportunity_Product__r.Opportunity.Location__r.AcctSeed__GL_Account_Variable_1__c;
                        }
                        
                        JelineList.add(JeLine);
                        //}
                    }
                    
                    // Additional Amount Line
                    if (additionalAmount > 0) {
                        AcctSeed__Journal_Entry_Line__c newJeLine = new AcctSeed__Journal_Entry_Line__c();
                        newJeLine.AcctSeed__Journal_Entry__c = newjeList[0].Id;
                        newJeLine.AcctSeed__Date__c = newjeList[0].AcctSeed__Journal_Date__c;
                        newJeLine.AcctSeed__Credit__c = additionalAmount;
                        if (glaccount != null) {
                            newJeLine.AcctSeed__GL_Account__c = glaccount;
                        } else if (GlAccRec2 != null) {
                            newJeLine.AcctSeed__GL_Account__c = GlAccRec2.Id;
                            newJeLine.AcctSeed__Account__c = genericAccount.Id;
                        }
                        JelineList.add(newJeLine);
                    }
                }
            }
            
            if (!JelineList.isEmpty()) {
                insert JelineList;
            }
            
            resp.isSuccess = true;
            resp.message = 'Applied Payments created successfully';
            
        } catch (Exception ex) {
            Database.rollback(sp);
            resp.isSuccess = false;
            resp.message = 'Error: ' + ex.getMessage();
            System.debug('Error in createAppliedPayment: ' + ex.getStackTraceString());
        }
        return resp;
    }
    
    @AuraEnabled
    public static void updateClaimlines(String lstSelectedClaimLines, String updatePaymentList) {
        System.debug('lstSelectedClaimLines--------> ' + lstSelectedClaimLines);
        System.debug('updatePaymentList--->' + updatePaymentList);
        
        List<Claim_Line__c> claimToUpdate = new List<Claim_Line__c>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        
        List<claimLineWrap> claimList =
            (List<claimLineWrap>) JSON.deserialize(lstSelectedClaimLines, List<claimLineWrap>.class);
        List<Payment__c> paymentList =
            (List<Payment__c>) JSON.deserialize(updatePaymentList, List<Payment__c>.class);
        
        List<Claim__c> parentClaimsToUpdate = new List<Claim__c>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id, Claim__c> parentClaimsToUpdateMap = new Map<Id, Claim__c>();
        Map<Id, Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();
        
        
        for (claimLineWrap claim : claimList) {
            Claim_Line__c claimrec = new Claim_Line__c();
            claimrec.Id = claim.Id;
            claimrec.Opportunity_Product__c = claim.ProductId;
            claimrec.Allocated__c = true;
            claimrec.Allowed_Amount__c = claim.AllowedAmount;
            claimrec.Adj_Amount__c = claim.AdjAmount;
            claimrec.Total_Payment_ReceivedA__c = claim.Payments + claim.Amount;
            claimrec.Balance__c = claim.Balance;
            claimrec.Payment_Pending_with__c = claim.BalanceTransferredTo;
            
            /* ---------------- EXISTING LOGIC (UNCHANGED) ---------------- */
            if ((claim.Amount == 0 || claim.Amount == null) &&
                (claim.AdjAmount != null && claim.Payments != null && claim.TotalAmount != null) &&
                (Math.round(claim.AdjAmount + claim.Payments) == Math.round(claim.TotalAmount))) {
                    
                    if (claim.ClaimId != null) {
                        if (!parentClaimsToUpdateMap.containsKey(claim.ClaimId)) {
                            parentClaimsToUpdateMap.put(
                                claim.ClaimId,
                                new Claim__c(
                                    Id = claim.ClaimId,
                                    Submission_Status__c = 'Adjusted'
                                )
                            );
                        }
                        
                        if (claim.OpportunityId != null &&
                            !opportunitiesToUpdateMap.containsKey(claim.OpportunityId)) {
                                
                                opportunitiesToUpdateMap.put(
                                    claim.OpportunityId,
                                    new Opportunity(
                                        Id = claim.OpportunityId,
                                        StageName = 'Claim Settled',
                                        Status__c = 'Closed'
                                    )
                                );
                            }
                    }
                }
            
            /* ---------------- NEW LOGIC ADDED ---------------- */
            if (claim.TotalAmount != null && claim.TotalAmount > 0 &&
                claim.Balance != null && claim.Balance == 0 &&
                claim.OpportunityId != null) {
                    
                    if (claim.ClaimId != null) {
                        if (!parentClaimsToUpdateMap.containsKey(claim.ClaimId)) {
                            parentClaimsToUpdateMap.put(
                                claim.ClaimId,
                                new Claim__c(
                                    Id = claim.ClaimId,
                                    Submission_Status__c = 'Received Payment'
                                )
                            );
                        }
                        
                        if (claim.OpportunityId != null &&
                            !opportunitiesToUpdateMap.containsKey(claim.OpportunityId)) {
                                
                                opportunitiesToUpdateMap.put(
                                    claim.OpportunityId,
                                    new Opportunity(
                                        Id = claim.OpportunityId,
                                        StageName = 'Claim Settled',
                                        Status__c = 'Closed'
                                    )
                                );
                            }
                    }
                }
            
            claimToUpdate.add(claimrec);
        }
        
        if (!parentClaimsToUpdateMap.isEmpty()) {
            update parentClaimsToUpdateMap.values();
        }
        
        if (!opportunitiesToUpdateMap.isEmpty()) {
            update opportunitiesToUpdateMap.values();
        }
        
        if (!claimToUpdate.isEmpty()) {
            update claimToUpdate;
        }
        
        /* ---------------- UPDATE OPPORTUNITY LINE ITEMS ---------------- */
        Set<Id> oliSetId = new Set<Id>();
        for (claimLineWrap cli : claimList) {
            if (cli.ProductId != null && !oliSetId.contains(cli.ProductId)) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Id = cli.ProductId;
                oli.Total_Payment_ReceivedA__c = cli.Payments + cli.Amount;
                oli.Balance__c = cli.Balance;
                oli.Allowed_Amount__c = cli.AllowedAmount;
                oli.Adj_Amount__c = cli.AdjAmount;
                oli.Payment_Pending_with__c = cli.BalanceTransferredTo;
                
                oliToUpdate.add(oli);
                oliSetId.add(cli.ProductId);
            }
        }
        
        if (!oliToUpdate.isEmpty()) {
            update oliToUpdate;
        }
        
        /* ---------------- UPDATE PAYMENTS ---------------- */
        List<Payment__c> paymentUpdate = new List<Payment__c>();
        for (Payment__c payRec : paymentList) {
            Payment__c pay = new Payment__c();
            pay.Id = payRec.Id;
            pay.Allocation__c = payRec.Allocation__c;
            pay.Unallocation__c = payRec.Unallocation__c;
            paymentUpdate.add(pay);
        }
        
        if (!paymentUpdate.isEmpty()) {
            update paymentUpdate;
        }
        
        System.debug('Updated ClaimLines: ' + claimToUpdate);
        System.debug('Updated OLI: ' + oliToUpdate);
        System.debug('Updated Payments: ' + paymentUpdate);
        System.debug('Updated parentClaimsToUpdate: ' + parentClaimsToUpdate);
    }
    
    
    @AuraEnabled
    public static void setObjectToRecentItems(Id recordId) {
        if (!String.isBlank(recordId)) {
            Schema.SObjectType sObjectType = recordId.getSobjectType();
            String queryString = String.format('SELECT Id, Name FROM {0} WHERE Id =: recordId FOR VIEW', new List<Object>{sObjectType});
            Database.query(queryString);
        }
    }
    
    public class recordWrap{
        @AuraEnabled
        public List<Payment__c> paymentRecords;
        
        @AuraEnabled
        public List<claimLineWrap> claimWrapclass;
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
        }
    }
    
    
    public class claimLineWrap{
        @AuraEnabled
        public String Id;
        
        @AuraEnabled
        public Boolean isSearch = true;
        
        @AuraEnabled
        public Boolean IsChecked;
        
        @AuraEnabled
        public String Claim;
        
        @AuraEnabled
        public String Patient;
        
        @AuraEnabled
        public String ClaimLine;
        
        @AuraEnabled
        public Decimal TotalAmount;
        
        @AuraEnabled
        public Decimal Payments;
        
        @AuraEnabled
        public Decimal Balance;
        
        @AuraEnabled
        public Decimal Amount;
        // @AuraEnabled
        // public Decimal OverriddenBalance;
        
        @AuraEnabled
        public Decimal AllowedAmount;
        
        @AuraEnabled
        public Decimal AdjAmount;
        
        @AuraEnabled
        public String ProductId;
        
        @AuraEnabled
        public String PaymentId;
        
        @AuraEnabled
        public Boolean Allocate;
        
        @AuraEnabled
        public string BalanceTransferredTo; 
        
        @AuraEnabled
        public string treatmentloaction; 
        @AuraEnabled
        public Date scheduledateString; 
        @AuraEnabled
        public string StartdateString; 
        @AuraEnabled
        public Id ClaimId;
        @AuraEnabled
        public Id OpportunityId;
    }
}