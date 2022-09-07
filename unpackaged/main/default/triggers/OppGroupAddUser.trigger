trigger OppGroupAddUser on OpportunityGroup__c (before Insert) {
    Map<string, string> AllowRoles = new Map<string, string>{'Менеджер по продажам'=>'Менеджер по продажам', 
        'Руководитель отдела продаж'=>'Администрация', 
        'Региональный менеджер по продажам'=>'Менеджер по продажам', 
        'Руководитель сервисной службы'=>'Администрация', 
        'Сервисный инженер'=>'Сервисный инженер', 
        'Проектировщик'=>'Проектировщик'};
    OpportunityGroup__c og = Trigger.new[0];
    Opportunity opp = [SELECT Id, OwnerId, StageName, UserTION__c FROM Opportunity WHERE Id = :og.Opportunity__c ];
    List<OpportunityGroup__c> oglist = [SELECT Id FROM OpportunityGroup__c WHERE Opportunity__c = :opp.Id AND UserRole__c = :og.UserRole__c];
    User__c uc = [SELECT User__c FROM User__c WHERE Id = :og.UserTION__c];
    User user = [SELECT LastName FROM User WHERE Id = :uc.User__c];
    if(!oglist.isEmpty() && userinfo.getLastName() != 'Системный администратор' && userinfo.getLastName() != 'Администрация') og.addError('Пользователь с ролью "' + og.UserRole__c + '" уже добавлен в группу.');
    if(AllowRoles.get(og.UserRole__c) != user.LastName && userinfo.getLastName() != 'Системный администратор' && userinfo.getLastName() != 'Администрация') og.addError('Этот пользователь не может быть добавлен с выбранной ролью');
    if(userinfo.getUserId() != opp.ownerId && userinfo.getLastName() != 'Системный администратор' && userinfo.getLastName() != 'Администрация') og.addError('Вы не можете добавлять пользователей в группу');
    
    if(userinfo.getLastName() == 'Проектировщик'){
        if (opp.StageName != 'Отслеживание конкурса на проектирование' || (og.UserRole__c != 'Менеджер по продажам' && og.UserRole__c != 'Проектировщик' && og.UserRole__c != 'Руководитель отдела продаж')) og.addError('Вы не можете добавить этого пользователя');
    }
    
    if (opp.StageName == 'Отслеживание конкурса на проектирование' && og.UserRole__c == 'Менеджер по продажам'){
        opp.UserTION__c = og.UserTION__c;        
        update opp;
    }
}