trigger ProductAddToProjectChangePrice on OpportunityLineItem (before insert, before update) {
    Decimal total = 0;
    ID oppId;
    oppId = Trigger.new[0].OpportunityId;
    Opportunity opp = [SELECT Id, Amount, RecordTypeId FROM Opportunity WHERE Id = :oppId];
    BusinessProcess bp = [Select id, Name From BusinessProcess WHERE id in (SELECT BusinessProcessId FROM RecordType WHERE Id =: opp.RecordTypeId ) limit 1];
    List<ProjectMember__c> contractor = [SELECT AccountId__c, ProjectRoles__c FROM ProjectMember__c WHERE OpportunityId__c = :oppId];
    if(contractor.size() > 0) for(integer i = 0; i < contractor.size(); i++){
        if(contractor[i].ProjectRoles__c != null && contractor[i].ProjectRoles__c.toUpperCase() == 'ДИЛЕР'){
            List<Account> acc = [SELECT discount__c FROM Account WHERE Id = :contractor[i].AccountId__c];
            if(acc.size() > 0 && acc[0].discount__c != null){    
                LIST<OpportunityLineItem> oli = [SELECT id, Discount FROM OpportunityLineItem WHERE OpportunityId = :Trigger.new[0].OpportunityId];
                for (OpportunityLineItem o : oli) { 
                    if(o.id != Trigger.new[0].id){
                        o.Discount = acc[0].discount__c;
                        update o;
                    }
                    else  Trigger.new[0].Discount = acc[0].discount__c;
                }           
            }
        } 
    }
}