trigger setOpportunityAccountName on ProjectMember__c (after insert, after update) {
    Opportunity opp = [SELECT AccountId FROM Opportunity WHERE id = :Trigger.new[0].OpportunityId__c];
    opp.AccountId = Trigger.new[0].AccountId__c;
    update opp;
}