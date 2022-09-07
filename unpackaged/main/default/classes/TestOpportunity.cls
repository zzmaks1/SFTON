@isTest(seeAllData=true)
private class TestOpportunity {  
    static testMethod void TestStageByBusinessProcess() {            
        BusinessProcess bp1 = [SELECT id FROM BusinessProcess WHERE Name = 'Тион, продажа О2 дилерам'];
        BusinessProcess bp2 = [SELECT id FROM BusinessProcess WHERE Name = 'Тион, выбивание конкурентов'];
        BusinessProcess bp3 = [SELECT id FROM BusinessProcess WHERE Name = 'Тион, базовый процесс продаж'];
        StageByBusinessProcess sbp = new StageByBusinessProcess();
        system.assertEquals(sbp.getNextStage(bp1, 'Холодный звонок'), 'Переговоры (обсуждение условий)');
        system.assertEquals(sbp.getNextStage(bp2, 'Отслеживание конкурса на монтаж'),'Конкурс на монтаж завершен');
        system.assertEquals(sbp.getNextStage(bp3, 'Отслеживание конкурса на монтаж'),'Конкурс на монтаж завершен');
        system.assertEquals(sbp.getNextStage(bp3, ''),'Отслеживание конкурса на проектирование');
    }      
    
    
    static testMethod void TestLookup() {
        PageReference pageRef = Page.ContractorCustomLookup;
        Account account = new Account(Name='Test acc',
                                      Type='Монтажник',
                                      Phone='1234',
                                      ShippingCountry__c='Россия',
                                      ShippingRegion__c='Москва');
        insert account;
        Opportunity opp = new Opportunity(Name='Test opp',StageName='Подбор оборудования',CloseDate=Date.today());
        BusinessProcess bp = [SELECT Id FROM BusinessProcess WHERE Name = 'Тион, продажа О2 дилерам'];
        RecordType rt = [SELECT Id FROM RecordType WHERE BusinessProcessId = :bp.ID limit 1];
        opp.RecordTypeId = rt.Id;
        insert opp;
        pageRef.getParameters().put('accountId',account.Id);
        pageRef.getParameters().put('oppId',opp.Id);
        pageRef.getParameters().put('retURL','www.tion.info');
        pageRef.getParameters().put('saveURL','www.tion.info');
        Test.setCurrentPageReference(pageRef);
        ContractorLookupController controller = new ContractorLookupController();  
        controller.contractor.ProjectRoles__c = 'Дилер';
        controller.save();          
        controller.cancel();
        ProjectMember__c contractor = controller.getContractor();
        System.debug('Current contractor: ' + contractor.Id);
        
    }
    
    static testMethod void TestAct() {
        PageReference pageRef = Page.ActPDF;
        Test.setCurrentPageReference(pageRef);    
        Opportunity opp = [SELECT id FROM opportunity Where OwnerId = :userinfo.getUserID() limit 1 offset 2];        
        opp.StartWorkingProducts__c = date.newinstance(2013, 2, 17);
        update opp;
        act__c act = new act__c(Opportunity__c = opp.id);
        insert act;
        ApexPages.StandardController sc = new ApexPages.StandardController(act);
        ActExtensionController controller = new ActExtensionController(sc);      
        controller.getStartDate();
        controller.getStartDateMin();
        controller.getCountAssets();
        controller.getAssetList();
        
    }
    
    
    static testMethod void testTriggerProjectAdd(){
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        Pricebook2 pb2 = new Pricebook2(Name = 'test');
        insert pb2;
        Account account = new Account(Name='Test acc',
                                      Type='Монтажник',
                                      Phone='1234',
                                      ShippingCountry__c='Россия',
                                      ShippingRegion__c='Москва', discount__c = 20);
        insert account;  
        Opportunity opportunity = new Opportunity(Name='Test opp',StageName='Закупка оборудования',CloseDate=Date.today(), Pricebook2Id = pb2.Id);
        BusinessProcess bp = [SELECT Id FROM BusinessProcess WHERE Name = 'Тион, продажа О2 дилерам'];
        RecordType rt = [SELECT Id FROM RecordType WHERE BusinessProcessId = :bp.ID limit 1];
        opportunity.RecordTypeId = rt.Id;
        opportunity.accountId = account.Id;
        insert opportunity;                
        ProjectMember__c contractor = new ProjectMember__c(AccountId__c = account.Id,OpportunityId__c = opportunity.Id, ProjectRoles__c = 'Дилер');
        insert contractor;
        Product2 p2 = new Product2(Name = 'Компактная вентиляционная система Тион О2');
        insert p2;
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p2.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry pe = new PricebookEntry(UnitPrice = 100, IsActive = true, Product2Id = p2.Id, Pricebook2Id = pb2.Id);
        insert pe;
        OpportunityLineItem oln = new OpportunityLineItem(OpportunityId = Opportunity.Id, PricebookEntryId = pe.Id, Quantity = 1, UnitPrice = 100);
        insert oln;
        
        contractor.ProjectRoles__c = 'Генподрядчик';
        update contractor;
        
        List<Opportunity> opplist = [SELECT id FROM opportunity Where OwnerId = :userinfo.getUserID() limit 2];
        opportunity = opplist[1];
        bp = [SELECT Id FROM BusinessProcess WHERE Name = 'Тион, базовый процесс продаж'];
        rt = [SELECT Id FROM RecordType WHERE BusinessProcessId = :bp.ID limit 1];
        opportunity.RecordTypeId = rt.Id;  
        opportunity.StageName='Подбор оборудования';
        update opportunity;
        
        try{
            p2 = new Product2(Name = 'ТИОН МЕД');
            insert p2;
            standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p2.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
            insert standardPrice;
            pe = new PricebookEntry(UnitPrice = 100, IsActive = true, Product2Id = p2.Id, Pricebook2Id = pb2.Id);
            insert pe;
            oln = new OpportunityLineItem(OpportunityId = Opportunity.Id, PricebookEntryId = pe.Id, Quantity = 1, UnitPrice = 100);
            insert oln;
            
            p2 = new Product2(Name = 'ТИОН ПРОМ');
            insert p2;
            standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = p2.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
            insert standardPrice;
            pe = new PricebookEntry(UnitPrice = 100, IsActive = true, Product2Id = p2.Id, Pricebook2Id = pb2.Id);
            insert pe;
            oln = new OpportunityLineItem(OpportunityId = Opportunity.Id, PricebookEntryId = pe.Id, Quantity = 1, UnitPrice = 100);
            insert oln;
        }catch(System.DMLException e) {                
        }
    }
    
    static testMethod void TestOppGroup() {
        PageReference pageRef = Page.OpportunityGroupAdd;
        Account account = new Account(Name='Test acc',
                                      Type='Монтажник',
                                      Phone='1234',
                                      ShippingCountry__c='Россия',
                                      ShippingRegion__c='Москва');
        insert account;
        Opportunity opp = new Opportunity(Name='Test opp',StageName='Подбор оборудования',CloseDate=Date.today());
        BusinessProcess bp = [SELECT Id FROM BusinessProcess WHERE Name = 'Тион, продажа О2 дилерам'];
        RecordType rt = [SELECT Id FROM RecordType WHERE BusinessProcessId = :bp.ID limit 1];
        opp.RecordTypeId = rt.Id;
        insert opp;
        pageRef.getParameters().put('accountId',account.Id);
        pageRef.getParameters().put('oppId',opp.Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(new OpportunityGroup__c(Opportunity__c = opp.id));
        OpportunityGroupController controller = new OpportunityGroupController(sc);    
        Profile profile = [select id, Name from profile where Name = 'Менеджер по продажам'];    
        User user = new User(alias = 'tt03', email='testtest03@test.com', emailencodingkey='UTF-8', lastname='Менеджер по продажам', languagelocalekey='en_US', localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='testtest03@test.com');  
        insert user;  
        
        User__c UT = new User__c(User__c = User.Id, Name = 'Менеджер по продажам');
        insert UT;
        controller.ogc.UserTION__c=UT.Id;
        controller.ogc.UserRole__c='Менеджер по продажам';
        controller.ogc.Opportunity__c = opp.Id;
        controller.sendNotification = true;
        controller.saveForm();
        System.RunAs(user){  
            controller.saveForm();
        }
        controller.getItems();         
        controller.delForm();
        controller.userDel = UT.Id;
        controller.getDynamicForm();
        controller.getSetOwnerForm();
        controller.setOwnerForm();
        controller.getDeleteForm();           
        controller.delForm();
        
    }
    
    static testMethod void testCaseInsert(){
        Account account = new Account(Name='Test acc',
                                      Type='Монтажник',
                                      Phone='1234',
                                      ShippingCountry__c='Россия',
                                      ShippingRegion__c='Москва');
        insert account;  
        Opportunity opportunity = new Opportunity(Name='Test opp',StageName='Закупка оборудования',CloseDate=Date.today());
        BusinessProcess bp = [SELECT Id FROM BusinessProcess WHERE Name = 'Тион, продажа О2 дилерам'];
        RecordType rt = [SELECT Id FROM RecordType WHERE BusinessProcessId = :bp.ID limit 1];
        opportunity.RecordTypeId = rt.Id;
        insert opportunity; 
        asset a = new asset(Opportunity__c = opportunity.id, Name='111', accountId = account.Id);
        insert a;
        case c = new Case(AssetId = a.id);
        insert c;
    }
    
    static testMethod void QuoteDelItem(){
        Quote  q = [SELECT Id FROM Quote Limit 1];
        delete q;
    }
}