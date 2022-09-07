trigger ApproveProjectClosingTrigger on Opportunity (before update,after update) {
    for(Opportunity o: Trigger.new){
        if(Trigger.isAfter && o.StageName == 'Закрыто как не профиль'){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Прошу утвердить закрытие проекта как не профильного для нас. Причина: ' + o.Description);
            req1.setObjectId(o.id);
            try{
            	Approval.ProcessResult result = Approval.process(req1);
            }
            catch(System.DmlException e){}
        }
        if(Trigger.isAfter && o.StageName == 'Закрыто как провал'){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Прошу утвердить закрытие проекта как провал. Причина: ' + o.Description);
            req1.setObjectId(o.id);
            try{
            	Approval.ProcessResult result = Approval.process(req1);
            }
            catch(System.DmlException e){}
        }
        if(Trigger.isAfter && o.StageName == 'Закрыто и реализовано'){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Прошу утвердить закрытие проекта. Причина: ' + o.Description);
            req1.setObjectId(o.id);
            try{
            	Approval.ProcessResult result = Approval.process(req1);
            }
            catch(System.DmlException e){}
        }
        
        if(Trigger.isBefore && o.isClosingRejected__c){
            o.StageName = o.HiddenStageNameBeforeApprovalStarts__c;
            o.isClosingRejected__c = false;
        }
    }
}