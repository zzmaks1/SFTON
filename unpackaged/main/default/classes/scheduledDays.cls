global class scheduledDays implements Schedulable {
     

    global static String scheduleIt() {
        String ret = 'ok';
        try{
            for(Integer j=0; j< 60; j = j + 2){
        		System.schedule('Last State Days Update ' + String.valueOf(j) + '', '0 ' + String.valueOf(j) + ' * * * ? *', new scheduledDays());
            }
        }
        catch(System.DMLException e){
        	ret = String.valueOf(e);   
        }   
        return ret;
    }
     
    global void execute(SchedulableContext sc) {
    	List<Opportunity> opp = [SELECT id, LastStageUpdated__c, DaysFromLastStageUpdated__c, UpdatedLast__c, StageName FROM Opportunity WHERE UpdatedLast__c != TODAY];
        Integer i = 0;
        if(!opp.isEmpty()) for(Integer j=0; j< opp.size() && i < 45; j++){
            if(opp[j].StageName != 'Закрыто как не профиль' && opp[j].StageName != 'Закрыто как провал'){
                if(opp[j].LastStageUpdated__c == NULL){
                    OpportunityHistory oh = [SELECT id, CreatedDate, StageName FROM OpportunityHistory WHERE OpportunityId = :opp[j].id AND isDeleted = false ORDER BY CreatedDate DESC LIMIT 1];
                    opp[j].LastStageUpdated__c = oh.CreatedDate;
                } 
                Integer days = Integer.valueOf((datetime.now().getTime() - opp[j].LastStageUpdated__c.getTime())/(60*60*24*1000));
                opp[j].DaysFromLastStageUpdated__c = days;
                opp[j].UpdatedLast__c = datetime.now();
                try{
                    update opp[j];
                }
                catch(System.DMLException e){}
                i++;
            }
        }
        
    }
}