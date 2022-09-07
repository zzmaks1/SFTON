trigger CaseSetOpp on Case (before insert, before update) {
	
        for (Case c : Trigger.new) {
            List<Asset> asset = [SELECT id, Opportunity__c FROM Asset WHERE id = :c.AssetId];
            if(!asset.isEmpty()) c.Opportunity__c = asset[0].Opportunity__c;
        }
}