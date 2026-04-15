@isTest
public class PaymentController_TC {
    @isTest
    Public static void testRunning(){
        Payment__c pay = new Payment__c();
        pay.Amount__c = 1000;
        pay.Allocation__c = 1000;
        pay.Payment_Date__c = system.today();
        insert pay;
        PaymentController.createPaymentrecord(pay.id, 'test', 100);
        //Paymentvoidcontroller.createPaymentrecord(pay.id, 'test', 100);
    }

}