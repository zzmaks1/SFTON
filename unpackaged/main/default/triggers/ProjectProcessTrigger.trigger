trigger ProjectProcessTrigger on Opportunity (after insert, before update, before delete) {
    
    if(trigger.isInsert){
        for (Opportunity opp : Trigger.new){
            RecordType recType = [select developername from RecordType where id=:opp.recordTypeId];
            List<User__c> UT_array = [SELECT User__c, Id, Email__c FROM User__c WHERE Id = :opp.UserTION__c];
            User__c UT = NULL;
            if(!UT_array.isEmpty()) UT = UT_array[0];
                if(recType.DeveloperName != 'O2ProjectType') {
                    try{                        
                        if(UT.User__c != userinfo.getUserId()) opp.addError('Вы не можете назначить ответственным этого сотрудника.');
                        else{
                            OpportunityGroup__c og = new OpportunityGroup__c();
                            og.Opportunity__c = opp.ID;
                            og.UserRole__c = userinfo.getLastName();
                            og.UserTION__c = UT.ID;
                            insert og;
                        }
                        User rop = [SELECT Id, ProfileId FROM user Where LastName = 'Администрация']; 
                        List<User__c> UT1= [SELECT User__c, Id FROM User__c WHERE User__c = :rop.Id];
                        //User rop = [SELECT Id, ProfileId FROM user Where LastName = 'Руководитель отдела продаж'];      
                        if(!UT1.isEmpty()){
                            OpportunityGroup__c og1 = new OpportunityGroup__c();
                            og1.Opportunity__c = opp.ID;
                            og1.UserRole__c = 'Руководитель отдела продаж';                    
                            og1.UserTION__c = UT1[0].ID;
                            insert og1;
                        }
                        List<OpportunityGroup__c> ogp = [SELECT Id FROM OpportunityGroup__c WHERE Opportunity__c = :opp.ID AND UserRole__c = 'Проектировщик'];
                        if(ogp.isEmpty() && recType.DeveloperName == 'DesignStageProjectType'){
                            User rop1 = [SELECT Id, ProfileId FROM user Where LastName = 'Проектировщик']; 
                            UT1 = [SELECT User__c, Id FROM User__c WHERE User__c = :rop1.Id];     
                            if(!UT1.isEmpty()){
                                OpportunityGroup__c og2 = new OpportunityGroup__c();
                                og2.Opportunity__c = opp.ID;
                                og2.UserRole__c = 'Проектировщик';                    
                                og2.UserTION__c = UT1[0].ID;
                                insert og2;
                            }
                        }
                    }
                    catch(System.DMLException e){}
                }
            if(opp.AccountId != null){
                ProjectMember__c projectMember = new ProjectMember__c(OpportunityId__c = opp.Id,
                                                                AccountId__c = opp.AccountId);
                insert projectMember;                
            }
            if(opp.needSendNotification__c == true){
                if(UT.Email__c != NULL && UT.Email__c != ''){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {UT.Email__c});                    
                    mail.setSubject('Новый проект');
                    String htmlBody = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
                    mail.setHtmlBody(htmlBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                }
            }
        }
    }
    if(trigger.IsUpdate && trigger.IsBefore){
        if(Trigger.new[0].StageName != Trigger.old[0].StageName){
            Trigger.new[0].LastStageUpdated__c = datetime.now();
            Trigger.new[0].DaysFromLastStageUpdated__c = 0;
            Trigger.new[0].UpdatedLast__c = datetime.now();
            if(Trigger.new[0].StageName == 'Шеф-монтаж'){     
                User rop = [SELECT Id, ProfileId FROM user Where LastName = 'Администрация' limit 1];
                User__c UT = [SELECT User__c, Id FROM User__c WHERE User__c = :rop.Id];
                OpportunityGroup__c og = new OpportunityGroup__c();
                og.Opportunity__c = Trigger.new[0].ID;
                og.UserRole__c = 'Руководитель сервисной службы';
                og.UserTION__c = UT.ID;
                try{
                    insert og;
                    Trigger.new[0].ownerId = rop.Id;
                    Trigger.new[0].userTION__c = UT.ID;
                }
                catch(System.DmlException e){}
            }
            if(Trigger.new[0].StageName == 'Гарантийная эксплуатация'){ 
                Date dateStart = Trigger.new[0].StartWorkingProducts__c;
                Date dateEnd = Trigger.new[0].StartWorkingProducts__c.addYears(2);
                Map<date, string> service = new Map<date, string>();
                List<Asset> assetList = [SELECT id, ServiceFreq__c, SerialNumber FROM Asset WHERE Opportunity__c = :Trigger.new[0].Id];
                String SerialString;
                Date dateService;
                for(Asset asset: assetList){
                    SerialString = NULL;
                    dateService = dateStart.addDays(Integer.valueOf(asset.ServiceFreq__c));
                    while(dateService <= dateEnd){     
                        if(service.get(dateService) == NULL){
                            service.put(dateService, asset.SerialNumber);   
                        }
                        else{
                            service.put(dateService, service.get(dateService) + ', ' + asset.SerialNumber); 
                        }
                        dateService = dateService.addDays(Integer.valueOf(asset.ServiceFreq__c)); 
                    }
                }
                List<Event> events = new List<Event>();
                Event event;
                for (date dateS: service.keySet())
                {
                    event = new Event();
                    event.Description = 'Серийные номера приборов: ' + service.get(dateS);
                    event.WhatId = Trigger.new[0].Id;
                    event.OwnerId = Trigger.new[0].OwnerId;
                    event.Subject = 'Гарантийное сервисное обслуживание';
                    event.Type = 'Сервис';
                    event.DurationInMinutes = 60;
                    event.activityDate = dateS;
                    event.activityDateTime = Datetime.newInstance(dateS, Time.newInstance(9, 0, 0, 0));
                    events.add(event);
                }
                insert events;
            }
            if(Trigger.new[0].StageName == 'Отгрузка оборудования'){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {'md@tion.info','nn@tion.info'});                    
                mail.setSubject('Проект перешел на этап Отгрузка оборудования');
                String htmlBody = URL.getSalesforceBaseUrl().toExternalForm() + '/' + Trigger.new[0].Id;
                mail.setHtmlBody(htmlBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }
        } 
        if(Trigger.new[0].approval__c == true){
            List<OpportunityGroup__c> mp = [SELECT UserTION__c FROM OpportunityGroup__c WHERE Opportunity__c = :Trigger.new[0].Id AND UserRole__c = 'Региональный менеджер по продажам'];
            if(mp.isEmpty()) Trigger.new[0].addError('Перед утверждением необходимо добавить Регионального менеджера по продажам');
            else{
                Trigger.new[0].approval__c = false;
                Trigger.new[0].UserTION__c = mp[0].UserTION__c;
                User__c userc = [SELECT user__c FROM User__c WHERE Id = :mp[0].UserTION__c];
                Trigger.new[0].ownerId = userc.user__c;
            }
        }
        else if(Trigger.new[0].needProlongation__c == true && (Trigger.new[0].needProlongationText__c == NULL || Trigger.new[0].needProlongationText__c == '')){ 
            Trigger.new[0].needProlongation__c = false;
            Trigger.new[0].LastStageUpdated__c = Trigger.new[0].LastStageUpdated__c.addDays(30); 
            Trigger.new[0].DaysFromLastStageUpdated__c = Integer.valueOf((datetime.now().getTime() - Trigger.new[0].LastStageUpdated__c.getTime())/(60*60*24*1000));
            //изменить срок этапа
        }
        else if(Trigger.old[0].HiddenStageNameBeforeApprovalStarts__c == 'Государственная экспертиза проекта' 
                && Trigger.new[0].HiddenStageNameBeforeApprovalStarts__c == NULL 
                && Trigger.new[0].approval__c == false){
            OpportunityGroup__c mp = [SELECT UserTION__c FROM OpportunityGroup__c WHERE Opportunity__c = :Trigger.new[0].Id AND UserRole__c = 'Менеджер по продажам'];
            Trigger.new[0].UserTION__c = mp.UserTION__c;                    
            User__c userc = [SELECT user__c FROM User__c WHERE Id = :mp.UserTION__c];
            Trigger.new[0].ownerId = userc.user__c;
        }
        
    }
    
    if(trigger.isDelete){
        if(userinfo.getLastName() != 'Системный администратор') Trigger.old[0].addError('Вам запрещено удалять проекты.');   
    }

}