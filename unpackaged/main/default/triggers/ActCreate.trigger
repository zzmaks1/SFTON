trigger ActCreate on act__c (before Insert, before Update) {
    ID oppId = Trigger.new[0].Opportunity__c;
    Opportunity opp = [SELECT StartWorkingProducts__c FROM Opportunity WHERE id = :oppId];
    //if(opp.StartWorkingProducts__c == NULL) Trigger.new[0].addError('Укажите дату ввода оборудования в эксплуатацию в проекте!');
    LIST<act__c> exists = [SELECT Id FROM act__c WHERE Opportunity__c = :oppId];
    if(!exists.isEmpty()) Trigger.new[0].addError('К этому проекту уже добавлен акт шеф-монтажа.');
}