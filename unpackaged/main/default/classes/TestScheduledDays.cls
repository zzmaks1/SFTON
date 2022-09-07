@isTest(SeeAllData=true)
private class TestScheduledDays {
    
    static testmethod void test() {
        Test.startTest();
        
        User__c UT = new User__c(User__c = UserInfo.getUserId(), Name = 'tester');
        insert UT;
        
        Opportunity opp = new Opportunity(UserTION__c = UT.id);
        opp.Name='Test opp';
        opp.StageName='Подбор оборудования';
        opp.CloseDate=Date.today();
        opp.AuctionDateDesign__c = Date.today();
        opp.RecordTypeId='012b0000000L3bI';
        insert opp;
        
        
    
        
        scheduledDays.scheduleIt();
        String jobID = System.schedule(
            '_unittest_scheduled_: 001',
            '0 0 * * * ? *',
            new scheduledDays()
        );
        
        Test.stopTest();
    
    }     
}