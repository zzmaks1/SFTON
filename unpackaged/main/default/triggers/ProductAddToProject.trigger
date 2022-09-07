trigger ProductAddToProject on OpportunityLineItem (before insert, before update) {
    String name;
    Integer med = 0;
    Integer prom = 0;
    ID oppId = Trigger.new[0].OpportunityId;
    Opportunity opp = [SELECT RecordTypeId, StageName, OwnerId FROM Opportunity WHERE id = :oppId];
    BusinessProcess bp = [Select id, Name From BusinessProcess WHERE id in (SELECT BusinessProcessId FROM RecordType WHERE Id =: opp.RecordTypeId ) limit 1];
    Pricebook2 zap_pb = [select id from Pricebook2 where name='Запчасти Тион'];
    
    if(bp.name == 'Тион, продажа О2 дилерам'){
        if(opp.StageName != 'Переговоры (обсуждение условий)' && opp.StageName != 'Закупка оборудования'){
            Trigger.new[0].addError('Нельзя добавить продукты на данном этапе проекта.');
        }
        else
        for (OpportunityLineItem o : Trigger.new) { 
            PricebookEntry p = [select Product2.name from PricebookEntry where Id=:o.PricebookEntryId];
            name = p.Product2.name;
            if(name.toUpperCase().indexOf('ТИОН O2', 0) >= 0 || name.toUpperCase().indexOf('ТИОН О2', 0) >= 0){                   
            }
            else{
                o.addError('Проект может содержать только продукт “Компактная вентиляционная система Тион О2”');
            }
        }
    }
    else if(bp.name == 'Тион, продажа услуг сервиса'){
        if(opp.StageName != 'Переговоры (обсуждение условий)' && opp.StageName != 'Закупка оборудования'){
            Trigger.new[0].addError('Нельзя добавить продукты на данном этапе проекта.');
        }
//        else
//        for (OpportunityLineItem o : Trigger.new) { 
//            PricebookEntry p = [select Product2.name, Pricebook2Id from PricebookEntry where Id=:o.PricebookEntryId];
//            if(p.Pricebook2Id != zap_pb.Id) o.addError('Проект может содержать продукты только из прайс-листа "Запчасти Тион"');
//        }
    }
    else{
        for (OpportunityLineItem o : [select PricebookEntryId from OpportunityLineItem where OpportunityId = :oppId]) { 
            PricebookEntry p = [select Product2.name from PricebookEntry where Id=:o.PricebookEntryId];
            name = p.Product2.name;
            if(name.toUpperCase().indexOf('МЕД', 0) >= 0){
                med++;
            }
            else  if(name.toUpperCase().indexOf('ТИОН O2', 0) >= 0 || name.toUpperCase().indexOf('ТИОН О2', 0) >= 0){
            }            
            else {
                prom++;
            }
        }
        for (OpportunityLineItem o : Trigger.new) { 
            PricebookEntry p = [select Product2.name, Pricebook2Id from PricebookEntry where Id=:o.PricebookEntryId];
            name = p.Product2.name;
            if(p.Pricebook2Id == zap_pb.Id) o.addError('Проект не может содержать продукты из прайс-листа "Запчасти Тион"');
            else if((opp.OwnerId != userinfo.getUserId() && !(userinfo.getLastName() == 'Проектировщик' && (opp.StageName == 'Подбор оборудования' || opp.StageName == 'КП проектировщику')))
               || opp.StageName == 'Отслеживание конкурса на проектирование' || opp.StageName == 'Переговоры с проектировщиком') o.addError('На текущем этапе вы не можете добавлять продукты. Проект должен находится на этапе "Подбор оборудования" или "КП проектировщику", или Вам запрещено добавлять продукты в этот проект.');
            else if(name.toUpperCase().indexOf('МЕД', 0) >= 0){
                med++;
            }
            else  if(name.toUpperCase().indexOf('ТИОН O2', 0) >= 0 || name.toUpperCase().indexOf('ТИОН О2', 0) >= 0){
            } 
            else{
                prom++;
            }
        }
        if(med > 0 && prom > 0){
            for (OpportunityLineItem o : Trigger.new) {             
                if(name.toUpperCase().indexOf('ТИОН O2', 0) >= 0 || name.toUpperCase().indexOf('ТИОН О2', 0) >= 0){
                } 
                else o.addError('Продукты типа Мед и Пром не могут быть прикреплены одновременно к одному проекту');
            }
        }    
    }
}