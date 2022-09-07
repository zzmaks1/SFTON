public with sharing class ContractorLookupController {
    
    public final ProjectMember__c contractor;
    
    public ContractorLookupController() {
        Id accountId = ApexPages.currentPage().getParameters().get('accountId');
        Id oppId = ApexPages.currentPage().getParameters().get('oppId');
        contractor = new ProjectMember__c(AccountId__c = accountId, OpportunityId__c = oppId);
        
    }
    
    public ProjectMember__c getContractor() {
        return contractor;
    }
    
    
    public PageReference cancel() {
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }


    public PageReference save() {
                  
        Opportunity opp = [SELECT RecordTypeId FROM Opportunity WHERE id = :contractor.OpportunityId__c];
        BusinessProcess bp = [Select id, Name From BusinessProcess WHERE id in (SELECT BusinessProcessId FROM RecordType WHERE Id =: opp.RecordTypeId ) limit 1];
        if(((bp.name == 'Тион, продажа О2 дилерам' || bp.name == 'Сделка') && contractor.ProjectRoles__c.toUpperCase() != 'ДИЛЕР') || ((bp.name == 'Тион, продажа О2 дилерам' || bp.name == 'Сделка') && contractor.ProjectRoles__c.toUpperCase().indexOf('ДИЛЕР', 0) >= 0)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Тип “Дилер” может быть добавлен только к типу возможности “Продажа Тион О2 дилерам” и с такой ролью в возможности может быть только одна организация. Добавление организаций с другими ролями к типу возможности “Продажа Тион О2 дилерам” запрещено'));
            return null;
        }
        if(bp.name == 'Тион, продажа О2 дилерам'){
            List<ProjectMember__c> ProjectMember = [SELECT AccountId__c FROM ProjectMember__c WHERE OpportunityId__c = :contractor.OpportunityId__c];
            if(ProjectMember.size() > 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'К проекту уже добавлена организация с ролью Дилер - можно добавить только одну организацию с такой ролью.'));
                return null;
            }
        }
        insert contractor;
        if(bp.name == 'Тион, продажа О2 дилерам'){             
            Account acc = [SELECT discount__c FROM Account WHERE Id = :contractor.AccountId__c];
            for (OpportunityLineItem o : [select Discount from OpportunityLineItem where OpportunityId = :contractor.OpportunityId__c]) {   
                o.Discount = acc.discount__c;
                update o;
            }
        }
        
        return new PageReference(ApexPages.currentPage().getParameters().get('saveURL'));
    }
    
   
}