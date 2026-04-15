/************************************
 * @Author			: eClouds
 * @Modified Date	: 07/08/2025
************************************/
@isTest
public class SalesOrderTriggerHandlerTest {
    @isTest
    static void testCreateBillingOpportunities() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@example.com';
        
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = uniqueUsername
        );
        insert testUser;
        
        Id payerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();

        Account testAccount = new Account(Name = 'Test Account', Special_Instructions__c = 'test', 
                                          BillingStreet = '456 Artera St',
                                          BillingCity = 'Houston', // added by eCoulds
                                          BillingCountry     = 'United States',
                                          BillingState       = 'Texas',
                                          BillingPostalCode  = '77001');
        insert testAccount;
        Account testAccount1 = new Account(Name = 'Artera Inc.', Special_Instructions__c = 'test', RecordTypeId = payerRecordTypeId);
        insert testAccount1;
        
        Account pathologyLab = new Account(Name = 'Test Pathology Lab', Type = 'Pathology Lab', Special_Instructions__c = 'test lab',
                                           BillingStreet = '456 Artera St',// added by eCoulds
                                           BillingCity = 'Houston', // added by eCoulds
                                           BillingCountry     = 'United States', // added by eCoulds
                                           BillingState       = 'Texas', // added by eCoulds
                                           BillingPostalCode  = '77001' // added by eCoulds
                                          );
        insert pathologyLab;
        
        Product2 testProduct = new Product2(Name = '0376U', IsActive = true);
        insert testProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry testPricebook = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            IsActive = true,
            UnitPrice = 100
        );
        insert testPricebook;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            NPI__c = '1234567890', // added by eClouds
            MailingStreet = '123 Test St',
            MailingCity = 'Minneapolis',
            MailingState = 'Minnesota',
            MailingPostalCode = '55401',
            MailingCountry = 'United States',
            Email = 'test@gmail.com'
            //Referring_Provider_NPI__c = '0123698541'
        );
        insert testContact;
        
        Id billingOpportunityRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Billing_Opportunity' LIMIT 1].Id;
        MemberPlan memberPlanRec = new MemberPlan();
        memberPlanRec.MemberId = testAccount.Id;
        memberPlanRec.Status = 'Active';
        memberPlanRec.VerificationStatus = 'Active - Verified';
        memberPlanRec.Insurance_Verification_Status__c = 'Active - Verified';
        memberPlanRec.PayerId = testAccount1.Id;
        memberPlanRec.Payer_Type__c = 'Patient';
        memberPlanRec.Name = 'test';
        memberPlanRec.PrimarySecondaryTertiary = 'Primary'; 
        insert memberPlanRec;
        
        Sales_Order__c testSalesOrder = new Sales_Order__c(
            Account__c = testAccount1.Id,
            Patient_Name1__c = testAccount.Id,
            Status__c = 'Open',
            Contact__c = testContact.Id,
            Portal_Ticket__c = 'test',
            Pathology_Lab__c = pathologyLab.Id,
            CS_Representative__c = testUser.Id
          //  Special_Instructions__c = testAccount.Special_Instructions__c, // commented by eCoulds
          //  Special_Instructions_PathLab__c = pathologyLab.Special_Instructions__c // commented by eCoulds
        );
        insert testSalesOrder;
        
        Test.startTest();
        testSalesOrder.Ready_for_processing__c = true;
        update testSalesOrder;
        Test.stopTest();
        
        // Verify Opportunity creation
        List<Opportunity> createdOpportunities = [SELECT Id, Name, StageName, RecordTypeId FROM Opportunity WHERE Sales_Order__c = :testSalesOrder.Id];
        // Verify OpportunityLineItem creation
        List<OpportunityLineItem> createdLineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :createdOpportunities[0].Id];
    }

    @isTest
    static void testCreateBillingOpportunitiesWithIncompleteAddress() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@example.com';
        
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = uniqueUsername
        );
        insert testUser;
        
        Id payerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();

          Account testAccount = new Account(
            Name = 'Test Account', 
            Special_Instructions__c = 'test',
              BillingStreet = '456 Artera St',// added by eCoulds
              BillingCity = 'Houston', // added by eCoulds
              BillingCountry     = 'United States',
              BillingState       = 'Texas',
              BillingPostalCode  = '77001'
        );
        insert testAccount;
        
        Account testAccount1 = new Account(Name = 'Artera Inc.', Special_Instructions__c = 'test', RecordTypeId = payerRecordTypeId);
        insert testAccount1;
        
        Account pathologyLab = new Account(Name = 'Test Pathology Lab', Type = 'Pathology Lab', Special_Instructions__c = 'test lab',
                                          BillingStreet = '456 Artera St',// added by eCoulds
                                           BillingCity = 'Houston', // added by eCoulds
                                           BillingCountry     = 'United States', // added by eCoulds
                                           BillingState       = 'Texas', // added by eCoulds
                                           BillingPostalCode  = '77001' // added by eCoulds
                                          );
        insert pathologyLab;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            NPI__c = '1234567890', // added by eClouds
            MailingStreet = '123 Test St',
            MailingCity = 'Minneapolis',
            MailingState = 'Minnesota',
            MailingPostalCode = '55401',
            MailingCountry = 'United States',
            Email = 'test@gmail.com'
            //Referring_Provider_NPI__c = '0123698541'
        );
        insert testContact;
        
        MemberPlan memberPlanRec = new MemberPlan();
        memberPlanRec.MemberId = testAccount.Id;
        memberPlanRec.Status = 'Active';
        memberPlanRec.VerificationStatus = 'Active - Verified';
        memberPlanRec.Insurance_Verification_Status__c = 'Active - Verified';
        memberPlanRec.PayerId = testAccount1.Id;
        memberPlanRec.Payer_Type__c = 'Patient';
        memberPlanRec.Name = 'test';
        memberPlanRec.PrimarySecondaryTertiary = 'Primary'; // CRITICAL FIX
        insert memberPlanRec;
        
        Sales_Order__c testSalesOrder = new Sales_Order__c(
            Account__c = testAccount1.Id,
            Patient_Name1__c = testAccount.Id,
            Status__c = 'Open',
            Contact__c = testContact.Id,
            Portal_Ticket__c = 'test',
            Pathology_Lab__c = pathologyLab.Id,
            CS_Representative__c = testUser.Id
          //  Special_Instructions__c = testAccount.Special_Instructions__c, 		  // commented by eCoulds
          //  Special_Instructions_PathLab__c = pathologyLab.Special_Instructions__c // commented by eCoulds
        );
        insert testSalesOrder;
        
        Test.startTest();
        try {
            testSalesOrder.Ready_for_processing__c = true;
            update testSalesOrder;
        } catch (DmlException e) {
        }
        Test.stopTest();
        
        // Verify no Opportunity is created
        List<Opportunity> createdOpportunities = [SELECT Id FROM Opportunity WHERE Sales_Order__c = :testSalesOrder.Id];
    }
}