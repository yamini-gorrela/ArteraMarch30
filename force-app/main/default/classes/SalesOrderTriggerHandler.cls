public class SalesOrderTriggerHandler {
    
    public static Map<Id, MemberPlan> validMemberPlans = new Map<Id, MemberPlan>();
    private static final Set<String> SPECIAL_PAYER_NAMES = new Set<String>{
        '[Payer] Bay Pines VA',
            '[Payer] CorePlus',
            '[Payer] Durham VA Health System',
            '[Payer] Rhenium Oncotest',
            '[Payer] Rocky Mountain Regional VA Medical Center',
            '[Payer] VA Caribbean Healthcare System'
            };
                
                public static void validatePayerConditions(List<Sales_Order__c> newSalesOrders, Map<Id, Sales_Order__c> oldSalesOrderMap) {
                    System.debug('Starting validation for payer conditions.');
                    
                    Set<Id> patientIds = new Set<Id>();
                    
                    // Collect Patient IDs needing validation
                    for (Sales_Order__c salesOrder : newSalesOrders) {
                        if (salesOrder.Patient_Name1__c != null && 
                            salesOrder.Ready_for_processing__c == TRUE && 
                            oldSalesOrderMap.containsKey(salesOrder.Id) && 
                            oldSalesOrderMap.get(salesOrder.Id).Ready_for_processing__c != TRUE) {
                                patientIds.add(salesOrder.Patient_Name1__c);
                            }
                    }
                    
                    // Query all Member Plans in a single ordered query
                    Map<Id, List<MemberPlan>> memberPlanMap = new Map<Id, List<MemberPlan>>();
                    if (!patientIds.isEmpty()) {
                        for (MemberPlan mp : [
                            SELECT Id, Status, MemberId, PayerId, Payer_Type__c, VerificationStatus, 
                            SubscriberId, PrimarySecondaryTertiary, Insurance_Verification_Status__c,
                            Type_of_Insurance__c,Claim_Indicator_Code__c, CreatedDate
                            FROM MemberPlan 
                            WHERE MemberId IN :patientIds
                            ORDER BY CreatedDate DESC
                        ]) {
                            if (!memberPlanMap.containsKey(mp.MemberId)) {
                                memberPlanMap.put(mp.MemberId, new List<MemberPlan>());
                            }
                            memberPlanMap.get(mp.MemberId).add(mp);
                        }
                    }
                    
                    // Query billing addresses for related member accounts
                    Map<Id, Account> memberAccounts = new Map<Id, Account>();
                    if (!patientIds.isEmpty()) {
                        memberAccounts = new Map<Id, Account>([
                            SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                            FROM Account
                            WHERE Id IN :patientIds
                        ]);
                    }
                    
                    // Validate each Sales Order
                    for (Sales_Order__c salesOrder : newSalesOrders) {
                        if (salesOrder.Ready_for_processing__c == TRUE && 
                            oldSalesOrderMap.containsKey(salesOrder.Id) && 
                            oldSalesOrderMap.get(salesOrder.Id).Ready_for_processing__c != TRUE) {
                                
                                List<MemberPlan> plans = memberPlanMap.get(salesOrder.Patient_Name1__c);
                                
                                if (plans == null || plans.isEmpty()) {
                                    salesOrder.addError('No Member Plan found for the patient. Please ensure a valid Member Plan is associated.');
                                    continue;
                                }
                                
                                // Updated logic: prioritize active-verified Primary > Secondary > Tertiary
                                MemberPlan primaryPlan = null;
                                MemberPlan secondaryPlan = null;
                                MemberPlan tertiaryPlan = null;
                                
                                for (MemberPlan mp : plans) {
                                    if (mp.Status == 'Active' && mp.VerificationStatus == 'Active - Verified') {
                                        if (mp.PrimarySecondaryTertiary == 'Primary' && primaryPlan == null) {
                                            primaryPlan = mp;
                                        } else if (mp.PrimarySecondaryTertiary == 'Secondary' && secondaryPlan == null) {
                                            secondaryPlan = mp;
                                        } else if (mp.PrimarySecondaryTertiary == 'Tertiary' && tertiaryPlan == null) {
                                            tertiaryPlan = mp;
                                        }
                                    }
                                }
                                
                                MemberPlan selectedVerifiedPlan;
                                if (primaryPlan != null) {
                                    selectedVerifiedPlan = primaryPlan;
                                } else if (secondaryPlan != null) {
                                    selectedVerifiedPlan = secondaryPlan;
                                } else if (tertiaryPlan != null) {
                                    selectedVerifiedPlan = tertiaryPlan;
                                } else {
                                    selectedVerifiedPlan = null;
                                }
                                
                                if (selectedVerifiedPlan != null) {
                                    // Additional validation for non-'Client' insurance
                                    if (selectedVerifiedPlan.Type_of_Insurance__c != 'Client') {
                                        Account acc = memberAccounts.get(selectedVerifiedPlan.MemberId);
                                        if (acc == null || 
                                            String.isBlank(acc.BillingStreet) || 
                                            String.isBlank(acc.BillingCity) || 
                                            String.isBlank(acc.BillingState) || 
                                            String.isBlank(acc.BillingPostalCode) || 
                                            String.isBlank(acc.BillingCountry)) {
                                                salesOrder.addError('The Member Account must have a complete Billing Address for non-Client insurance (Street, City, State, Zip, Country).');
                                                continue;
                                            }
                                    }
                                    
                                    validMemberPlans.put(salesOrder.Id, selectedVerifiedPlan);
                                    System.debug('Selected Verified Plan --> ' + selectedVerifiedPlan);
                                } else {
                                    Boolean hasActiveOnly = false;
                                    for (MemberPlan mp : plans) {
                                        if (mp.Status == 'Active') {
                                            hasActiveOnly = true;
                                            break;
                                        }
                                    }
                                    if (hasActiveOnly) {
                                        salesOrder.addError('At least one Active Member Plan must be Verified (Active - Verified).');
                                    } else {
                                        salesOrder.addError('No Active Member Plan found for this patient.');
                                    }
                                }
                            }
                    }
                }
    
    
    public static void createBillingOpportunities(List<Sales_Order__c> newSalesOrders, Map<Id, Sales_Order__c> oldSalesOrderMap) {
        System.debug('Starting creation of Billing Opportunities.');
        
        List<Sales_Order__c> finishedSalesOrders = new List<Sales_Order__c>();
        for (Sales_Order__c salesOrder : newSalesOrders) {
            Sales_Order__c oldSalesOrder = oldSalesOrderMap.get(salesOrder.Id);
            if (salesOrder.Ready_for_processing__c == TRUE && 
                (oldSalesOrder == null || oldSalesOrder.Ready_for_processing__c != TRUE)) {
                    finishedSalesOrders.add(salesOrder);
                }
        }
        
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
        //List<Product2> productList = [SELECT Id FROM Product2 WHERE Name = '0376U' LIMIT 1];
        Product2 product = [
            SELECT Id FROM Product2 WHERE Name = '0376U' LIMIT 1
        ];
        PricebookEntry standardPBE = [
            SELECT Id, UnitPrice, Self_Pay_Amount__c
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
            AND IsActive = TRUE
            LIMIT 1
        ];
        
        Id billingOpportunityRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Billing_Opportunity' LIMIT 1].Id;
        List<Account> selfPayAccountList = [SELECT Id FROM Account WHERE Name = 'Self Pay' LIMIT 1];
        List<User> userrecList = [SELECT Id FROM User WHERE Name = 'Artera' LIMIT 1];
        List<Account> accrecList = [SELECT Id FROM Account WHERE Name = 'Artera Inc.' LIMIT 1];
        
        for (Sales_Order__c salesOrder : finishedSalesOrders) {
            MemberPlan plan = validMemberPlans.get(salesOrder.Id);
            System.debug('plan--->'+plan);
            Id payerId = null;
            Id subscriberId = null;
            String payerType = null;
            String insuranceType = null;
            String ClaimIndicatorCode = null;
            
            if (plan != null) {
                payerType = plan.Payer_Type__c;
                insuranceType = plan.Type_of_Insurance__c;
                subscriberId = plan.SubscriberId;
                ClaimIndicatorCode = plan.Claim_Indicator_Code__c;
                
                payerId = (payerType == 'Patient') ?
                    (selfPayAccountList.isEmpty() ? null : selfPayAccountList[0].Id) :
                plan.PayerId;
            }
            
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.Name = salesOrder.Name + '-' + salesOrder.Patient_Name1__r.Name + '- Billing Opportunity';
            newOpportunity.AccountId = salesOrder.Patient_Name1__c;
            newOpportunity.CloseDate = System.today().addDays(30);
            newOpportunity.Service_Date__c = salesOrder.DOS__c;
            newOpportunity.StageName = 'Qualification';
            newOpportunity.RecordTypeId = billingOpportunityRecordTypeId;
            newOpportunity.Sales_Order__c = salesOrder.Id;
            newOpportunity.HealthCloudGA__ReferringPractitioner__c = salesOrder.Contact__c;
            newOpportunity.Payer__c = payerId;
            newOpportunity.Payer_Type__c = payerType;
            newOpportunity.Type_of_Insurance__c = insuranceType;
            newOpportunity.Subscriber__c = subscriberId;
            newOpportunity.Claim_Indicator_Code__c = ClaimIndicatorCode;
            if (!userrecList.isEmpty()) newOpportunity.Provider__c = userrecList[0].Id;
            if (!accrecList.isEmpty()) newOpportunity.Location__c = accrecList[0].Id;
            
            opportunitiesToInsert.add(newOpportunity);
        }
        
        if (!opportunitiesToInsert.isEmpty()) {
            insert opportunitiesToInsert;
        }
        Set<Id> payerIds = new Set<Id>();
        for (Opportunity o : opportunitiesToInsert) if (o.Payer__c != null) payerIds.add(o.Payer__c);
        
        Map<Id, Account> payerMap = payerIds.isEmpty()
            ? new Map<Id, Account>()
            : new Map<Id, Account>([
                SELECT Id, Name, Price_Book__c
                FROM Account
                WHERE Id IN :payerIds
            ]);
        
        Map<Id, PricebookEntry> specialPBEMap = new Map<Id, PricebookEntry>();
        
        for (PricebookEntry pbe : [
            SELECT Id, UnitPrice, Pricebook2Id
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
            AND IsActive = TRUE
        ]) {
            specialPBEMap.put(pbe.Pricebook2Id, pbe);
        }
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (Opportunity opp : opportunitiesToInsert) {
            PricebookEntry selectedPBE = standardPBE;
            Decimal unitPrice = standardPBE.UnitPrice;
            
            Account payer = payerMap.get(opp.Payer__c);
            
            if (payer != null &&
                SPECIAL_PAYER_NAMES.contains(payer.Name) &&
                payer.Price_Book__c != null &&
                specialPBEMap.containsKey(payer.Price_Book__c)) {
                    
                    selectedPBE = specialPBEMap.get(payer.Price_Book__c);
                    unitPrice = selectedPBE.UnitPrice;
                    
                } else if (opp.Payer_Type__c == 'Patient' &&
                           standardPBE.Self_Pay_Amount__c != null) {
                               
                               unitPrice = standardPBE.Self_Pay_Amount__c;
                           }
            
            olis.add(new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = product.Id,
                Quantity = 1,
                UnitPrice = unitPrice,
                PricebookEntryId = selectedPBE.Id
            ));
        }
        
        insert olis;
    }
}