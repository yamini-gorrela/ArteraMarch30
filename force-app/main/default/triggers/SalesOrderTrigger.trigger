trigger SalesOrderTrigger on Sales_Order__c (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Pass both Trigger.new and Trigger.oldMap to validatePayerConditions
        SalesOrderTriggerHandler.validatePayerConditions(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        // Query updated Sales Orders and pass them to createBillingOpportunities
        List<Sales_Order__c> updatedSalesOrders = [
            SELECT Id, Name,DOS__c,Ready_for_processing__c, Status__c, Account__c, Account__r.Name, Patient_Name1__c, Patient_Name1__r.Name, Contact__c
            FROM Sales_Order__c
            WHERE Id IN :Trigger.newMap.keySet()
        ];
        // Call the method to create billing opportunities, but only if validation passed
        SalesOrderTriggerHandler.createBillingOpportunities(updatedSalesOrders, Trigger.oldMap);
    }
}