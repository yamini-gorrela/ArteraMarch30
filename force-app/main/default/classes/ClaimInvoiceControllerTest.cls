@isTest
public class ClaimInvoiceControllerTest {
    @testSetup
    static void setupTestData() {
        
        Id patientId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        AcctSeed__Accounting_Variable__c accvar = new AcctSeed__Accounting_Variable__c();
        accvar.Name = 'test1';
        accvar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accvar;
        
        
        Account testPatient = new Account();
        testPatient.LastName = 'test';
        testPatient.Accounting_Variable__c = accvar.Id;
        testPatient.RecordTypeId =patientId;
        insert testPatient;
        
        
        
        Claim__c testClaim = new Claim__c();
        testClaim.Patient__c=testPatient.id;
        insert testClaim;
        
        List<Claim_Line__c> claimLines = new List<Claim_Line__c>{
            new Claim_Line__c(
                Claim__c = testClaim.Id,
                Date_from_of_Service__c = Date.newInstance(2025, 4, 1),
                Payment_Pending_with__c = 'Patient',
                Sales_Price__c = 100,
                Insurance_Balance__c = 50,
                Patient_Balance__c = 50,
                Balance__c = 50,
                Total_Payment_ReceivedA__c = 50,
                Total_Price__c = 100,
                Adj_Amount__c = 10
            ),
                new Claim_Line__c(
                    Claim__c = testClaim.Id,
                    Date_from_of_Service__c = Date.newInstance(2025, 4, 2),
                    Payment_Pending_with__c = 'Insurance',
                    Sales_Price__c = 200,
                    Insurance_Balance__c = 150,
                    Patient_Balance__c = 50,
                    Balance__c = 150,
                    Total_Payment_ReceivedA__c = 100,
                    Total_Price__c = 200,
                    Adj_Amount__c = 20
                )
                };
                    insert claimLines;
        
        MemberPlan testMemberPlan = new MemberPlan(
            Name = 'test',
            MemberId = testPatient.Id,
            SubscriberId = testPatient.Id,
            Status = 'Active'
        );
        insert testMemberPlan;
    }
    
    @isTest
    static void testClaimInvoiceController() {
        Claim__c testClaim = [SELECT Id FROM Claim__c LIMIT 1];
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testClaim);
        
        Test.startTest();
        ClaimInvoiceController claimCtrl = new ClaimInvoiceController(controller);
        Map<Id, String> formattedDates = claimCtrl.getFormattedDates();
        Test.stopTest();
    }
}