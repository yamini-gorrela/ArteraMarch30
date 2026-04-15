@isTest
public class createClaimFromOppContoller_Tc {
    Static testmethod void Test1(){
        
        Id Accountrecordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        Id Accountrecordtypepatientid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        Id BillingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing Opportunity').getRecordTypeId();
        
        
        Account acc= new Account();
        acc.Name = 'Self Pay';
        acc.RecordTypeId= Accountrecordtypeid;
        insert acc;
        
        Account acc1= new Account();
        acc1.Name = 'Self Pay';
        acc.RecordTypeId= Accountrecordtypepatientid;
        insert acc1;
        
        Account acc2= new Account();
        acc2.Name = 'Self Pay';
        //acc2.RecordTypeId= AccountPhysmedrecordtypeid;
        insert acc2;
        
        contact con1 = new contact();
        con1.LastName = 'testclass';
        con1.AccountId = acc.id;
        con1.MailingCountry = 'United States';
        con1.MailingState = 'Minnesota'; // Set the State field
        con1.MailingPostalCode = '55401';
        con1.NPI__c = '7890';
        con1.Email = 'test@gmail.com';
        insert con1;
        
        contact con = new contact();
        con.LastName ='testclass';
        con.AccountId= acc1.id;
        con.MailingCountry = 'United States';
        con.MailingState = 'Minnesota';
        con.MailingPostalCode = '55401';
        con.NPI__c = '78911';
        con.Email = 'test12@gmail.com';
        insert con;
        
        
        AccountContactRelation acccon = new AccountContactRelation();
        acccon.AccountId=acc.id;
        acccon.ContactId=con.id;
        insert acccon;
                
        Product2 prod = new Product2(Name = '20610');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod1 = new Product2(Name = '20611');
        insert prod1;
        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                          UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,
                                                           UnitPrice = 10, IsActive = true);
        insert standardPrice1;
        
           
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Billing Opp';
        opp.CloseDate = system.today();
        opp.StageName = 'Qualification';
        opp.AccountId=acc.id;
        opp.Payer__c = acc.Id;
        opp.Status__c = 'Draft';
        opp.Provider__c= UserInfo.getUserId();
        opp.Location__c=acc.id;
        opp.Subscriber__c=acc.id;
        opp.Service_Date__c=system.today();
        opp.RecordTypeId = BillingRecordTypeId;
        oppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Billing Opp';
        opp1.CloseDate = system.today();
        opp1.StageName = 'Qualification';
        opp1.Payer__c = acc.Id;
        opp1.Status__c = 'Draft';
        opp1.Provider__c= UserInfo.getUserId();
        opp1.Location__c=acc.id;
        opp1.Subscriber__c=acc.id;
        opp1.Service_Date__c=system.today();
        opp1.RecordTypeId = BillingRecordTypeId;
        oppList.add(opp1);
        insert oppList;
        
        
        List<OpportunityLineItem> OpplineItems = new List<OpportunityLineItem>();
        
        OpportunityLineItem LineItem1 = new OpportunityLineItem();
        LineItem1.OpportunityId = oppList[0].Id;
        LineItem1.PricebookEntryId = standardPrice.Id;
        LineItem1.UnitPrice = 100;
        LineItem1.Quantity = 5;
        
        OpplineItems.add(LineItem1);
        
        OpportunityLineItem LineItem2 = new OpportunityLineItem();
        LineItem2.OpportunityId = oppList[0].Id;
        LineItem2.PricebookEntryId = standardPrice1.Id;
        LineItem2.UnitPrice = 100;
        LineItem2.Quantity = 5;
        OpplineItems.add(LineItem2);
        
        //insert OpplineItems;
        
        Test.startTest();
        PageReference testPage = Page.createClaimFromOpp; 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppList);
        stdSetController.setSelected(oppList);
        //testPage.getParameters().put('id', String.valueOf(oppList[0].Id));
        createClaimFromOppContoller ext = new createClaimFromOppContoller(stdSetController);
        ext.createClaims();
        Test.stopTest();
    }
    Static testmethod void Test2(){
        
        Id Accountrecordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        Id BillingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing Opportunity').getRecordTypeId();
        
        Account acc= new Account();
        acc.Name = 'Self Pay';
        acc.RecordTypeId= Accountrecordtypeid;
        insert acc;
        
        
        Product2 prod = new Product2(Name = '20610');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod1 = new Product2(Name = '20611');
        insert prod1;
        
        //Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                          UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,
                                                           UnitPrice = 10, IsActive = true);
        insert standardPrice1;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Billing Opp';
        opp.CloseDate = system.today();
        opp.StageName = 'Qualification';
        opp.Payer__c = acc.Id;
        opp.Status__c = 'Ready for Claim';
        opp.Provider__c= UserInfo.getUserId();
        opp.Location__c=acc.id;
        opp.Subscriber__c=acc.id;
        opp.Service_Date__c=system.today();
        opp.RecordTypeId = BillingRecordTypeId;
        oppList.add(opp);
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Billing Opp';
        opp1.CloseDate = system.today();
        opp1.StageName = 'Qualification';
        opp1.Payer__c = acc.Id;
        opp1.Status__c = 'Ready for Claim';
        opp1.Provider__c= UserInfo.getUserId();
        opp1.Location__c=acc.id;
        opp1.Subscriber__c=acc.id;
        opp1.Service_Date__c=system.today();
        opp1.RecordTypeId = BillingRecordTypeId;
        oppList.add(opp1);
        insert oppList;
        
        List<OpportunityLineItem> OpplineItems = new List<OpportunityLineItem>();
        
        OpportunityLineItem LineItem1 = new OpportunityLineItem();
        LineItem1.OpportunityId = oppList[0].Id;
        LineItem1.PricebookEntryId = standardPrice.Id;
        LineItem1.UnitPrice = 100;
        LineItem1.Quantity = 5;
        OpplineItems.add(LineItem1);
        
        OpportunityLineItem LineItem2 = new OpportunityLineItem();
        LineItem2.OpportunityId = oppList[1].Id;
        LineItem2.PricebookEntryId = standardPrice1.Id;
        LineItem2.UnitPrice = 100;
        LineItem2.Quantity = 5;
        OpplineItems.add(LineItem2);
        
        insert OpplineItems;
        
        CodeSet code = new CodeSet();
        code.Name ='C61';
        code.Code = '1123';
        insert code;
        
        Test.startTest();
        PageReference testPage = Page.createClaimFromOpp; 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppList);
        stdSetController.setSelected(oppList);
        //testPage.getParameters().put('id', String.valueOf(oppList[0].Id));
        createClaimFromOppContoller ext = new createClaimFromOppContoller(stdSetController);
        ext.createClaims();
        Test.stopTest();
    }
}