public class ProductionOrderExtentionController{
    public ProductionOrder__c PO;
    ID Quote;
    private final ApexPages.StandardController stdController;
    Map <Integer,String> monthNames = new Map<Integer,String> {1 => 'января',2 => 'февраля',3 => 'марта',
        4 => 'апреля', 5 => 'мая', 6 => 'июня', 7 => 'июля', 8 => 'августа', 9 => 'сентября', 10 => 'октября',
        11 => 'ноября', 12 => 'декабря'};

    public ProductionOrderExtentionController(ApexPages.StandardController controller) {
        stdController = controller;
        PO = (ProductionOrder__c)controller.getRecord();
    }
    
    public PageReference save() {    
        if (PO.id == NULL) PO.Quote__c = Quote;
        PageReference redirectPage;
        try { 
            redirectPage = stdController.save();               
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }
    
    public List<SelectOption> getQuoteItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Quote> qList = [SELECT ID, Name FROM Quote WHERE OpportunityId = :PO.Opportunity__c];
        for(Quote q:qList){
            options.add(new SelectOption(q.ID,q.Name));    
        }
        return options;
    }
    
    public ID getQuote() {
        return Quote;
    }
    
    public void setQuote(ID Quote) {
        this.Quote = Quote;
    }
    
    public Component.Apex.PageBlock getDynamicForm() {
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlock';
        dynPageBlock.mode = 'edit';
        dynPageBlock.title = 'Редактировать производственный заказ';
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
        Component.Apex.InputField fieldOpp = new Component.Apex.InputField();
        fieldOpp.id = 'Opp';
        fieldOpp.label = 'Проект';
        fieldOpp.expressions.value = '{!ProductionOrder__c.Opportunity__c}';
        Component.Apex.SelectOptions fieldQuoteOption = new Component.Apex.SelectOptions();
        fieldQuoteOption.id = 'QOP';
        fieldQuoteOption.expressions.value = '{!QuoteItems}';            
        Component.Apex.actionSupport actionOpp = new Component.Apex.actionSupport();
        actionOpp.event = 'onchange';        
        fieldOpp.childComponents.add(actionOpp);
        
        if (PO.id == NULL){
            Component.Apex.SelectList fieldQuote = new Component.Apex.SelectList();
            fieldQuote.id = 'Quote';
            try{fieldQuote.label = 'Смета';}catch(System.VisualforceException e){}
            fieldQuote.size = 1;
            fieldQuote.expressions.value = '{!Quote}';
            fieldQuote.childComponents.add(fieldQuoteOption);  
            dynPageBlockSection1.childComponents.add(fieldQuote);    
            dynPageBlockSection1.childComponents.add(fieldOpp);   
        }
        
        
        Component.Apex.InputField fieldOwner = new Component.Apex.InputField();
        fieldOwner.id = 'Owner';
        fieldOwner.required = true;
        fieldOwner.label = 'Ответственный за производственный заказ';
        fieldOwner.expressions.value = '{!ProductionOrder__c.Owner__c}';
        
        
        Component.Apex.InputField fieldUserTION = new Component.Apex.InputField();
        fieldUserTION.id = 'UserTION';
        fieldUserTION.required = true;
        fieldUserTION.label = 'Сотрудник, ответственный за производственный заказ';
        fieldUserTION.expressions.value = '{!ProductionOrder__c.UserTION__c}';
        
        
        Component.Apex.InputField fieldSubmissionDate = new Component.Apex.InputField();
        fieldSubmissionDate.id = 'SubmissionDate';
        fieldSubmissionDate.required = true;
        fieldSubmissionDate.label = 'Дата представления утвержденной заявки';
        fieldSubmissionDate.expressions.value = '{!ProductionOrder__c.SubmissionDate__c}';
        
        
        Component.Apex.InputField fieldUID_1C = new Component.Apex.InputField();
        fieldUID_1C.id = 'UID_1C';
        fieldUID_1C.label = 'Номер заказа поставщику в 1С';
        fieldUID_1C.expressions.value = '{!ProductionOrder__c.UID_1C__c}';
        
        
        Component.Apex.InputField fieldAccount = new Component.Apex.InputField();
        fieldAccount.id = 'Account';
        fieldAccount.required = true;
        fieldAccount.label = 'Контрагент';
        fieldAccount.expressions.value = '{!ProductionOrder__c.Account__c}';
        
        
        Component.Apex.InputField fieldAccountContacts = new Component.Apex.InputField();
        fieldAccountContacts.id = 'AccountContacts';
        fieldAccountContacts.required = true;
        fieldAccountContacts.label = 'Контакты контрагента (ФИО, адрес, тел.)';
        fieldAccountContacts.expressions.value = '{!ProductionOrder__c.AccountContacts__c}';
        
        
        Component.Apex.InputField fieldAddress = new Component.Apex.InputField();
        fieldAddress.id = 'Address';
        fieldAddress.required = true;
        fieldAddress.label = 'Адрес объекта';
        fieldAddress.expressions.value = '{!ProductionOrder__c.Address__c}';
        
        
        Component.Apex.InputField fieldDeliveryPay = new Component.Apex.InputField();
        fieldDeliveryPay.id = 'DeliveryPay';
        fieldDeliveryPay.required = true;
        fieldDeliveryPay.label = 'Оплата доставки';
        fieldDeliveryPay.expressions.value = '{!ProductionOrder__c.DeliveryPay__c}';
        
        
        Component.Apex.InputField fieldEquipmentDate = new Component.Apex.InputField();
        fieldEquipmentDate.id = 'EquipmentDate';
        fieldEquipmentDate.label = 'Дата производства оборудования';
        fieldEquipmentDate.expressions.value = '{!ProductionOrder__c.EquipmentDate__c}';
        
        
        Component.Apex.InputField fieldShipmentDate = new Component.Apex.InputField();
        fieldShipmentDate.id = 'ShipmentDate';
        fieldShipmentDate.label = 'Дата отгрузки оборудования на объект';
        fieldShipmentDate.expressions.value = '{!ProductionOrder__c.ShipmentDate__c}';
        
          
        dynPageBlockSection1.childComponents.add(fieldOwner);   
        dynPageBlockSection1.childComponents.add(fieldAccount);   
        dynPageBlockSection1.childComponents.add(fieldUserTION);   
        dynPageBlockSection1.childComponents.add(fieldAccountContacts);   
        dynPageBlockSection1.childComponents.add(fieldSubmissionDate);   
        dynPageBlockSection1.childComponents.add(fieldAddress);   
        dynPageBlockSection1.childComponents.add(fieldUID_1C);   
        dynPageBlockSection1.childComponents.add(fieldDeliveryPay);   
        dynPageBlockSection1.childComponents.add(fieldEquipmentDate);   
        dynPageBlockSection1.childComponents.add(fieldShipmentDate); 
        
        
        
        List<Quote> qList = [SELECT ID, Name FROM Quote WHERE OpportunityId = :PO.Opportunity__c];
        if(!qList.isEmpty()) dynPageBlockButtons.childComponents.add(dynButtonSave);   
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlock.childComponents.add(dynPageMessages);    
        dynPageBlock.childComponents.add(dynPageBlockSection1);
        return dynPageBlock;
    }
    
    public List<ProductionOrderItemLine__c> getProducts() {
        return [SELECT NumberPP__c, SideService__c, ProductionOrder__c, ProductName__c, SpecialNotes__c, LimitSizeShipping__c, CustomBodyColor__c, CustomMounting__c, 
                        CustomPressure__c, CustomConnection__c, CustomSize__c, CustomPerformance__c, SeparateControl__c, medprom__c, SectionComposition__c, CountItems__c
                FROM ProductionOrderItemLine__c WHERE ProductionOrder__c = :PO.Id];   
    }
    
    public string getSubmissionDate() {
        if(PO.SubmissionDate__c == NULL) return NULL;
        String day = PO.SubmissionDate__c.day().format();
        if(day.length()==1) {
            day = '0'+day;
        }
        String sDate = '«'+ day +'» '+monthNames.get(PO.SubmissionDate__c.month())+' '+PO.SubmissionDate__c.year()+' г.';
        return sDate;
    }
    
    public string getEquipmentDate() {
        if(PO.EquipmentDate__c == NULL) return NULL;
        String day = PO.EquipmentDate__c.day().format();
        if(day.length()==1) {
            day = '0'+day;
        }
        String sDate = '«'+ day +'» '+monthNames.get(PO.EquipmentDate__c.month())+' '+PO.EquipmentDate__c.year()+' г.';
        return sDate;
    }
    
    public string getShipmentDate() {
        if(PO.ShipmentDate__c == NULL) return NULL;
        String day = PO.ShipmentDate__c.day().format();
        if(day.length()==1) {
            day = '0'+day;
        }
        String sDate = '«'+ day +'» '+monthNames.get(PO.ShipmentDate__c.month())+' '+PO.ShipmentDate__c.year()+' г.';
        return sDate;
    }
    
    
}