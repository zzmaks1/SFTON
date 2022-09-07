public class OpportunityExtentionController {
    public Opportunity opp;
    private final ApexPages.StandardController stdController;    
    public Boolean sendNotification{get; set;}

    public OpportunityExtentionController(ApexPages.StandardController controller) {
        //controller.addFields(new String[]{'Name', 'StageName', 'LeadSource', 'ProjectProperties__c', 'isBillPaid__c', 'Description', 'Type', 'ProjectRegion__c', 'isProblematicProject__c', 'AuctionLinkDesign__c', 'AuctionLinkMounting__c', 'DesignAuctionNumber__c', 'MountingAuctionNumber__c', 'AuctionNameDesign__c', 'AuctionNameMounting__c', 'AuctionDateDesign__c', 'AuctionDateMounting__c', 'ActualAmount__c', 'CloseDate', 'RecordTypeId'});
        stdController = controller;
        opp = (Opportunity)controller.getRecord();
        sendNotification = false;
        String auctionId = ApexPages.currentPage().getParameters().get('auctionId');
        String recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        if(auctionId != null && auctionId != ''){
            try {
                Auction__c auction = [select AuctionName__c,AuctionNumber__c,
                                      AuctionRegion__c,AuctionURLLink__c, UserTION__c from Auction__c where id=:auctionId]; 
                RecordType recType = [select developername from RecordType where id=:recordTypeId];
                opp.ProjectRegion__c = auction.AuctionRegion__c;
                opp.UserTION__c = auction.UserTION__c;
                if(recType.DeveloperName != 'BuildingStageProjectType'){
                    opp.AuctionNameDesign__c = auction.AuctionName__c;
                    opp.DesignAuctionNumber__c = auction.AuctionNumber__c;
                    opp.AuctionLinkDesign__c = auction.AuctionURLLink__c;
                } else {
                    opp.AuctionNameMounting__c = auction.AuctionName__c;
                    opp.MountingAuctionNumber__c = auction.AuctionNumber__c;
                    opp.AuctionLinkMounting__c = auction.AuctionURLLink__c;
                }
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
            }
        }
    }

    public PageReference save() {
        String auctionId = ApexPages.currentPage().getParameters().get('auctionId');
        String recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        Integer stageIndex = 0;
        PageReference redirectPage;
        try {                
            List<User__c> UT = [SELECT User__c, Id FROM User__c WHERE Id = :opp.UserTION__c];
            if(auctionId != null && auctionId != ''){
                Auction__c auction = [select AuctionStatus__c from Auction__c where id=:auctionId];
                auction.AuctionStatus__c = 'Конвертирован в проект';
                update auction;
            }
            else if(userinfo.getLastName() == 'Проектировщик') {                 
                try{
                    throw new StageException('Вам запрещено создание и редактирование проектов.');
                }
                catch(StageException e){
                    ApexPages.addMessages(e);
                    return null;
                }
            }
            if(opp.Id == null) { //Check if we are editing or creating opportunity
                Profile cuser = [select Name from profile where id = :userinfo.getProfileId() limit 1];
                if(recordTypeId != null) {
                    RecordType recType = [select developername from RecordType where id=:recordTypeId];
                    if(recType.DeveloperName == 'BuildingStageProjectType'){
                        stageIndex = 6;                        
                    }
                    if(recType.DeveloperName == 'O2ProjectType') stageIndex = 20;                    
                    if(recType.DeveloperName == 'ServiceProjectType') stageIndex = 20;             
                    if(recType.DeveloperName == 'DealProjectType') stageIndex = 22;
                    if((recType.DeveloperName == 'BuildingStageProjectType' || recType.DeveloperName == 'DesignStageProjectType') && sendNotification){
                        opp.needSendNotification__c = true;
                    }
                }
                else{                  
                    if(cuser.Name == 'Менеджер по продажам Тион О2'){
                        stageIndex = 20;
                    }
                    if(cuser.Name == 'Менеджер сервисного отдела'){
                        stageIndex = 20;
                    }
                }
                opp.StageName = Opportunity.StageName.getDescribe().getPicklistValues().get(stageIndex).getValue();
            }
            else if(opp.OwnerId != userinfo.getUserId()) {  
                ApexPages.addMessages(new StageException('Вам запрещено редактирование проекта.'));
                return null;
            }
            if(!UT.isEmpty()) opp.OwnerId = UT[0].User__c;
            redirectPage = stdController.save();            
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }

    public Opportunity opp_public {
        get {
            return opp;
        }
    }

    public Component.Apex.PageBlock getDynamicForm() {
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlock';
        dynPageBlock.mode = 'edit';
        dynPageBlock.title = 'Редактировать проект';
        Component.Apex.PageBlockButtons dynPageBlockButtons = new Component.Apex.PageBlockButtons();
        Component.Apex.commandButton dynButtonSave = new Component.Apex.commandButton();
        dynButtonSave.expressions.action = '{!save}';
        dynButtonSave.value = 'Сохранить';
        Component.Apex.commandButton dynButtonCancel = new Component.Apex.commandButton();
        dynButtonCancel.expressions.action = '{!cancel}';
        dynButtonCancel.value = 'Отмена';
        dynButtonCancel.immediate = true;
        Component.Apex.PageMessages dynPageMessages = new Component.Apex.PageMessages();        
        Component.Apex.PageBlockSection dynPageBlockSection1 = new Component.Apex.PageBlockSection();
        dynPageBlockSection1.columns = 2;
        dynPageBlockSection1.collapsible = false;        
        Component.Apex.InputField fieldName = new Component.Apex.InputField();
        fieldName.id = 'Name';
        fieldName.label = 'Наименование';
        fieldName.expressions.value = '{!Opportunity.Name}';
        Component.Apex.InputField fieldActualAmount = new Component.Apex.InputField();
        fieldActualAmount.id = 'ActualAmount__c';
        fieldActualAmount.label = 'Сумма прихода денег';
        fieldActualAmount.expressions.value = '{!Opportunity.ActualAmount__c}';        
        Component.Apex.InputField fieldCloseDate = new Component.Apex.InputField();
        fieldCloseDate.id = 'CloseDate';
        fieldCloseDate.label = 'Предполагаемая дата отгрузки оборудования';
        fieldCloseDate.expressions.value = '{!Opportunity.CloseDate}';      
        Component.Apex.InputField fieldLeadSource = new Component.Apex.InputField();
        fieldLeadSource.id = 'LeadSource';
        fieldLeadSource.label = 'Источник интереса';
        fieldLeadSource.expressions.value = '{!Opportunity.LeadSource}';  
        Component.Apex.InputField fieldProjectProperties = new Component.Apex.InputField();
        fieldProjectProperties.id = 'ProjectProperties__c';
        fieldProjectProperties.label = 'Характеристики проекта';
        fieldProjectProperties.required = true;
        fieldProjectProperties.expressions.value = '{!Opportunity.ProjectProperties__c}';
        Component.Apex.InputField fieldDescription = new Component.Apex.InputField();
        fieldDescription.id = 'Description';
        fieldDescription.label = 'Описание';
        fieldDescription.expressions.value = '{!Opportunity.Description}';
        Component.Apex.InputField fieldType = new Component.Apex.InputField();
        fieldType.id = 'Type';
        fieldType.label = 'Тип проекта';
        fieldType.required = true;
        fieldType.expressions.value = '{!Opportunity.Type}';
        Component.Apex.InputField fieldProjectRegion = new Component.Apex.InputField();
        fieldProjectRegion.id = 'ProjectRegion__c';
        fieldProjectRegion.label = 'Регион проекта';
        fieldProjectRegion.expressions.value = '{!Opportunity.ProjectRegion__c}';
        Component.Apex.InputField fieldOpportunityLink = new Component.Apex.InputField();
        fieldOpportunityLink.id = 'OpportunityLink__c';
        fieldOpportunityLink.label = 'Связано с';
        fieldOpportunityLink.expressions.value = '{!Opportunity.OpportunityLink__c}';
        Component.Apex.InputField fieldisProblematicProject = new Component.Apex.InputField();
        fieldisProblematicProject.id = 'isProblematicProject__c';
        fieldisProblematicProject.label = 'Проблемный проект';
        fieldisProblematicProject.expressions.value = '{!Opportunity.isProblematicProject__c}';
        Component.Apex.InputCheckbox fieldSendNotification = new Component.Apex.InputCheckbox();
        fieldSendNotification.id = 'fieldSendNotification';
        try{
        	fieldSendNotification.label = 'Отправить электронное уведомление';
        }
        catch(System.VisualforceException e){}  
        fieldSendNotification.expressions.value = '{!sendNotification}';
        Component.Apex.InputField fieldisBillPaid = new Component.Apex.InputField();
        fieldisBillPaid.id = 'isBillPaid__c';
        fieldisBillPaid.label = 'Счёт оплачен';
        fieldisBillPaid.expressions.value = '{!Opportunity.isBillPaid__c}';
        Component.Apex.InputField fieldStartWorkingProducts = new Component.Apex.InputField();
        fieldStartWorkingProducts.id = 'StartWorkingProducts__c';
        fieldStartWorkingProducts.label = 'Дата ввода оборудования в эксплуатацию';
        fieldStartWorkingProducts.expressions.value = '{!Opportunity.StartWorkingProducts__c}';
        Component.Apex.InputField fieldUserTION = new Component.Apex.InputField();
        fieldUserTION.id = 'UserTION__c';
        fieldUserTION.required = true;
        fieldUserTION.label = 'Сотрудник, ответственный за проект';
        fieldUserTION.expressions.value = '{!Opportunity.UserTION__c}';   
        Component.Apex.InputHidden fieldHidden1 = new Component.Apex.InputHidden();
        Component.Apex.InputHidden fieldHidden2 = new Component.Apex.InputHidden();
        Component.Apex.InputHidden fieldHidden3 = new Component.Apex.InputHidden();
        Component.Apex.PageBlockSection dynPageBlockSection2 = new Component.Apex.PageBlockSection();        
        dynPageBlockSection2.columns = 2;
        dynPageBlockSection2.collapsible = false;
        dynPageBlockSection2.showHeader = true;
        dynPageBlockSection2.title = 'Дополнительное описание';
        Component.Apex.InputField fieldAuctionLinkDesign = new Component.Apex.InputField();
        fieldAuctionLinkDesign.id = 'AuctionLinkDesign__c';
        fieldAuctionLinkDesign.label = 'Конкурс на проектирование(госзакупки)';
        fieldAuctionLinkDesign.expressions.value = '{!Opportunity.AuctionLinkDesign__c}';
        Component.Apex.InputField fieldAuctionLinkMounting = new Component.Apex.InputField();
        fieldAuctionLinkMounting.id = 'AuctionLinkMounting__c';
        fieldAuctionLinkMounting.label = 'Конкурс на монтаж(госзакупки)';
        fieldAuctionLinkMounting.expressions.value = '{!Opportunity.AuctionLinkMounting__c}';
        Component.Apex.InputField fieldDesignAuctionNumber = new Component.Apex.InputField();
        fieldDesignAuctionNumber.id = 'DesignAuctionNumber__c';
        fieldDesignAuctionNumber.label = 'Номер конкурса на проектирование';
        fieldDesignAuctionNumber.expressions.value = '{!Opportunity.DesignAuctionNumber__c}';
        Component.Apex.InputField fieldMountingAuctionNumber = new Component.Apex.InputField();
        fieldMountingAuctionNumber.id = 'MountingAuctionNumber__c';
        fieldMountingAuctionNumber.label = 'Номер конкурса на монтаж';
        fieldMountingAuctionNumber.expressions.value = '{!Opportunity.MountingAuctionNumber__c}';
        Component.Apex.InputField fieldAuctionNameDesign = new Component.Apex.InputField();
        fieldAuctionNameDesign.id = 'AuctionNameDesign__c';
        fieldAuctionNameDesign.label = 'Наименование конкурса на проектирование';
        fieldAuctionNameDesign.expressions.value = '{!Opportunity.AuctionNameDesign__c}';
        Component.Apex.InputField fieldAuctionNameMounting = new Component.Apex.InputField();
        fieldAuctionNameMounting.id = 'AuctionNameMounting__c';
        fieldAuctionNameMounting.label = 'Наименование конкурса на монтаж';
        fieldAuctionNameMounting.expressions.value = '{!Opportunity.AuctionNameMounting__c}';
        Component.Apex.InputField fieldAuctionDateDesign = new Component.Apex.InputField();
        fieldAuctionDateDesign.id = 'AuctionDateDesign__c';
        fieldAuctionDateDesign.label = 'Дата конкурса на проектирование';
        fieldAuctionDateDesign.expressions.value = '{!Opportunity.AuctionDateDesign__c}';
        Component.Apex.InputField fieldAuctionDateMounting = new Component.Apex.InputField();
        fieldAuctionDateMounting.id = 'AuctionDateMounting__c';
        fieldAuctionDateMounting.label = 'Дата конкурса на монтаж';
        fieldAuctionDateMounting.expressions.value = '{!Opportunity.AuctionDateMounting__c}';
        Boolean o2 = false;
        Boolean service = false;
        Boolean deal = false;
        RecordType rt = [select id,businessProcessId from RecordType where SobjectType='Opportunity' and developerName='O2ProjectType' Limit 1];
        RecordType rts = [select id,businessProcessId from RecordType where SobjectType='Opportunity' and developerName='ServiceProjectType' Limit 1];  
        RecordType rtd = [select id,businessProcessId from RecordType where SobjectType='Opportunity' and developerName='DealProjectType' Limit 1];        
        Opportunity opprt;
        if(ApexPages.currentPage().getParameters().get('RecordType') == null || ApexPages.currentPage().getParameters().get('RecordType') == ''){
            if(opp.Id == null){
                Profile cuser = [select Name from profile where id = :userinfo.getProfileId() limit 1];
                if(cuser.Name == 'Менеджер по продажам Тион О2'){
                    o2 = true;
                }
                if(cuser.Name == 'Менеджер сервисного отдела'){
                    service = true;
                }
            }
            else{
                opprt = [select RecordTypeId from Opportunity where id = :opp.Id Limit 1];
                if(opprt.RecordTypeId == rt.id) o2 = true;
                if(opprt.RecordTypeId == rts.id) service = true;
                if(opprt.RecordTypeId == rtd.id) deal = true;
            }
        }
        else{
            if(ApexPages.currentPage().getParameters().get('RecordType') == rt.id) o2 = true;
            if(ApexPages.currentPage().getParameters().get('RecordType') == rts.id) service = true;
            if(ApexPages.currentPage().getParameters().get('RecordType') == rtd.id) deal = true;
        }
        dynPageBlockButtons.childComponents.add(dynButtonSave);        
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlock.childComponents.add(dynPageMessages);
        
        if(userinfo.getLastName() != 'Сервисный инженер'){
            /*if(opp.Id == NULL || o2 || userinfo.getLastName() == 'Системный администратор' || userinfo.getLastName() == 'Администрация') dynPageBlockSection1.childComponents.add(fieldUserTION);
            if(!o2 && opp.Id == NULL) dynPageBlockSection1.childComponents.add(fieldActualAmount);
            if(o2) dynPageBlockSection1.childComponents.add(fieldLeadSource);
            dynPageBlockSection1.childComponents.add(fieldName);
            if(!o2 && opp.Id != NULL) dynPageBlockSection1.childComponents.add(fieldActualAmount);
            if(!o2) {
                dynPageBlockSection1.childComponents.add(fieldLeadSource);
            } else {
                dynPageBlockSection1.childComponents.add(fieldisBillPaid);
            }            
            dynPageBlockSection1.childComponents.add(fieldCloseDate);
            if(o2) dynPageBlockSection1.childComponents.add(fieldHidden1);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldDescription);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldProjectProperties);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldHidden1);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldType);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldHidden2);
            if(!o2 && (userinfo.getLastName() == 'Администрация' || userinfo.getLastName() == 'Сервисный инженер')) dynPageBlockSection1.childComponents.add(fieldStartWorkingProducts);
            dynPageBlockSection1.childComponents.add(fieldProjectRegion);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldHidden3);
            if(!o2) dynPageBlockSection1.childComponents.add(fieldisProblematicProject);
            */
            if(!o2 && !service && !deal) {
                if(opp.Id == NULL) {
                    dynPageBlockSection1.childComponents.add(fieldUserTION);
                    dynPageBlockSection1.childComponents.add(fieldActualAmount);
                    dynPageBlockSection1.childComponents.add(fieldName);
                    dynPageBlockSection1.childComponents.add(fieldLeadSource);
                    dynPageBlockSection1.childComponents.add(fieldCloseDate);
                    dynPageBlockSection1.childComponents.add(fieldDescription);
                    dynPageBlockSection1.childComponents.add(fieldProjectProperties);
                    dynPageBlockSection1.childComponents.add(fieldHidden1);
                    dynPageBlockSection1.childComponents.add(fieldType);
                    if (userinfo.getLastName() == 'Администрация' || userinfo.getLastName() == 'Сервисный инженер') {
                        dynPageBlockSection1.childComponents.add(fieldStartWorkingProducts);    
                    } else {
                        dynPageBlockSection1.childComponents.add(fieldHidden2);
                    }
                    dynPageBlockSection1.childComponents.add(fieldProjectRegion);
                    dynPageBlockSection1.childComponents.add(fieldHidden3);
                    dynPageBlockSection1.childComponents.add(fieldisProblematicProject);
                    dynPageBlockSection1.childComponents.add(fieldSendNotification);
                } else {
                    dynPageBlockSection1.childComponents.add(fieldName);
                    dynPageBlockSection1.childComponents.add(fieldActualAmount);
                    dynPageBlockSection1.childComponents.add(fieldCloseDate);
                    dynPageBlockSection1.childComponents.add(fieldLeadSource);
                    dynPageBlockSection1.childComponents.add(fieldProjectProperties);
                    dynPageBlockSection1.childComponents.add(fieldDescription);
                    dynPageBlockSection1.childComponents.add(fieldType);
                    dynPageBlockSection1.childComponents.add(fieldHidden1);
                    dynPageBlockSection1.childComponents.add(fieldProjectRegion);
                    if (userinfo.getLastName() == 'Администрация' || userinfo.getLastName() == 'Сервисный инженер') {
                        dynPageBlockSection1.childComponents.add(fieldStartWorkingProducts);    
                    } else {
                        dynPageBlockSection1.childComponents.add(fieldHidden2);
                    }
                    dynPageBlockSection1.childComponents.add(fieldisProblematicProject);
                }
            } 
            else if(service == true) {
                dynPageBlockSection1.childComponents.add(fieldUserTION);
                dynPageBlockSection1.childComponents.add(fieldLeadSource);
                dynPageBlockSection1.childComponents.add(fieldName);
                dynPageBlockSection1.childComponents.add(fieldisBillPaid);
                dynPageBlockSection1.childComponents.add(fieldCloseDate);
                dynPageBlockSection1.childComponents.add(fieldHidden1);
                dynPageBlockSection1.childComponents.add(fieldProjectRegion);
            }
            else if(deal == true) {                
        		fieldProjectRegion.required = true;
                dynPageBlockSection1.childComponents.add(fieldUserTION);
                dynPageBlockSection1.childComponents.add(fieldLeadSource);
                dynPageBlockSection1.childComponents.add(fieldName);
                dynPageBlockSection1.childComponents.add(fieldisBillPaid);
                dynPageBlockSection1.childComponents.add(fieldCloseDate);                
                dynPageBlockSection1.childComponents.add(fieldActualAmount);
                dynPageBlockSection1.childComponents.add(fieldProjectRegion);
                dynPageBlockSection1.childComponents.add(fieldOpportunityLink);
            }
            else {
                dynPageBlockSection1.childComponents.add(fieldUserTION);
                dynPageBlockSection1.childComponents.add(fieldLeadSource);
                dynPageBlockSection1.childComponents.add(fieldName);
                dynPageBlockSection1.childComponents.add(fieldisBillPaid);
                dynPageBlockSection1.childComponents.add(fieldCloseDate);
                dynPageBlockSection1.childComponents.add(fieldHidden1);
                dynPageBlockSection1.childComponents.add(fieldProjectRegion);
            }
            
        }
        else{
            dynPageBlockSection1.childComponents.add(fieldName);
            dynPageBlockSection1.childComponents.add(fieldStartWorkingProducts);            
            dynPageBlockSection1.childComponents.add(fieldProjectRegion);
            dynPageBlockSection1.childComponents.add(fieldCloseDate);
        }
        dynPageBlock.childComponents.add(dynPageBlockSection1);
        dynPageBlockSection2.childComponents.add(fieldAuctionLinkDesign);
        dynPageBlockSection2.childComponents.add(fieldAuctionLinkMounting);
        dynPageBlockSection2.childComponents.add(fieldDesignAuctionNumber);
        dynPageBlockSection2.childComponents.add(fieldMountingAuctionNumber);
        dynPageBlockSection2.childComponents.add(fieldAuctionNameDesign);
        dynPageBlockSection2.childComponents.add(fieldAuctionNameMounting);
        dynPageBlockSection2.childComponents.add(fieldAuctionDateDesign);
        dynPageBlockSection2.childComponents.add(fieldAuctionDateMounting);
        if(!o2 && !service && !deal && userinfo.getLastName() != 'Сервисный инженер') dynPageBlock.childComponents.add(dynPageBlockSection2);
        return dynPageBlock;
    }

    public Component.Apex.PageBlock getShowNextStage() {
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlock';
        dynPageBlock.mode = 'nextStage';
        dynPageBlock.title = 'Перейти к следующему этапу';
        Component.Apex.PageBlockButtons dynPageBlockButtons = new Component.Apex.PageBlockButtons();
        Component.Apex.commandButton dynButtonSave = new Component.Apex.commandButton();
        dynButtonSave.expressions.action = '{!saveNextStage}';
        dynButtonSave.value = 'Сохранить';
        Component.Apex.commandButton dynButtonCancel = new Component.Apex.commandButton();
        dynButtonCancel.expressions.action = '{!cancel}';
        dynButtonCancel.value = 'Отмена';
        dynButtonCancel.immediate = true;
        Component.Apex.PageBlockSection dynPageBlockSection = new Component.Apex.PageBlockSection();  
        Component.Apex.outputText dynCurStage = new Component.Apex.outputText();
        dynCurStage.value = 'Текущий этап: ' + opp_public.stageName;
        BusinessProcess bp = [SELECT id FROM BusinessProcess WHERE id in (SELECT BusinessProcessId FROM RecordType WHERE Id = :opp_public.RecordTypeId) limit 1];
        StageByBusinessProcess sbbp = new StageByBusinessProcess();
        String nextStage = sbbp.getNextStage(bp, opp_public.stageName);        
        Component.Apex.outputText dynNextStage = new Component.Apex.outputText();
        dynNextStage.value = 'Следующий этап: ' + nextStage;        
        Component.Apex.PageMessages dynPageMessages = new Component.Apex.PageMessages();
        Component.Apex.PageMessage dynPageMessage = new Component.Apex.PageMessage();
        dynPageMessage.severity = 'warning';
        Boolean may = true;
        Profile profile = [Select Name from Profile where Id = :UserInfo.getProfileId()];
        User rop = [SELECT Id, ProfileId FROM user Where LastName = 'Администрация'];
        if(userinfo.getLastName() == 'Администрация' && opp_public.OwnerId == rop.Id){
            if(opp_public.stageName == 'Государственная экспертиза проекта') dynPageMessage.summary = 'Вы не можете изменить этап проекта. Пожалуйста, добавьте пользователя в группу проекта с ролью "Региональный менеджер по продажам"';
            else if(opp_public.stageName == 'Шеф-монтаж') dynPageMessage.summary = 'Вы не можете изменить этап проекта. Пожалуйста, добавьте пользователя в группу проекта с ролью "Сервисный инженер"';
            else dynPageMessage.summary = 'Вы не можете изменить текущий этап';
            may = false;
        }
        else if(opp_public.OwnerId == rop.Id){
            dynPageMessage.summary = 'Вы не можете изменить текущий этап. Проект находится на утверждении.';
            may = false; 
        }
        else if( opp_public.OwnerId != userinfo.getUserId()){
                 dynPageMessage.summary = 'Вы не можете изменить текущий этап';
                 may = false; 
             }
        else if(opp_public.stageName == nextStage){
            dynPageMessage.summary = 'Невозможно перейти на следующий этап';
            may = false;
        }
        else{
            String error = checkStage(opp_public.stageName, nextStage, false, bp);
            if(error != '') {
                dynPageMessage.summary = error;
                may = false;   
            }
        }
        if(may) dynPageBlockButtons.childComponents.add(dynButtonSave);        
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlock.childComponents.add(dynPageMessages);
        if(!may)dynPageBlock.childComponents.add(dynPageMessage);
        dynPageBlockSection.childComponents.add(dynCurStage);
        if(may)dynPageBlockSection.childComponents.add(dynNextStage);
        dynPageBlock.childComponents.add(dynPageBlockSection);        
        return dynPageBlock;
    }

    public class StageException extends Exception {}    
   
    public PageReference saveNextStage() {
        BusinessProcess bp = [SELECT id,Name FROM BusinessProcess WHERE id in (SELECT BusinessProcessId FROM RecordType WHERE Id = :opp_public.RecordTypeId) limit 1];
        StageByBusinessProcess sbbp = new StageByBusinessProcess();
        String nextStage = sbbp.getNextStage(bp, opp_public.stageName);        
        PageReference redirectPage;
        try {    
            String error = checkStage(opp_public.stageName, nextStage, true, bp);
            if(error != '') throw new StageException(error);
            Opportunity opp_stage = opp;
            if(opp_stage.stageName == 'Государственная экспертиза проекта'){
                if(opp_stage.HiddenStageNameBeforeApprovalStarts__c != opp_stage.stageName){  
                    OpportunityGroup__c og = [SELECT userTION__c FROM OpportunityGroup__c WHERE UserRole__c = 'Руководитель отдела продаж' limit 1];
                    User__c uc = [SELECT user__c FROM user__c WHERE ID = :og.UserTION__c];
                    opp_stage.UserTION__c = og.UserTION__c;
                    opp_stage.ownerId = uc.User__c;                  
                    opp_stage.HiddenStageNameBeforeApprovalStarts__c = opp_stage.stageName;
                    opp_stage.needStateReview__c = true;
                    update opp_stage;
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(opp_stage.id);
                    Approval.ProcessResult result = Approval.process(req1);
                }
                else{
                    throw new StageException('Невозможно сменить этап.');
                }
            }
            else if(opp_stage.stageName == 'Закупка оборудования' && bp.name == 'Тион, прямая продажа'){
                if(opp_stage.HiddenStageNameBeforeApprovalStarts__c != opp_stage.stageName){  
                    opp_stage.HiddenStageNameBeforeApprovalStarts__c = opp_stage.stageName;
                    update opp_stage;
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(opp_stage.id);
                    Approval.ProcessResult result = Approval.process(req1);
                }
                else{
                    throw new StageException('Невозможно сменить этап.');
                }
            }
            else{
                
                opp_stage.stageName = nextStage;
            }
            update opp_stage;
            redirectPage = stdController.view();            
        } catch(StageException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }

    private String checkStage(String stage, String nextStage, Boolean isSave, BusinessProcess bp){
        bp = [Select id, Name From BusinessProcess WHERE id = :bp.id limit 1];
        Opportunity project = [SELECT id, stageName, ProjectRegion__c, ActualAmount__c, HasOpportunityLineItem, ownerID FROM Opportunity WHERE id = :opp.id];
        String error = '';
        if(project.ownerID != userinfo.getUserID()) return 'Вы не можете изменить этап.';
        if(stage.toUpperCase().indexOf('ЗАКРЫТО', 0) >= 0){
             return 'Вы не можете изменить этап. Проект закрыт.';
        }
        if(stage == 'Отслеживание конкурса на проектирование') {          
            if(userinfo.getLastName() == 'Проектировщик') return 'Вы не имеете права изменять поля и этап проекта. Пожалуйста, добавьте в группу, работающую с проектом ответственного за проект сотрудника с ролью менеджер по продажам';
            List<ProjectMember__c> projectMembers = [select ProjectRoles__c, AccountId__c from ProjectMember__c where OpportunityId__c = :opp.id];
            Boolean isDesignerAdded = false;
            for(Integer j=0; j< projectMembers.size(); j++){
                if(projectMembers[j].ProjectRoles__c.containsIgnoreCase('Генпроектировщик') == true) {
                    isDesignerAdded = true;
                    if(isSave){
                        Account account = [select ShippingRegion__c from Account where Id=:projectMembers[j].AccountId__c limit 1];
                        project.ProjectRegion__c = account.ShippingRegion__c;
                        update project;
                    }
                    break;
                }
            }
            if(!isDesignerAdded) error = 'Прежде чем перейти к следующему этапу необходимо добавить Генпроектировщика к проекту';
        }
        if(stage == 'Переговоры с проектировщиком') {
            List<OpportunityGroup__c> OG = [SELECT id FROM OpportunityGroup__c WHERE UserRole__c = 'Руководитель отдела продаж' OR UserRole__c = 'Проектировщик'];
            if(OG.size() < 2) error = 'Для перехода на следующий этап необходимо добавить роли "Руководитель отдела продаж" и "Проектировщик"';
        }
        if(stage == 'Подбор оборудования') {
            if(project.HasOpportunityLineItem == false) error = 'Прежде чем перейти к следующему этапу необходимо добавить продукты к проекту';
        }
        if(stage == 'КП Проектировщику' || stage == 'КП генподрядчику') {
            List<Quote> projectQuotes = [Select Id from Quote where OpportunityId= :opp.Id];
            if(projectQuotes.size() == 0) error = 'Прежде чем перейти к следующему этапу необходимо добавить к проекту смету, на основе добавленных к проекту продуктов';
        }
        if(stage == 'Конкурс на монтаж завершен') {
            List<ProjectMember__c> projectMembers = [select ProjectRoles__c, AccountId__c from ProjectMember__c where OpportunityId__c = :opp.id];
            Boolean isInstallerAdded = false;
            for(Integer j=0; j< projectMembers.size(); j++){
                if(projectMembers[j].ProjectRoles__c.containsIgnoreCase('Генподрядчик') == true) {
                    isInstallerAdded = true;
                    if(isSave){
                        Account account = [select ShippingRegion__c from Account where Id=:projectMembers[j].AccountId__c limit 1];
                        project.ProjectRegion__c = account.ShippingRegion__c;
                        update project;
                    }
                    break;
                }
            }
            if(!isInstallerAdded) error = 'Прежде чем перейти к следующему этапу необходимо добавить Генподрядчика к проекту';
        }        
        if(stage == 'Заключение договора с генподрядчиком'){
            if([SELECT id FROM Contract WHERE ProjectName__c = :opp.id].isEmpty()) error = 'Необходимо добавить договор к проекту';
        }
        if(stage == 'Гарантийная эксплуатация' || stage == 'Шеф-монтаж') { 
            List<Case> cases = NULL;
            LIST<act__c> exists = [SELECT Id FROM act__c WHERE Opportunity__c = :opp.Id];
            if(exists.isEmpty()) error = 'Необходимо добавить акт шеф-монтажа к проекту.';  
            
            Opportunity opp_date = [SELECT StartWorkingProducts__c FROM Opportunity WHERE id = :opp.Id];
            if(opp_date.StartWorkingProducts__c == NULL) error = 'Укажите дату ввода оборудования в эксплуатацию в проекте!';
            else if(stage == 'Гарантийная эксплуатация') {
                cases = [SELECT id FROM Case WHERE Opportunity__c = :opp.Id AND isClosed = false AND type = 'Гарантийная эксплуатация'];
                if(!cases.isEmpty()) error = 'Прежде чем перейти к следующему этапу закройте все обращения с типом "Гарантийная эксплуатация"';
            }            
            cases = [SELECT id FROM Case WHERE Opportunity__c = :opp.Id AND isClosed = false AND type = 'Шеф-монтаж'];
            if(!cases.isEmpty()) error = 'Прежде чем перейти к следующему этапу закройте все обращения с типом "Шеф-монтаж"';
        }
        if(stage == 'Отгрузка оборудования') {
            if(project.ActualAmount__c == null || project.ActualAmount__c <= 0) error = 'Прежде чем перейти к следующему этапу необходимо указать фактическую сумму прихода денег по проекту';
        }
        if(stage == 'Холодный звонок'){
            List<ProjectMember__c> ProjectMember = [SELECT AccountId__c FROM ProjectMember__c WHERE OpportunityId__c = :opp.Id];
            if(ProjectMember.size() == 0 && bp.name == 'Тион, продажа О2 дилерам') error = 'Перед переходом к этапу “Переговоры” к возможности обязательно должна быть добавлена организация с ролью “Дилер”';
        	if(ProjectMember.size() == 0 && bp.name == 'Тион, продажа услуг сервиса') error = 'Перед переходом к этапу “Переговоры” к возможности обязательно должна быть добавлена организация';
        }
        if(stage == 'Переговоры (обсуждение условий)') {
            if(project.HasOpportunityLineItem == false) error = 'Прежде чем перейти к следующему этапу необходимо добавить продукты к проекту';
        }
        if(nextStage == 'Шеф-монтаж' && userinfo.getLastName() == 'Администрация') error = '"Вы не можете изменять этап проекта. Вместо этого, пожалуйста добавьте в группу проекта сервисного инженера, ответственного за проект';
        return error;
    }
}