@isTest(seeAllData=true)
private class TestApprovingProjectForClosing {

    static testMethod void myUnitTest() {
        
        User__c UT = new User__c(User__c = UserInfo.getUserId(), Name = 'tester');
        insert UT;
        
        Opportunity opp = new Opportunity(UserTION__c = UT.id);
        opp.Name='Test opp';
        opp.StageName='Закрыто как не профиль';
        opp.CloseDate=Date.today();
        insert opp;
        update opp;
        
        Opportunity opp1 = new Opportunity(UserTION__c = UT.id);
        opp1.Name='Test opp';
        opp1.StageName='Закрыто как провал';
        opp1.CloseDate=Date.today();
        insert opp1;
        update opp1;

        Opportunity opp2 = new Opportunity(UserTION__c = UT.id);
        opp2.Name='Test opp';
        opp2.StageName='Закрыто как не профиль';
        opp2.CloseDate=Date.today();
        insert opp2;
        opp2.isClosingRejected__c = true;
        opp2.HiddenStageNameBeforeApprovalStarts__c = 'Переговоры с проектировщиком';
        update opp2;
        
        
        
        Opportunity opp3 = new Opportunity(UserTION__c = UT.id);
        opp3.Name='Test opp';
        opp3.StageName='Закрыто и реализовано';
        opp3.CloseDate=Date.today();
        insert opp3;
        update opp3;
        
       
    }
}