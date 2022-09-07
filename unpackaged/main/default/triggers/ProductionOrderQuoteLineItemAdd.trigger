trigger ProductionOrderQuoteLineItemAdd on ProductionOrder__c (after insert) {
	List<QuoteLineItem> qlnList = [SELECT id, PricebookEntry.Product2.Name, Quantity, SectionComposition__c FROM QuoteLineItem WHERE QuoteId = :Trigger.new[0].Quote__c];
    List<ProductionOrderItemLine__c> poli = new LIST<ProductionOrderItemLine__c>();
    Integer i = 1;
    for(QuoteLineItem qln:qlnList){
        poli.add(new ProductionOrderItemLine__c(CountItems__c = qln.Quantity, 
                                                ProductName__c = qln.PricebookEntry.Product2.Name, SectionComposition__c = qln.SectionComposition__c, NumberPP__c = i,
                                               	ProductionOrder__c = Trigger.new[0].ID));
    	i++;
    }
    insert poli;
}