public class StageByBusinessProcess{
    
    public string getNextStage(BusinessProcess bp, String CurrentStage){
        bp = [Select id, Name From BusinessProcess WHERE id = :bp.id limit 1];
        List<string> stages = new List<string>();
        if(bp.name == 'Тион, продажа О2 дилерам'){
            stages.add('Холодный звонок');   
            stages.add('Переговоры (обсуждение условий)');   
            stages.add('Закупка оборудования');   
        }
        else if(bp.name == 'Тион, прямая продажа'){
            stages.add('Закупка оборудования');   
            stages.add('Шеф-монтаж');    
            stages.add('Гарантийная эксплуатация');    
            stages.add('Постгарантийная эксплуатация');  
        }
        else if(bp.name == 'Тион, продажа услуг сервиса'){
            stages.add('Холодный звонок');   
            stages.add('Переговоры (обсуждение условий)');   
            stages.add('Закупка оборудования');   
        }
        else if(bp.name == 'Тион, выбивание конкурентов'){
            stages.add('Отслеживание конкурса на монтаж'); 
            stages.add('Конкурс на монтаж завершен'); 
            stages.add('Переговоры с генподрядчиком');   
            stages.add('КП генподрядчику');   
            stages.add('Заключение договора с генподрядчиком');   
            stages.add('Заказ на производство оборудования');   
            stages.add('Отгрузка оборудования');   
            stages.add('Шеф-монтаж');    
            stages.add('Гарантийная эксплуатация');    
            stages.add('Постгарантийная эксплуатация');  
        }
        else if(bp.name == 'Тион, базовый процесс продаж'){
            stages.add('Отслеживание конкурса на проектирование');   
            stages.add('Переговоры с проектировщиком');   
            stages.add('Подбор оборудования');   
            stages.add('КП Проектировщику');   
            stages.add('Получение копии проекта с оборудованием');   
            stages.add('Государственная экспертиза проекта');    
            stages.add('Отслеживание конкурса на монтаж');   
            stages.add('Конкурс на монтаж завершен'); 
            stages.add('Переговоры с генподрядчиком');   
            stages.add('КП генподрядчику');   
            stages.add('Заключение договора с генподрядчиком');   
            stages.add('Заказ на производство оборудования');   
            stages.add('Отгрузка оборудования');   
            stages.add('Шеф-монтаж');    
            stages.add('Гарантийная эксплуатация');    
            stages.add('Постгарантийная эксплуатация');  
        }
        Boolean eq = false;
        if(CurrentStage == '') eq = true;
        for(string stage : stages){
            if(eq == true) return stage;
            if(CurrentStage == stage){
                eq = true;
            }
        }
        if(eq == true) return CurrentStage;
        return stages[0];
    }
}