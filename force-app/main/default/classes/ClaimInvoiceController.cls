public class ClaimInvoiceController {
    public List<Claim_Line__c> claimLines { get; set; }
    public Decimal totalCharge { get; set; }
    public Decimal totalAdjustment { get; set; }
    public Decimal totalInsurancePaid { get; set; }
    public Decimal totalPatientPaid { get; set; }
    public Decimal totalBalance { get; set; }
    public Decimal totalAmountDue { get; set; }
    public List<Id> patientIds { get; set; }
    public String memberPlanSubscriber { get; set; }
    public Id claimId { get; set; }
    public List<MemberPlan> subscribermemberplanlist { get; set; }
    
    public ClaimInvoiceController(ApexPages.StandardController controller) {
        claimId = controller.getId();
        
        // Fetch Claim and Claim Lines in a single query to reduce SOQL calls
        List<Claim__c> claims = [SELECT Id, Patient__c, Patient__r.Name, Patient__r.BillingStreet, Patient__r.BillingCity,
                                 Patient__r.BillingState, Patient__r.BillingPostalCode, Patient__r.BillingCountry
                                 FROM Claim__c WHERE Id = :claimId LIMIT 1];
        
        if (!claims.isEmpty()) {
            patientIds = new List<Id>{ claims[0].Patient__c };
                }
        
        claimLines = [SELECT Date_from_of_Service__c, Payment_Pending_with__c, CPT_HCPCS__c, 
                      Sales_Price__c, Insurance_Balance__c, Patient_Balance__c, 
                      Balance__c, Total_Payment_ReceivedA__c, Total_Price__c, Adj_Amount__c, 
                      Opportunity_Product__c, Opportunity_Product__r.Description__c, 
                      Opportunity_Product__r.Payment_By_Patient__c, 
                      Opportunity_Product__r.Payment_By_Insurance__c 
                      FROM Claim_Line__c WHERE Claim__c = :claimId];
        
        // Initialize totals
        totalCharge = 0;
        totalAdjustment = 0;
        totalInsurancePaid = 0;
        totalPatientPaid = 0;
        totalBalance = 0;
        totalAmountDue = 0;
        
        for (Claim_Line__c cl : claimLines) {
            totalCharge += cl.Total_Price__c != null ? cl.Total_Price__c : 0;
            totalAdjustment += cl.Adj_Amount__c != null ? cl.Adj_Amount__c : 0;
            totalInsurancePaid += cl.Opportunity_Product__r != null && cl.Opportunity_Product__r.Payment_By_Insurance__c != null ? cl.Opportunity_Product__r.Payment_By_Insurance__c : 0;
            totalPatientPaid += cl.Opportunity_Product__r != null && cl.Opportunity_Product__r.Payment_By_Patient__c != null ? cl.Opportunity_Product__r.Payment_By_Patient__c : 0;
            totalBalance += cl.Balance__c != null ? cl.Balance__c : 0;
                
                if (cl.Payment_Pending_with__c == 'Patient' && cl.Patient_Balance__c != null) {
                    totalAmountDue += cl.Patient_Balance__c;
                } else if (cl.Payment_Pending_with__c == 'Insurance' && cl.Insurance_Balance__c != null) {
                    totalAmountDue += cl.Insurance_Balance__c;
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
        
        for (Claim_Line__c cl : claimLines) {
            if (cl.Date_from_of_Service__c != null) {
                Integer month = cl.Date_from_of_Service__c.month();
                Integer day = cl.Date_from_of_Service__c.day();
                Integer year = cl.Date_from_of_Service__c.year();
                
                // Ensure MM/DD/YYYY format with leading zeros
                String formattedDate = 
                    String.valueOf(month).leftPad(2, '0') + '/' + 
                    String.valueOf(day).leftPad(2, '0') + '/' + 
                    String.valueOf(year);
                
                formattedDates.put(cl.Id, formattedDate);
            } else {
                formattedDates.put(cl.Id, '');
            }
        }
        return formattedDates;
    }
    
}