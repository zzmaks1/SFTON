trigger SpecificType on Contract (before insert, before update) {
    String name;
    Integer med = 0;
    Integer prom = 0;
    ID qId = Trigger.new[0].Smeta__c;
    for (QuoteLineItem o : [select PricebookEntryId from QuoteLineItem where QuoteId = :qId]) { 
        PricebookEntry p = [select Product2.name from PricebookEntry where Id=:o.PricebookEntryId];
        name = p.Product2.name;
        if(name.toUpperCase().indexOf('МЕД', 0) >= 0){
            med++;
        }
        else{
            prom++;
        }
    }
    if( Trigger.new[0].SpecificationType__c == 'Медоборудование' ||  Trigger.new[0].SpecificationType__c == 'Экспорт'){
        if(prom > 0){
            Trigger.new[0].SpecificationType__c.addError('Тип спецификации не соответствует типу продуктов в смете. Измените тип спецификации, либо укажите другую смету в поле "Смета"');
        }
    }
    else{
        if(med > 0){        
            Trigger.new[0].SpecificationType__c.addError('Тип спецификации не соответствует типу продуктов в смете. Измените тип спецификации, либо укажите другую смету в поле "Смета"');
        }
    } 
}