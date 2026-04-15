@isTest
public class OpportunityInvoiceControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Record Type IDs
        Id patientId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing Opportunity').getRecordTypeId();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        
        // Accounting Variable
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c(
            Name = 'Test Variable',
            AcctSeed__Type__c = 'GL Account Variable 1'
        );
        insert accVar;
        
        // Patient Account
        Account patient = new Account(
            LastName = 'Test Patient',
            RecordTypeId = patientId,
            Accounting_Variable__c = accVar.Id
        );
        insert patient;
        
        // Payer Account
        Account payer = new Account(
            Name = 'Self Pay',
            RecordTypeId = accountRecordTypeId
        );
        insert payer;
        
        // Products
        Product2 prod1 = new Product2(Name = '20610');
        Product2 prod2 = new Product2(Name = '20611');
        insert new List<Product2>{ prod1, prod2 };
            
            Id standardPricebookId = Test.getStandardPricebookId();
        
        // Pricebook Entries
        PricebookEntry pbe1 = new PricebookEntry(
            Product2Id = prod1.Id,
            Pricebook2Id = standardPricebookId,
            UnitPrice = 100,
            IsActive = true
        );
        PricebookEntry pbe2 = new PricebookEntry(
            Product2Id = prod2.Id,
            Pricebook2Id = standardPricebookId,
            UnitPrice = 10,
            IsActive = true
        );
        insert new List<PricebookEntry>{ pbe1, pbe2 };
            
            // Opportunity
            Opportunity opp = new Opportunity(
                Name = 'Billing Opp',
                CloseDate = Date.today(),
                StageName = 'Qualification',
                RecordTypeId = billingRecordTypeId,
                AccountId = patient.Id,
                Payer__c = payer.Id,
                Status__c = 'Draft',
                Provider__c = UserInfo.getUserId(),
                Location__c = patient.Id,
                Subscriber__c = patient.Id,
                Service_Date__c = Date.today()
            );
        insert opp;
        
        // Opportunity Line Items
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        
        lineItems.add(new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe1.Id,
            UnitPrice = 100,
            Quantity = 5,
            Adj_Amount__c = 10,
            Balance__c = 5,
            Payment_Pending_with__c = 'Patient',
            Payment_By_Insurance__c = 10,
            Payment_By_Patient__c = 5
        ));
        
        lineItems.add(new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe2.Id,
            UnitPrice = 100,
            Quantity = 5,
            Adj_Amount__c = 10,
            Balance__c = 5,
            Payment_Pending_with__c = 'Insurance',
            Payment_By_Insurance__c = 10,
            Payment_By_Patient__c = 5
        ));
        
        insert lineItems;
        
        // Active Member Plan
        MemberPlan mp = new MemberPlan(
            Name = 'Test Plan',
            MemberId = patient.Id,
            SubscriberId = patient.Id,
            Status = 'Active'
        );
        insert mp;
    }
    
    @isTest
    static void testOpportunityInvoiceControllerLogic() {
        // Query the opportunity created in @testSetup
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Billing Opp' LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        
        Test.startTest();
        OpportunityInvoiceController controller = new OpportunityInvoiceController(stdCtrl);
        Map<Id, String> dateMap = controller.getFormattedDates();
        Test.stopTest();
    }
}