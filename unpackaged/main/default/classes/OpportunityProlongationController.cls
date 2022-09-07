public class OpportunityProlongationController{
    public Opportunity opp;
    private final ApexPages.StandardController stdController;

    public OpportunityProlongationController(ApexPages.StandardController controller) {
        //controller.addFields(new String[]{'Name', 'StageName', 'LeadSource', 'ProjectProperties__c', 'isBillPaid__c', 'Description', 'Type', 'ProjectRegion__c', 'isProblematicProject__c', 'AuctionLinkDesign__c', 'AuctionLinkMounting__c', 'DesignAuctionNumber__c', 'MountingAuctionNumber__c', 'AuctionNameDesign__c', 'AuctionNameMounting__c', 'AuctionDateDesign__c', 'AuctionDateMounting__c', 'ActualAmount__c', 'CloseDate', 'RecordTypeId'});
        stdController = controller;
        opp = (Opportunity)controller.getRecord();
    }   
    
    public Component.Apex.PageBlock getShowLong() {
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlock';
        dynPageBlock.mode = 'LongBut';
        dynPageBlock.title = 'Перейти к следующему этапу';
        Component.Apex.PageBlockButtons dynPageBlockButtons = new Component.Apex.PageBlockButtons();
        Component.Apex.commandButton dynButtonSave = new Component.Apex.commandButton();
        dynButtonSave.expressions.action = '{!saveLong}';
        dynButtonSave.value = 'Сохранить';
        Component.Apex.commandButton dynButtonCancel = new Component.Apex.commandButton();
        dynButtonCancel.expressions.action = '{!cancel}';
        dynButtonCancel.value = 'Отмена';
        dynButtonCancel.immediate = true;
        Component.Apex.PageBlockSection dynPageBlockSection = new Component.Apex.PageBlockSection();  
        Component.Apex.InputField dynText = new Component.Apex.InputField();
        dynText.id = 'needProlongationText__c';
        dynText.label = 'Укажите причину продления';
        dynText.expressions.value = '{!Opportunity.needProlongationText__c}';
        Component.Apex.PageMessages dynPageMessages = new Component.Apex.PageMessages();
        Component.Apex.PageMessage dynPageMessage = new Component.Apex.PageMessage();
        dynPageMessage.severity = 'warning';
        Boolean may = false;
        Profile profile = [Select Name from Profile where Id = :UserInfo.getProfileId()];
        User rop = [SELECT Id, ProfileId FROM user Where LastName = 'Менеджер по продажам'];        
        dynPageMessage.summary = 'Проект не нуждается в продлении.';
        if(opp.LastStageUpdated__c == NULL){
        	OpportunityHistory oh = [SELECT id, CreatedDate, StageName FROM OpportunityHistory WHERE OpportunityId = :opp.id AND isDeleted = false ORDER BY CreatedDate DESC LIMIT 1];
            opp.LastStageUpdated__c = oh.CreatedDate;
        }        
        if(
            (opp.StageName == 'Отслеживание конкурса на проектирование' && opp.LastStageUpdated__c.addDays(60) < datetime.now()) ||
            (opp.StageName == 'Переговоры с проектировщиком' && opp.LastStageUpdated__c.addDays(120) < datetime.now()) ||
            (opp.StageName == 'Подбор оборудования' && opp.LastStageUpdated__c.addDays(120) < datetime.now()) ||
            (opp.StageName == 'КП Проектировщику' && opp.LastStageUpdated__c.addDays(120) < datetime.now()) ||
            (opp.StageName == 'Получение копии проекта с оборудованием' && opp.LastStageUpdated__c.addDays(120) < datetime.now()) ||
            (opp.StageName == 'Государственная экспертиза проекта' && opp.LastStageUpdated__c.addDays(120) < datetime.now()) ||
            (opp.StageName == 'Отслеживание конкурса на монтаж' && opp.LastStageUpdated__c.addDays(365) < datetime.now()) ||
            (opp.StageName == 'Переговоры с генподрядчиком' && opp.LastStageUpdated__c.addDays(60) < datetime.now()) ||
            (opp.StageName == 'КП генподрядчику' && opp.LastStageUpdated__c.addDays(60) < datetime.now()) ||
            (opp.StageName == 'Заключение договора с генподрядчиком' && opp.LastStageUpdated__c.addDays(60) < datetime.now()) ||
            (opp.StageName == 'Заказ на производство оборудования' && opp.LastStageUpdated__c.addDays(60) < datetime.now())          
        ){
            may = true;         
        } 
        if(may) dynPageBlockButtons.childComponents.add(dynButtonSave);        
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlock.childComponents.add(dynPageMessages);
        if(!may)dynPageBlock.childComponents.add(dynPageMessage);
        if(may)dynPageBlockSection.childComponents.add(dynText);
        dynPageBlock.childComponents.add(dynPageBlockSection);        
        return dynPageBlock;
    }
    
    public class StageException extends Exception {}
    
    public PageReference saveLong() {
        PageReference redirectPage;
        Opportunity opp_stage = opp;
        try{
            if(opp.needProlongationText__c == NULL || opp.needProlongationText__c == '') throw new StageException('Необходимо заполнить причину продления.');
        } catch(StageException e) {
            ApexPages.addMessages(e);
            return null;
        }
        opp_stage.needProlongation__c = true;
        update opp_stage;
        try {                
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(opp.id);
            req1.setComments(opp.needProlongationText__c);
            Approval.ProcessResult result = Approval.process(req1);   
            redirectPage = stdController.view();            
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }
}