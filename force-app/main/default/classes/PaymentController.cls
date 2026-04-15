public class PaymentController {
    @AuraEnabled
    public static Id createPaymentrecord(Id parentPaymentId, String refundreason, Decimal refundamount) {
        
        Payment__c parentPayment = [
            SELECT Id, Refund_Reason__c, Refund_Amount__c, Transaction_Type__c, Amount__c,
            Allocation__c, Unallocation__c, Claim__c, Original_Payment_Reference__c,
            Paid_Amount__c, Payer__c, Patient__c
            FROM Payment__c 
            WHERE Id = :parentPaymentId 
            LIMIT 1
        ];
        
        if (refundamount > parentPayment.Amount__c) {
            throw new AuraHandledException('Refund amount cannot be greater than the original payment amount (' + parentPayment.Amount__c + ').');
        }
        
        Payment__c newPayment = new Payment__c();
        newPayment.Refund_Reason__c = refundreason;
        newPayment.Refund_Amount__c = refundamount;
        newPayment.Transaction_Type__c = 'Refund';
        newPayment.Amount__c = refundamount;
        newPayment.Allocation__c = 0;
        newPayment.Unallocation__c = refundamount;
        newPayment.Claim__c = parentPayment.Claim__c;
        newPayment.Paid_Amount__c = -1 * refundamount;
        newPayment.Payment_Date__c = system.today();
        newPayment.Payer__c = parentPayment.Payer__c;
        newPayment.Patient__c = parentPayment.Patient__c;
        newPayment.Original_Payment_Reference__c = parentPaymentId;
        
        insert newPayment;
        system.debug('newPayment====' + newPayment);
        return newPayment.Id;
    }
}