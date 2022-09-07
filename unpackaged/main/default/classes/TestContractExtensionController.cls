@isTest(seeAllData=true)
private class TestContractExtensionController {  
      static testMethod void Test1() {  
           Profile profile = [select id, Name from profile where Name = 'Менеджер по продажам'];    
           Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
           User user = new User(alias = 'tt02', email='testtest02@test.com', emailencodingkey='UTF-8', lastname='Менеджер по продажам', languagelocalekey='en_US', localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='testtest02@test.com');  
           insert user;  
           System.RunAs(user){  
               PageReference pageRef = Page.ContractPDF;
               Test.setCurrentPageReference(pageRef);
               Account account = new Account(Name='Test acc',
                                        Type='Монтажник',
                                        Phone='1234',
                                        ShippingCountry__c='Россия',
                                        ShippingRegion__c='Москва');
               insert account;               
               Pricebook2 pb2 = new Pricebook2(Name = 'test');
               insert pb2;
                User__c UT = new User__c(User__c = UserInfo.getUserId(), Name = 'Менеджер по продажам');
                insert UT;
               Opportunity opportunity = new Opportunity(Name='Test opp',StageName='test',CloseDate=Date.today(), Pricebook2Id = pb2.Id, UserTION__c = UT.id);
               insert opportunity;
               Quote quote = new Quote(Name = 'test', OpportunityId = opportunity.Id, Organisation__c = account.id, Pricebook2Id = pb2.Id);
               insert quote;                 
               Product2 p2 = new Product2(Name = 'test1 Пром');
               insert p2;
               PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p2.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
               insert standardPrice;
               PricebookEntry pe = new PricebookEntry(UnitPrice = 100, IsActive = true, Product2Id = p2.Id, Pricebook2Id = pb2.Id);
               insert pe;
               QuoteLineItem qln = new QuoteLineItem(quoteId = quote.Id, PricebookEntryId = pe.Id, Quantity = 1, UnitPrice = 100);
               insert qln;
               OpportunityLineItem oln = new OpportunityLineItem(OpportunityId = Opportunity.Id, PricebookEntryId = pe.Id, Quantity = 1, UnitPrice = 100);
               insert oln;
               
               
               Contract cn = new Contract();
               cn.Prepayment_days__c = 5;
               cn.Partpayment_days__c = 5;
               cn.Postpayment_days__c = 5;              
               cn.ProjectName__c = opportunity.Id;
               cn.Smeta__c = quote.Id;
               cn.AccountId = account.Id;
               cn.AccountCEO__c = 'test';
               cn.AccountBillingName__c = 'test';
               cn.AccountCEOAct__c = 'test';
               cn.SignatureInitials__c = 'test';
               cn.SpecificationDate__c = Date.valueOf('2013-04-10'); 
               cn.StartDate =  Date.valueOf('2013-04-10');
               cn.CompanyDeliverTo__c = 'test';
               cn.DeliveryDuration__c = 'test';
               cn.Partpayment__c = 30;
               cn.Postpayment__c = 30;
               cn.Prepayment__c = 40;
               cn.ContractNumber__c = 'TT/11112022';
               insert cn;
               
               Specification__c sn = new Specification__c();
               sn.Prepayment_days__c = 5;
               sn.Partpayment_days__c = 5;
               sn.Postpayment_days__c = 5;              
               sn.Opportunity__c = opportunity.Id;
               sn.Quote__c = quote.Id;
               sn.SpecificationDate__c = Date.valueOf('2013-04-10'); 
               sn.CompanyDeliverTo__c = 'test';
               sn.DeliveryDuration__c = 'test';
               sn.Partpayment__c = 30;
               sn.Postpayment__c = 30;
               sn.Prepayment__c = 40;
               sn.Contract__c = cn.ID;
               insert sn;    
               
               ApexPages.StandardController sc = new ApexPages.StandardController(cn);
               ContractExtensionController cec = new ContractExtensionController(sc);
               System.assertEquals(cec.getContractDate(), '«10» апреля 2013 г.');
               System.assertEquals(cec.getContractSpecificationDate(), '«10» апреля 2013 г.');
               cec.getContractProducts();
               cec.getContractNDS();
               cec.getContractCount();
               cec.getContractTotal();
               cec.getContractTotalWithoutNDS();
               cec.getContractTotalStr();
               cec.getContractNDSStr();
               cec.getPaymentText();
               cec.getPaymentText2();
               cec.getBankDaysStr(Decimal.valueOf(5));
               cec.getBankDaysStr(Decimal.valueOf(12));               
               cec.getBankDaysStr(Decimal.valueOf(55));
               cec.getDelivery();
               cec.getAddressPost();
               cec.getCProduct();
               cec.getspecConditionPointNumber();
               cec.num2str(Decimal.valueOf('12'));
               cec.num2str(Decimal.valueOf('12222'));
               cec.num2str(Decimal.valueOf('12222222'));
               cec.num2str(Decimal.valueOf('12222222222'));               
                        
               
               pageRef = Page.SpecificationPDF;
               Test.setCurrentPageReference(pageRef);
               
               ApexPages.StandardController scs = new ApexPages.StandardController(sn);
               SpecificationExtensionController sec = new SpecificationExtensionController(scs);
               System.assertEquals(sec.getContractDate(), '«10» апреля 2013 г.');
               System.assertEquals(sec.getContractSpecificationDate(), '«10» апреля 2013 г.');
               sec.getContract();
               sec.getContractProducts();
               sec.getContractNDS();
               sec.getContractCount();
               sec.getContractTotal();
               sec.getContractTotalWithoutNDS();
               sec.getContractTotalStr();
               sec.getContractNDSStr();
               sec.getPaymentText();
               sec.getPaymentText2();
               sec.getBankDaysStr(Decimal.valueOf(5));
               sec.getBankDaysStr(Decimal.valueOf(12));               
               sec.getBankDaysStr(Decimal.valueOf(55));
               sec.getDelivery();
               sec.getAddressPost();
               sec.getCProduct();
               sec.getspecConditionPointNumber();
               sec.num2str(Decimal.valueOf('12'));
               sec.num2str(Decimal.valueOf('12222'));
               sec.num2str(Decimal.valueOf('12222222'));
               sec.num2str(Decimal.valueOf('12222222222'));
               
               pageRef = Page.ContractPDF;
               Test.setCurrentPageReference(pageRef);
               
               Pricebook2 pb22 = new Pricebook2(Name = 'test');
               insert pb22;
               Quote quote2 = new Quote(Name = 'test', OpportunityId = opportunity.Id, Organisation__c = account.id, Pricebook2Id = pb22.Id);
               insert quote2;                 
               Product2 p22 = new Product2(Name = 'test1 Мед');
               insert p22;
               PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p22.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
               insert standardPrice2;
               PricebookEntry pe2 = new PricebookEntry(UnitPrice = 100, IsActive = true, Product2Id = p22.Id, Pricebook2Id = pb22.Id);
               insert pe2;
               QuoteLineItem qln2 = new QuoteLineItem(quoteId = quote2.Id, PricebookEntryId = pe2.Id, Quantity = 1, UnitPrice = 100);
               insert qln2;    
               Opportunity opportunity2 = new Opportunity(Name='Test opp',StageName='test',CloseDate=Date.today(), Pricebook2Id = pb22.Id, UserTION__c = UT.id);
               insert opportunity2;
               OpportunityLineItem oln2 = new OpportunityLineItem(OpportunityId = Opportunity2.Id, PricebookEntryId = pe2.Id, Quantity = 1, UnitPrice = 100);
               insert oln2;
               OpportunityLineItem oln3 = new OpportunityLineItem(OpportunityId = Opportunity2.Id, PricebookEntryId = pe2.Id, Quantity = 1, UnitPrice = 200);
               insert oln3;
               Contract cn2 = new Contract();
               cn2.Prepayment_days__c = 5;
               cn2.Partpayment_days__c = 5;
               cn2.Postpayment_days__c = 5;              
               cn2.ProjectName__c = opportunity.Id;
               cn2.Smeta__c = quote2.Id;
               cn2.AccountId = account.Id;
               cn2.AccountCEO__c = 'test';
               cn2.AccountBillingName__c = 'test';
               cn2.AccountCEOAct__c = 'test';
               cn2.SignatureInitials__c = 'test';
               cn2.SpecificationDate__c = Date.valueOf('2013-04-10'); 
               cn2.SpecificationType__c = 'Экспорт';
               cn2.DeliveryCondition__c = 'За счет Покупателя. Покупатель оплачивает счет от транспортной компании';
               cn2.StartDate =  Date.valueOf('2013-04-10');
               cn2.CompanyDeliverTo__c = 'test';
               cn2.DeliveryDuration__c = 'test';
               cn2.Partpayment__c = 0;
               cn2.Postpayment__c = 0;
               cn2.Prepayment__c = 100;               
               cn2.ContractNumber__c = 'TT/11112022';
               insert cn2;
               
               Specification__c sn2 = new Specification__c();
               sn2.Prepayment_days__c = 5;
               sn2.Partpayment_days__c = 5;
               sn2.Postpayment_days__c = 5;              
               sn2.opportunity__c = opportunity.Id;
               sn2.quote__c = quote2.Id;
               sn2.SpecificationDate__c = Date.valueOf('2013-04-10'); 
               sn2.SpecificationType__c = 'Экспорт';
               sn2.DeliveryCondition__c = 'За счет Покупателя. Покупатель оплачивает счет от транспортной компании';
               sn2.CompanyDeliverTo__c = 'test';
               sn2.DeliveryDuration__c = 'test';
               sn2.Partpayment__c = 0;
               sn2.Postpayment__c = 0;
               sn2.Prepayment__c = 100;               
               sn2.Contract__c = cn2.ID;
               insert sn2;
               
               ApexPages.StandardController sc2 = new ApexPages.StandardController(cn2);
               ContractExtensionController cec2 = new ContractExtensionController(sc2);
               cec2.getContractProducts();
               cec2.getContractNDS();
               cec2.getContractCount();
               cec2.getContractTotal();
               cec2.getContractTotalWithoutNDS();
               cec2.getContractTotalStr();
               cec2.getContractNDSStr();
               cec2.getPaymentText();
               cec2.getPaymentText2();
               cec2.getBankDaysStr(Decimal.valueOf(5));
               cec2.getBankDaysStr(Decimal.valueOf(12));               
               cec2.getBankDaysStr(Decimal.valueOf(55));
               cec2.getDelivery();
               cec2.getAddressPost();
               cec2.getCProduct();
               cec2.getspecConditionPointNumber();
               cec2.num2str(Decimal.valueOf('12'));
               cec2.num2str(Decimal.valueOf('12222'));
               cec2.num2str(Decimal.valueOf('12222222'));
               cec2.num2str(Decimal.valueOf('12222222222'));
               
               pageRef = Page.SpecificationPDF;
               Test.setCurrentPageReference(pageRef);
               ApexPages.StandardController scs2 = new ApexPages.StandardController(sn2);
               SpecificationExtensionController sec2 = new SpecificationExtensionController(scs2);
               sec2.getContractProducts();
               sec2.getContractNDS();
               sec2.getContractCount();
               sec2.getContractTotal();
               sec2.getContractTotalWithoutNDS();
               sec2.getContractTotalStr();
               sec2.getContractNDSStr();
               sec2.getPaymentText();
               sec2.getPaymentText2();
               sec2.getBankDaysStr(Decimal.valueOf(5));
               sec2.getBankDaysStr(Decimal.valueOf(12));               
               sec2.getBankDaysStr(Decimal.valueOf(55));
               sec2.getDelivery();
               sec2.getAddressPost();
               sec2.getCProduct();
               sec2.getspecConditionPointNumber();
               sec2.num2str(Decimal.valueOf('12'));
               sec2.num2str(Decimal.valueOf('12222'));
               sec2.num2str(Decimal.valueOf('12222222'));
               sec2.num2str(Decimal.valueOf('12222222222'));
               
           }  
      }  
 }