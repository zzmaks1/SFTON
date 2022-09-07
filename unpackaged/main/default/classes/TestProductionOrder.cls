@isTest(seeAllData=true)
private class TestProductionOrder {  
      static testMethod void Test1() {  
           Profile profile = [select id, Name from profile where Name = 'Менеджер по продажам'];    
           Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
           User user = new User(alias = 'tt05', email='testtest05@test.com', emailencodingkey='UTF-8', lastname='Менеджер по продажам', languagelocalekey='en_US', localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='testtest05@test.com');  
           insert user;  
           System.RunAs(user){                 
               PageReference pageRef = Page.ProductionOrder;
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
               Opportunity opportunity = new Opportunity(Name='Test opp',StageName='test',CloseDate=Date.today(), Pricebook2Id = pb2.Id, UserTION__c = UT.id, needSendNotification__c = true);
               insert opportunity;               
               ProjectMember__c PMC = new ProjectMember__c(ProjectRoles__c = 'Генпроектировщик', OpportunityId__c = opportunity.id, AccountId__c = account.id);
               insert PMC;               
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
               
               ApexPages.StandardController sc = new ApexPages.StandardController(new ProductionOrder__c());
               ProductionOrderExtentionController controller = new ProductionOrderExtentionController(sc);               
               controller.PO.owner__c=userinfo.getUserID();
               controller.PO.opportunity__c = opportunity.ID;
               controller.setQuote(quote.ID);
               controller.PO.UserTION__c = UT.ID;
               controller.PO.SubmissionDate__c = Date.today();
               controller.PO.Account__c = PMC.Id;
               controller.PO.AccountContacts__c = 'test';
               controller.PO.Address__c = 'test';
               controller.PO.DeliveryPay__c = 'Самовывоз в течение 5 дней после уведомления';
               controller.save();   
               
               controller.getDynamicForm();
               insert controller.PO;
           }  
      }  
 }