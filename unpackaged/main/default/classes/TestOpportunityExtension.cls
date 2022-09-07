@isTest(seeAllData=true)
private class TestOpportunityExtension {  
    static testMethod void TestOpportunityExtentionController() {
        RecordType recType1 = [select developername from RecordType where Name='Объект на проектирование' and SobjectType = 'Opportunity'];   
        Auction__c auction = new Auction__c(AuctionName__c = 'Description',
                                            AuctionNumber__c = '123',
                                            AuctionRegion__c = 'Республика Татарстан',
                                            AuctionURLLink__c = 'http://salesforce.com',
                                            AuctionStatus__c = 'Не просмотрен');
        insert auction;
        
        Account account = new Account(Name='Test acc',
                                      Type='Монтажник',
                                      Phone='1234',
                                      ShippingCountry__c='Россия',
                                      ShippingRegion__c='Москва');
        insert account;
              
        PageReference pageRef = Page.CustomProjectPage;
        pageRef.getParameters().put('RecordType',recType1.Id);
        pageRef.getParameters().put('auctionId',auction.Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        OpportunityExtentionController controller = new OpportunityExtentionController(sc);
        controller.opp.Name='Test opp';
        controller.opp.StageName='Подбор оборудования';
        controller.opp.CloseDate=Date.today();
        controller.opp.ownerID=userinfo.getUserID();
        controller.sendNotification = true;
        controller.opp.needSendNotification__c = true;
        controller.save();
        
        Opportunity opp = [SELECT id FROM opportunity Where OwnerId = :userinfo.getUserID() limit 1];
        controller.opp.id = opp.id;
        controller.getDynamicForm();
        controller.opp.RecordTypeId = recType1.Id;     
        ProjectMember__c pmc = new ProjectMember__c(AccountId__c = [SELECT id FROM Account Limit 1].id, OpportunityId__c = opp.id, ProjectRoles__c = 'Генпроектировщик, Генподрядчик');
        insert pmc;
        controller.opp.StageName='Подбор оборудования';
        controller.getShowNextStage();
        controller.saveNextStage();
        
        
        asset asset = new asset(Name = '1',ServiceFreq__c = '3', Opportunity__c = opp.id, AccountId = [SELECT id FROM Account Limit 1].id);
        insert asset;
        
        controller.opp.HiddenStageNameBeforeApprovalStarts__c = 'test';
        controller.opp.StageName='Отслеживание конкурса на проектирование';
        controller.saveNextStage();
        controller.opp.StageName='Переговоры с проектировщиком';
        controller.saveNextStage();
        controller.opp.StageName='Подбор оборудования';
        controller.saveNextStage();
        controller.opp.StageName='КП Проектировщику';
        controller.saveNextStage();
        controller.opp.StageName='Отслеживание конкурса на монтаж';
        controller.saveNextStage();
        
        controller.opp.StageName='Шеф-монтаж';
        controller.saveNextStage();
        
        controller.opp.StageName='Гарантийная эксплуатация'; 
        
        opp.StageName='Гарантийная эксплуатация'; 
        opp.StartWorkingProducts__c = date.today();
        update opp;  
        controller.saveNextStage();
        controller.opp.StageName='Шеф-монтаж';
        opp.StageName='Шеф-монтаж';
        act__c act = new act__c(Opportunity__c = opp.id);
        insert act;
        
        opp.StartWorkingProducts__c = date.today();
        controller.opp.StartWorkingProducts__c = opp.StartWorkingProducts__c;
        controller.saveNextStage();
        controller.opp.StageName='Отгрузка оборудования';
        controller.saveNextStage();
        controller.opp.StageName='Холодный звонок';
        controller.saveNextStage();
        controller.opp.StageName='Переговоры (обсуждение условий)';
        controller.saveNextStage();
        
        User admUser = [SELECT Id, ProfileId FROM user Where LastName = 'Администрация']; 
        List<User__c> tionUser = [SELECT User__c, Id FROM User__c WHERE User__c = :admUser.Id];    
        if(!tionUser.isEmpty()){
            OpportunityGroup__c oppgroup = new OpportunityGroup__c();
            oppgroup.Opportunity__c = opp.ID;
            oppgroup.UserRole__c = 'Руководитель отдела продаж';                    
            oppgroup.UserTION__c = tionUser[0].ID;
            insert oppgroup;
            controller.opp.HiddenStageNameBeforeApprovalStarts__c = null;  
            controller.opp.StageName='Государственная экспертиза проекта';
            controller.opp.needStateReview__c = true;
            opp.HiddenStageNameBeforeApprovalStarts__c = null;
            opp.StageName='Государственная экспертиза проекта';
            opp.needStateReview__c = true;
            update opp; 
            controller.saveNextStage();     
        }
        
        
    }
    
    static testMethod void TestOpportunityExtentionController2() {
        RecordType recType1 = [select developername from RecordType where Name='Объект на проектирование' and SobjectType = 'Opportunity'];     
        RecordType recType2 = [select developername from RecordType where Name='Объект на монтаж' and SobjectType = 'Opportunity'];
        RecordType recType3 = [select developername from RecordType where Name='Продажа Тион О2 дилерам' and SobjectType = 'Opportunity'];
        Auction__c auction = new Auction__c(AuctionName__c = 'Description',
                                            AuctionNumber__c = '123',
                                            AuctionRegion__c = 'Республика Татарстан',
                                            AuctionURLLink__c = 'http://salesforce.com',
                                            AuctionStatus__c = 'Не просмотрен');
        insert auction;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        OpportunityExtentionController controller = new OpportunityExtentionController(sc);
        Opportunity opp = [SELECT id FROM opportunity Where OwnerId = :userinfo.getUserID() limit 1];
        
            PageReference pageRef = Page.CustomProjectPage;
            pageRef.getParameters().put('RecordType',recType2.Id);
            pageRef.getParameters().put('auctionId',auction.Id);
            Test.setCurrentPageReference(pageRef);
            sc = new ApexPages.StandardController(new Opportunity());
            controller = new OpportunityExtentionController(sc);
            controller.opp.Name='Test opp';
            controller.opp.StageName='Подбор оборудования';
            controller.opp.CloseDate=Date.today();
            controller.save();
        
        pageRef = Page.CustomProjectPage;
        pageRef.getParameters().put('RecordType',recType3.Id);
        pageRef.getParameters().put('auctionId',NULL);
        Test.setCurrentPageReference(pageRef);
        sc = new ApexPages.StandardController(new Opportunity());
        controller = new OpportunityExtentionController(sc);
        controller.opp.Name='Test opp';
        controller.opp.StageName='Подбор оборудования';
        controller.opp.CloseDate=Date.today();
        Profile profile = [select id, Name from profile where Name = 'Проектировщик'];    
        User user = new User(alias = 'tt04', email='testtest04@test.com', emailencodingkey='UTF-8', lastname='Проектировщик', languagelocalekey='en_US', localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='testtest04@test.com');  
        insert user;  
        System.RunAs(user){  
            controller.save();
        }
        
        User rop = [SELECT Id, ProfileId FROM user Where LastName = 'Администрация']; 
        List<User__c> UT = [SELECT User__c, Id FROM User__c WHERE User__c = :rop.Id];    
        if(!UT.isEmpty()){
            OpportunityGroup__c og1 = new OpportunityGroup__c();
            og1.Opportunity__c = opp.ID;
            og1.UserRole__c = 'Региональный менеджер по продажам';                    
            og1.UserTION__c = UT[0].ID;
            insert og1;        
            opp.approval__c = true;
            update opp;
        }        
        
        opp.StageName='Отгрузка оборудования';
        update opp;
    }    
}