@isTest(SeeAllData=true)
private class TestDailyReportSender {

    static testMethod void testReportSending() {
        User__c user = new User__c(Name = 'Test user', Email__c='test@tion.info', User__c =UserInfo.getUserId() );
        insert user;
        DailyReportSender drs = new DailyReportSender();
        List<SelectOption> tionUsers = drs.tionUsers;
        drs.selectedUserId = (String) user.Id;
        //User__c user = [select Id, Name,Email__c from User__c where Id=:UserInfo.getUserId()];
        Account acc = new Account(Name='Организация',
                                Type='Proektirovwik',
                                Phone='1234',
                                ShippingCountry__c='Rossia',
                                ShippingRegion__c='Msk');
        insert acc;
        Contact contact = new Contact(LastName = 'familia',AccountId=acc.Id);
        insert contact;
        Task t1 = new Task(Subject = 'Task subject',
                            Type = 'Входящий вызов',
                            ActivityDate = Date.today(),
                            WhoId = contact.Id,
                            Description = 'описание',
                            TionOwner__c = 'Test user');
        Event e1 = new Event(Subject = 'Event subject',
                            Type = 'Event type',
                            ActivityDateTime = DateTime.now(),
                            DurationInMinutes = 15,
                            WhoId = contact.Id,
                            Description = 'Event description',
                            TionOwner__c = 'Test user');
        Task t2 = new Task(Subject = 'Task subject',
                            Type = 'Входящий вызов',
                            ActivityDate = Date.today(),
                            WhoId = contact.Id,
                            Description = 'описание',
                            TionOwner__c = 'Test user');
        Event e2 = new Event(Subject = 'Event subject',
                            Type = 'Event type',
                            ActivityDateTime = DateTime.now(),
                            DurationInMinutes = 15,
                            WhoId = contact.Id,
                            Description = 'Event description',
                            TionOwner__c = 'Test user');
        User__c UT = new User__c(User__c = UserInfo.getUserId(), Name = 'tester');
        insert UT;
        Opportunity opportunity = new Opportunity(Name='Test opp',StageName='test',CloseDate=Date.today(), UserTION__c = UT.id);
        insert opportunity;
        Quote quote = new Quote(Name = 'test', OpportunityId = opportunity.Id, Organisation__c = acc.id);
        insert quote;
        Contract contract = new Contract(AccountId=acc.Id,StartDate=Date.today(),ContractTerm=24);
        contract.Prepayment_days__c = 5;
        contract.Partpayment_days__c = 5;
        contract.Postpayment_days__c = 5;              
        contract.ProjectName__c = opportunity.Id;
        contract.Smeta__c = quote.Id;
        contract.AccountCEO__c = 'test';
        contract.AccountBillingName__c = 'test';
        contract.AccountCEOAct__c = 'test';
        contract.SignatureInitials__c = 'test';
        contract.SpecificationDate__c = Date.valueOf('2013-04-10'); 
        contract.CompanyDeliverTo__c = 'test';
        contract.DeliveryDuration__c = 'test';
        contract.Partpayment__c = 30;
        contract.Postpayment__c = 30;
        contract.Prepayment__c = 40;
        contract.ContractNumber__c = 'TT/11112022';
        insert contract;
        t1.WhatId = contract.Id;
        e1.WhatId = contract.Id;
        insert t1;
        insert e1;
        t2.WhatId = acc.Id;
        e2.WhatId = acc.Id;
        insert t2;
        insert e2;
        drs.setUserID(user.Id);
        drs.startSend();
        drs.startSend();
        drs.startSend();
        drs.startSend();
        drs.startSend();
        drs.startSend();
        drs.getStringCounts();
        drs.gethtml(); 
    }
}