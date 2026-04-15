@isTest
public class paymentAllocationController_TC {
    @isTest
    Public static void testRunning(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;         
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        
        Id payerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        Id patientId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        AcctSeed__Accounting_Variable__c accvar = new AcctSeed__Accounting_Variable__c();
        accvar.Name = 'test1';
        accvar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accvar;
        
        Account acc = new Account();
        acc.Name = 'Self Pay';
        acc.Accounting_Variable__c = accvar.Id;
        acc.RecordTypeId =payerId;
        
        insert acc;
        
        Account acc1 = new Account();
        acc1.LastName = 'test';
        acc1.Accounting_Variable__c = accvar.Id;
        acc1.RecordTypeId =patientId;
        insert acc1;
        Account acc4 = new Account();
        acc4.LastName = 'Artera Inc.';
        acc4.Accounting_Variable__c = accvar.Id;
        acc4.RecordTypeId =patientId;
        insert acc4;
        
        Account acc2 = new Account();
        acc2.Name = 'Attorney';
        acc2.RecordTypeId =payerId;
        acc2.Accounting_Variable__c = accvar.Id;
        insert acc2;
        
        ClinicalEncounter CE = new ClinicalEncounter();
        CE.Status = 'Arrived';
       /* CE.Assessment__c = 'testAss';
        CE.Procedure__c = 'testpro';
        CE.Objective__c = 'testobj';
        CE.Subjective__c = 'testsub';*/
        CE.Category = 'Ambulatory';
        CE.StartDate =  System.today();
        insert CE;
        
        Opportunity opp = new Opportunity();
        Id OpprecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing Opportunity').getRecordTypeId();
        opp.RecordTypeId = OpprecordTypeId;
        opp.Name = 'Jack Sparrow - CE-0008 - Billing';
        opp.Clinical_Encounter__c = CE.Id;
        opp.StageName ='Recommendation';
        opp.Status__c = 'Submitted';
        opp.CloseDate = system.today();
        opp.Location__c = acc.Id;
        opp.AccountId = acc1.Id;
        opp.Provider__c = uu.Id;
        //opp.Provider__r.FirstName = 'ABC';
        insert opp;
        
        Account acc3 = new Account();
        acc3.LastName = 'test';
        acc3.Accounting_Variable__c = accvar.Id;
        acc3.RecordTypeId =patientId;
        insert acc3;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true);
        Update standardPricebook;
        
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        System.assertEquals(true, standardPricebook.IsStandard);
        
        Product2 prod = new Product2();
        prod.Name = 'Fixed Fee';
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = standardPricebook.Id;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineitem.Product2Id = prod.Id;
        oppLineItem.UnitPrice = 7000;  
        oppLineItem.Quantity = 5;
        oppLineItem.Total_Payment_ReceivedA__c = 100;
        oppLineItem.Balance__c = 100;
        insert oppLineItem;
       
        
        Payment__c pay = new Payment__c();
        pay.Amount__c = 1000;
        pay.Allocation__c = 1000;
        pay.Payer__c =acc.Id;
        pay.Patient__c = acc1.Id;
        pay.Payment_Date__c = system.today();
        insert pay;
        
        Payment__c pay1 = new Payment__c();
        pay1.Amount__c = 1000;
        pay1.Payer__c =acc2.Id;
        pay1.Patient__c = acc1.Id;
        insert pay1;
        
         Payment__c pay3 = new Payment__c();
        pay3.Amount__c = 1000;
        pay3.Allocation__c = 1000;
        pay3.Payer__c =acc2.Id;
        pay3.Patient__c = acc1.Id;
        insert pay3;
        
        Claim__c claim = new Claim__c();
        claim.Payer__c = pay.Payer__c;
        system.debug('pay'+pay.Payer__c);
        system.debug('patet'+pay.Patient__c);
        claim.Opportunity__c = opp.Id;
        claim.Submitted_Date__c = System.today();
        claim.Submitted_To__c = 'Insurance';
        claim.Patient__c =pay.Patient__c;
        claim.Rendering_Provider_First_Name__c = opp.Provider__r.FirstName;
        insert claim;
        
        List<Claim__c> claimList =[SELECT Id, Name, Payer__c,Payer__r.Name,Patient__c,Patient__r.Name,Attorney__c,Attorney__r.Name FROM Claim__c where Id=:claim.Id];
        System.debug('cllist'+claimList);
        system.debug('payerId'+claimList[0].Payer__c);
        system.debug('patientId'+claimList[0].Patient__c);
        system.debug('payername--'+claimList[0].Payer__r.Name);
        system.debug('patientname--'+claimList[0].Patient__r.Name);
        
        List<Claim_Line__c> claimlinelist = new List<Claim_Line__c>();
        Claim_Line__c clline1 = new Claim_Line__c();
        clline1.Claim__c = claim.Id;
        clline1.Opportunity_Product__c = oppLineItem.Id;
        clline1.Balance__c = 200;
        clline1.Total_Price__c = 300;
        clline1.Adj_Amount__c = 100;
        clline1.Allowed_Amount__c = 200;
        clline1.Quantity__c = 1;
        clline1.Claim_Status__c = 'Submitted';
        clline1.Total_Payment_ReceivedA__c = 75;
        insert clline1;
        clline1.Allocated__c = true;
        update clline1;
        system.debug('clline1--'+clline1);
        system.debug('claimlinelist'+claimlinelist);
        
        List<Claim_Line__c>clLineList =  [SELECT Id, Name, Claim__c,Claim__r.Name,Claim__r.Patient__r.Name, Opportunity_Product__c, Opportunity_Product__r.Name, Balance__c, Total_Price__c, Quantity__c, Claim_Status__c,Total_Payment_ReceivedA__c FROM Claim_Line__c where Claim__c = :claim.id];
        system.debug('clLineList---->'+clLineList);
        system.debug('balance-->'+clLineList[0].Balance__c);
        
        date currentDate= system.today();
        System.debug('Year'+currentDate.year());
        system.debug('Month'+currentDate.month());
        
        Integer year=currentDate.year();
        Integer Month=currentDate.month();
        String Accountperioname;
        if(Month>=10){
            Accountperioname=year+'-'+Month;
        }else{
            Accountperioname=year+'-'+'0'+Month;
        }
        
        AcctSeed__Accounting_Period__c period=new AcctSeed__Accounting_Period__c();
        period.Name=Accountperioname;
        period.AcctSeed__Start_Date__c=system.today();
        period.AcctSeed__End_Date__c=system.today()+15;
        insert period;
        
        AcctSeed__Billing_Format__c Bill = new AcctSeed__Billing_Format__c();
        Bill.Name = 'Default Billing Product';
        Bill.AcctSeed__Type__c = 'Activity Statement';
        Bill.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF';
        Bill.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert Bill;
        
        AcctSeed__Billing_Format__c Billout = new AcctSeed__Billing_Format__c();
        Billout.Name = 'Default Billing Outstanding Activity Statement';
        Billout.AcctSeed__Type__c = 'Outstanding Statement';
        Billout.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF';
        Billout.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert Billout;
        
        AcctSeed__Billing_Format__c Billdefault = new AcctSeed__Billing_Format__c();
        Billdefault.Name = 'Default Billing Format';
        Billdefault.AcctSeed__Type__c = 'Billing';
        Billdefault.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF';
        Billdefault.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert Billdefault;
        
        AcctSeed__Billing_Format__c Billpurchase = new AcctSeed__Billing_Format__c();
        Billpurchase.Name = 'Default Billing Purchase Order Format';
        Billpurchase.AcctSeed__Type__c = 'Purchase Order';
        Billpurchase.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF';
        Billpurchase.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert Billpurchase;
        
        AcctSeed__Billing_Format__c Billpacking = new AcctSeed__Billing_Format__c();
        Billpacking.Name = 'Default Billing Packing Format';
        Billpacking.AcctSeed__Type__c = 'Packing Slip';
        Billpacking.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF';
        Billpacking.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert Billpacking;
        
        AcctSeed__GL_Account__c GlAcc = new AcctSeed__GL_Account__c();
        GlAcc.Name = 'Account';
        GlAcc.AcctSeed__Type__c = 'Balance Sheet';
        GlAcc.AcctSeed__Sub_Type_1__c = 'Assets';
        GlAcc.AcctSeed__Bank__c = false;
        GlAcc.AcctSeed__Active__c = true;
        insert GlAcc;
        
        AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c();
        cashGL.Name = '1000-Cash';
        cashGL.AcctSeed__Active__c = true;
        cashGL.AcctSeed__Type__c = 'Balance Sheet';
        cashGL.AcctSeed__Bank__c = true;
        cashGL.AcctSeed__Sub_Type_1__c = 'Assets';
        cashGL.AcctSeed__Sub_Type_2__c = 'Cash';
        insert CashGL;
        
         AcctSeed__GL_Account__c patientGl = new AcctSeed__GL_Account__c();
        patientGl.Name = '1200-Accounts Receivable';
        patientGl.AcctSeed__Active__c = true;
        patientGl.AcctSeed__Type__c = 'Balance Sheet';
        patientGl.AcctSeed__Bank__c = true;
        patientGl.AcctSeed__Sub_Type_1__c = 'Assets';
        patientGl.AcctSeed__Sub_Type_2__c = 'Cash';
        insert patientGl;
        
        AcctSeed__GL_Account__c GlAcc2 = new AcctSeed__GL_Account__c();
        GlAcc2.Name = 'Account';
        GlAcc2.AcctSeed__Type__c = 'Balance Sheet';
        GlAcc2.AcctSeed__Sub_Type_1__c = 'Assets';
        GlAcc2.AcctSeed__Bank__c = true;
        GlAcc2.AcctSeed__Active__c = true;
        insert GlAcc2;
        
        AcctSeed__Ledger__c Ledger = new AcctSeed__Ledger__c();
        Ledger.Name = 'Actual';
        Ledger.AcctSeed__Type__c = 'Transactional';
        Ledger.AcctSeed__Billing_Activity_Statement_Format__c = Bill.Id;
        Ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = Billout.Id;
        Ledger.AcctSeed__Default_Bank_Account__c = GlAcc2.Id;
        Ledger.AcctSeed__Default_Billing_Format__c = Billdefault.Id;
        Ledger.AcctSeed__Default_Purchase_Order_Format__c = Billpurchase.Id;
        Ledger.AcctSeed__Default_Packing_Slip_Format__c = Billpacking.Id;
        insert Ledger;
        
        Applied_Payment__c apppay = new Applied_Payment__c();
        apppay.Amount__c = clline1.Allowed_Amount__c;
        apppay.Opportunity_Product__c = clline1.Opportunity_Product__c;
        apppay.Payment__c = pay.Id;
        //apppay.Claim_Line__c = clline1.Id;
        insert apppay;
        system.debug('apppay--->'+apppay);
        
        Applied_Payment__c apppay1 = new Applied_Payment__c();
        apppay1.Amount__c = clline1.Allowed_Amount__c;
        apppay1.Opportunity_Product__c =oppLineItem.Id;
        apppay1.Payment__c = pay.Id;
        apppay1.Claim_Line__c = clline1.Id;
        insert apppay1;
        system.debug('apppay1--->'+apppay1);
        
        Opportunity opprec = [select Id ,AccountId, Location__c From Opportunity where Id =:opp.Id limit 1];
        update opprec;
        
        AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
        je.Name = 'Test JE';
        je.AcctSeed__Ledger__c = Ledger.Id;
        je.AcctSeed__Journal_Date__c = pay.Payment_Date__c;
        je.AcctSeed__Accounting_Period__c = period.id;
        je.Category__c = 'Interest Amount';
        je.Payment__c=pay.Id;
        insert je;
        
        
        List<AcctSeed__Journal_Entry_Line__c> jelinelist = new List<AcctSeed__Journal_Entry_Line__c>();
        AcctSeed__Journal_Entry_Line__c JeLine = new AcctSeed__Journal_Entry_Line__c();
        JeLine.AcctSeed__Journal_Entry__c = je.Id;
        JeLine.AcctSeed__Date__c = je.AcctSeed__Journal_Date__c;
        JeLine.AcctSeed__Credit__c =  1000;
        JeLine.AcctSeed__GL_Account__c = GlAcc.Id;
        JeLine.AcctSeed__GL_Account_Variable_1__c = acc.Accounting_Variable__c;
        JeLine.AcctSeed__Account__c = acc4.Id;
        jelinelist.add(JeLine);
        insert jelinelist;
        
        Payment__c pay2 = new Payment__c();
        pay2.Id = pay1.Id;
        pay2.Allocation__c = 1000;
        pay2.Unallocation__c =200;
        update pay2;
        
        oppLineItem.Id = clline1.Opportunity_Product__c;
        oppLineItem.Total_Payment_ReceivedA__c = clline1.Total_Payment_ReceivedA__c+clline1.Balance__c;
        oppLineItem.Balance__c = (clline1.Total_Price__c-(clline1.Total_Payment_ReceivedA__c+clline1.Balance__c));
        update oppLineItem;
        
        Test.startTest();
        string listofrecords = '[{"Id":"'+clline1.Id+'", "Name":"PM-100015", "Payer__c":"'+acc.Id+'", "Patient__c":"'+acc1.Id+'", "Amount__c":"1000.00"}]';
        string listofClaimlinerecords = '[{"Allocate":false,"Amount":149,"Balance":0,"Claim":"C-00035","ClaimLine":"John Do - CE-0334 - Billing 95992","Id":"'+clline1.Id+'","Payments":"50","ProductId":"'+oppLineItem.Id+'","TotalAmount":149,"AllowedAmount":"50","AdjAmount":99,"IsChecked":true}]';
        string listofpaymentrecords = '[{"Id":"'+pay.Id+'","Name":"PM-00006","Payer__c":"'+acc.Id+'","Allocation__c":794,"Unallocation__c":206,"Amount__c":1000,"Balance__c":206,"Payer__r":{"Name":"Amerigroup","HealthCloudGA__PayerType__c":"Patient","Id":"'+acc.Id+'"}}]';

        
        paymentAllocationController.getRecordDetails(pay.Id);
        paymentAllocationController.getRecordDetails(pay1.Id);
        paymentAllocationController.createAppliedPayment(listofrecords, pay.Id, je.Category__c,jelinelist[0].AcctSeed__GL_Account__c ,30);
        paymentAllocationController.updateClaimlines(listofClaimlinerecords,listofpaymentrecords);
        paymentAllocationController.setObjectToRecentItems(pay.Id);
        paymentAllocationController.testmethod1();
        Test.stopTest();
        
    }
    
}