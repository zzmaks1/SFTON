public class OpportunityGroupController{
    public Opportunity opp;
    public OpportunityGroup__c ogc;
    public ID userDel{get; set;}
    public ID userSetOwner{get; set;}
    public Boolean sendNotification{get; set;}
    private final ApexPages.StandardController stdController;
    public OpportunityGroupController(ApexPages.StandardController controller) {
        stdController = controller;
        ogc = (OpportunityGroup__c)controller.getRecord(); 
        opp = [SELECT ID, StageName, OwnerID FROM Opportunity WHERE ID = :ogc.Opportunity__c];
    }
    public Boolean getisAdministration(){
        return userinfo.getLastName() == 'Администрация' || userinfo.getLastName() == 'Системный администратор';
    }
    public Component.Apex.PageBlock getDynamicForm() {
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlock';
        dynPageBlock.mode = 'addUser';
        dynPageBlock.title = 'Добавить пользователя в группу';        
        Component.Apex.PageBlockButtons dynPageBlockButtons = new Component.Apex.PageBlockButtons();
        Component.Apex.commandButton dynButtonSave = new Component.Apex.commandButton();
        dynButtonSave.expressions.action = '{!saveForm}';
        dynButtonSave.value = 'Сохранить';
        Component.Apex.commandButton dynButtonCancel = new Component.Apex.commandButton();
        dynButtonCancel.expressions.action = '{!cancel}';
        dynButtonCancel.value = 'Отмена';
        dynButtonCancel.immediate = true;        
        Component.Apex.PageBlockSection dynPageBlockSection = new Component.Apex.PageBlockSection();  
        dynPageBlockSection.columns = 1;
        Component.Apex.InputField fieldUser = new Component.Apex.InputField();
        fieldUser.id = 'UserId';
        fieldUser.label = 'Пользователь';
        fieldUser.expressions.value = '{!OpportunityGroup__c.UserTION__c}';
        Component.Apex.InputField fieldRole = new Component.Apex.InputField();
        fieldRole.id = 'UserRole';
        fieldRole.label = 'Роль';
        fieldRole.expressions.value = '{!OpportunityGroup__c.UserRole__c}';
        Component.Apex.InputCheckbox fieldSendNotification = new Component.Apex.InputCheckbox();
        fieldSendNotification.id = 'fieldSendNotification';
        try{
        	fieldSendNotification.label = 'Отправить электронное уведомление';
        }
        catch(System.VisualforceException e){}   
        fieldSendNotification.expressions.value = '{!sendNotification}';
        Component.Apex.PageMessages dynPageMessages = new Component.Apex.PageMessages();
        Component.Apex.PageMessage dynPageMessage = new Component.Apex.PageMessage();
        dynPageMessage.severity = 'warning';
        dynPageBlockButtons.childComponents.add(dynButtonSave);        
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlock.childComponents.add(dynPageMessages);
        dynPageBlockSection.childComponents.add(fieldUser);
        dynPageBlockSection.childComponents.add(fieldRole);
        dynPageBlockSection.childComponents.add(fieldSendNotification);
        dynPageBlock.childComponents.add(dynPageBlockSection);
        return dynPageBlock;    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<OpportunityGroup__c> ogcc = [SELECT ID, UserTION__c, UserRole__c FROM OpportunityGroup__c WHERE Opportunity__c = :ogc.Opportunity__c];
        for (OpportunityGroup__c o: ogcc) {
            User__c ou = [SELECT ID, Name FROM User__c WHERE id = :o.UserTION__c];
            options.add(new SelectOption(o.ID,ou.Name + ' : ' + o.UserRole__c));   
        }
        return options;
    }
    public Component.Apex.PageBlock getDeleteForm() {        
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlockdel';
        dynPageBlock.mode = 'DelUser';
        dynPageBlock.title = 'Удалить пользователя из группы';        
        Component.Apex.PageBlockButtons dynPageBlockButtons = new Component.Apex.PageBlockButtons();
        Component.Apex.commandButton dynButtonSave = new Component.Apex.commandButton();
        dynButtonSave.expressions.action = '{!delForm}';
        dynButtonSave.value = 'Удалить';
        Component.Apex.commandButton dynButtonCancel = new Component.Apex.commandButton();
        dynButtonCancel.expressions.action = '{!cancel}';
        dynButtonCancel.value = 'Отмена';
        dynButtonCancel.immediate = true;        
        Component.Apex.PageBlockSection dynPageBlockSection = new Component.Apex.PageBlockSection();          
        Component.Apex.SelectList selectList = new Component.Apex.SelectList();
        selectList.expressions.value = '{!userDel}';
        try{
            selectList.label = 'Пользователь';
        }
        catch(System.VisualforceException e){}        
        Component.Apex.selectOptions selectOptions = new Component.Apex.selectOptions();
        selectOptions.expressions.value = '{!Items}';
        dynPageBlockButtons.childComponents.add(dynButtonSave);        
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlockSection.childComponents.add(selectList);
        selectList.childComponents.add(selectOptions);
        dynPageBlock.childComponents.add(dynPageBlockSection);        
        return dynPageBlock;
    }
    
    public Component.Apex.PageBlock getSetOwnerForm() {        
        Component.Apex.PageBlock dynPageBlock = new Component.Apex.PageBlock();
        dynPageBlock.id = 'PageBlockOwnerSet';
        dynPageBlock.mode = 'OwnerSetUser';
        dynPageBlock.title = 'Установить ответственным';        
        Component.Apex.PageBlockButtons dynPageBlockButtons = new Component.Apex.PageBlockButtons();
        Component.Apex.commandButton dynButtonSave = new Component.Apex.commandButton();
        dynButtonSave.expressions.action = '{!setOwnerForm}';
        dynButtonSave.value = 'Установить';
        Component.Apex.commandButton dynButtonCancel = new Component.Apex.commandButton();
        dynButtonCancel.expressions.action = '{!cancel}';
        dynButtonCancel.value = 'Отмена';
        dynButtonCancel.immediate = true;        
        Component.Apex.PageBlockSection dynPageBlockSection = new Component.Apex.PageBlockSection();          
        Component.Apex.SelectList selectList = new Component.Apex.SelectList();
        selectList.expressions.value = '{!userSetOwner}';
        try{
            selectList.label = 'Пользователь';
        }
        catch(System.VisualforceException e){}        
        Component.Apex.selectOptions selectOptions = new Component.Apex.selectOptions();
        selectOptions.expressions.value = '{!Items}';
        dynPageBlockButtons.childComponents.add(dynButtonSave);        
        dynPageBlockButtons.childComponents.add(dynButtonCancel);
        dynPageBlock.childComponents.add(dynPageBlockButtons);
        dynPageBlockSection.childComponents.add(selectList);
        selectList.childComponents.add(selectOptions);
        dynPageBlock.childComponents.add(dynPageBlockSection);        
        return dynPageBlock;
    }
    public class SException extends Exception {}
    public PageReference saveForm() {
        PageReference redirectPage;
        try {    
            if(ogc.UserTION__c == NULL){
                throw new SException('Не выбран пользователь.');
            }                
            User__c userc = [SELECT user__c, Email__c FROM User__c WHERE Id = :ogc.UserTION__c];            
            User user = [Select Id, ProfileId, LastName FROM User WHERE id = :userc.user__c];            
            if(userinfo.getLastName() == 'Менеджер по продажам' || userinfo.getLastName() == 'Сервисный инженер'){
                throw new SException('Вы не можете добавлять пользователей в группу.');
            }
            /*else if(userinfo.getLastName() == 'Администрация' && ogc.UserRole__c != 'Региональный менеджер по продажам' && ogc.UserRole__c != 'Сервисный инженер'){
                throw new SException('Вы не можете добавить этого пользователя в группу.');
            }*/
            try{
                insert ogc;    
                redirectPage = new ApexPages.StandardController([SELECT ID FROM Opportunity WHERE Id = :opp.Id]).view();
                redirectPage.setRedirect(true);
                if(ogc.UserRole__c == 'Сервисный инженер' || ogc.UserRole__c == 'Менеджер по продажам'){
                    opp.UserTION__c = userc.Id;
                    opp.ownerId = user.Id;
                    update opp;
                }      
                if(sendNotification == true){
                    if(userc.Email__c != NULL && userc.Email__c != ''){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {userc.Email__c});                    
                        mail.setSubject('Вы были добавлены в группу проекта');
                        String htmlBody = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
                        mail.setHtmlBody(htmlBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }
                }
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        } catch(SException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }
    
    public PageReference delForm() {        
        PageReference redirectPage;
        try {    
            if(userDel == null) throw new SException('Необходимо выбрать пользователя!');
            if(userinfo.getLastName() != 'Администрация' && userinfo.getLastName() != 'Системный администратор') throw new SException('Вам запрещено удалять пользователей из группы!');
            try{                    
                List<OpportunityGroup__c> otmUser = [SELECT id FROM OpportunityGroup__c WHERE opportunity__c = :opp.Id AND ID = :userDel];
                if(!otmUser.isEmpty()) delete otmUser[0];
                redirectPage = stdController.view(); 
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        } catch(SException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }
    
    public PageReference setOwnerForm() {        
        PageReference redirectPage;
        try {    
            if(userSetOwner == null) throw new SException('Необходимо выбрать пользователя!');
            if(userinfo.getLastName() != 'Администрация' && userinfo.getLastName() != 'Системный администратор') throw new SException('Вам запрещено устанавливать ответственного!');
            try{                    
                List<OpportunityGroup__c> otmUser = [SELECT id, UserTION__c FROM OpportunityGroup__c WHERE opportunity__c = :opp.Id AND ID = :userSetOwner];
                if(!otmUser.isEmpty()){
                    opp.UserTION__c = otmUser[0].UserTION__c;
                    update opp;
                }
                redirectPage = new ApexPages.StandardController([SELECT ID FROM Opportunity WHERE Id = :opp.Id]).view();
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        } catch(SException e) {
            ApexPages.addMessages(e);
            return null;
        }
        return redirectPage;
    }
}