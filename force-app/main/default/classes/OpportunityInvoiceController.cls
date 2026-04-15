public class OpportunityInvoiceController {
    public List<OpportunityLineItem	> optyLines { get; set; }
    public Decimal totalCharge { get; set; }
    public Decimal totalAdjustment { get; set; }
    public Decimal totalInsurancePaid { get; set; }
    public Decimal totalPatientPaid { get; set; }
    public Decimal totalBalance { get; set; }
    public Decimal totalAmountDue { get; set; }
    public List<Id> patientIds { get; set; }
    public String memberPlanSubscriber { get; set; }
    public Id optyId { get; set; }
    public List<MemberPlan> subscribermemberplanlist { get; set; }
    
    public OpportunityInvoiceController(ApexPages.StandardController controller) {
        optyId = controller.getId();
        
        // Fetch Claim and Claim Lines in a single query to reduce SOQL calls
        List<Opportunity> optys = [SELECT Id, Service_Date__c,AccountId, Account.Name, Account.BillingStreet, Account.BillingCity,
                                   Account.BillingState, Account.BillingPostalCode, Account.BillingCountry
                                   FROM Opportunity WHERE Id = :optyId LIMIT 1];
        
        if (!optys.isEmpty()) {
            patientIds = new List<Id>{ optys[0].AccountId };
                }
        
        optyLines = [SELECT Product2Id,Product2.Name,Opportunity.Service_Date__c, Payment_Pending_with__c, 
                     UnitPrice, Insurance_Balance__c, Patient_Balance__c, 
                     Balance__c, Total_Payment_ReceivedA__c, TotalPrice, Adj_Amount__c, 
                     Description__c, Payment_By_Patient__c, Payment_By_Insurance__c 
                     FROM OpportunityLineItem WHERE OpportunityId = :optyId];
        
        // Initialize totals
        totalCharge = 0;
        totalAdjustment = 0;
        totalInsurancePaid = 0;
        totalPatientPaid = 0;
        totalBalance = 0;
        totalAmountDue = 0;
        
        for (OpportunityLineItem oli : optyLines) {
            totalCharge += oli.TotalPrice != null ? oli.TotalPrice : 0;
            totalAdjustment += oli.Adj_Amount__c != null ? oli.Adj_Amount__c : 0;
            totalInsurancePaid +=  oli.Payment_By_Insurance__c != null ? oli.Payment_By_Insurance__c : 0;
            totalPatientPaid +=oli.Payment_By_Patient__c != null ? oli.Payment_By_Patient__c : 0;
            totalBalance += oli.Balance__c != null ? oli.Balance__c : 0;
                
                if (oli.Payment_Pending_with__c == 'Patient' && oli.Patient_Balance__c != null) {
                    totalAmountDue += oli.Patient_Balance__c;
                } else if (oli.Payment_Pending_with__c == 'Insurance' && oli.Insurance_Balance__c != null) {
                    totalAmountDue += oli.Insurance_Balance__c;
                }
        }
        
        // Fetch Subscriber details from MemberPlan
        subscribermemberplanlist = [
            SELECT Id, SubscriberId, Subscriber.Name, Status 
            FROM MemberPlan 
            WHERE MemberId IN :patientIds AND Status = 'Active' 
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (!subscribermemberplanlist.isEmpty()) {
            memberPlanSubscriber = subscribermemberplanlist[0].Subscriber.Name;
        }
    }
    
    public Map<Id, String> getFormattedDates() {
        Map<Id, String> formattedDates = new Map<Id, String>();
        
        for (OpportunityLineItem oli : optyLines) {
            if (oli.Opportunity.Service_Date__c != null) {
                Integer month = oli.Opportunity.Service_Date__c.month();
                Integer day = oli.Opportunity.Service_Date__c.day();
                Integer year = oli.Opportunity.Service_Date__c.year();
                
                // Ensure MM/DD/YYYY format with leading zeros
                String formattedDate = 
                    String.valueOf(month).leftPad(2, '0') + '/' + 
                    String.valueOf(day).leftPad(2, '0') + '/' + 
                    String.valueOf(year);
                
                formattedDates.put(oli.Id, formattedDate);
            } else {
                formattedDates.put(oli.Id, '');
            }
        }
        return formattedDates;
    }
    
}