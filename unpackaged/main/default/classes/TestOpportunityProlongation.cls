@isTest(seeAllData=true)
private class TestOpportunityProlongation {  
    static testMethod void TestOpportunityProlongationController() {
        PageReference pageRef =  Page.OpportunityProlongation;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        OpportunityProlongationController controller2 = new OpportunityProlongationController(sc);        
        Opportunity opp = [SELECT id FROM opportunity limit 1 OFFSET 2];
        controller2.opp.id = opp.id;
        controller2.opp.needProlongationText__c = 'test';
        controller2.getShowLong();
        controller2.saveLong();
        
        
    }
}