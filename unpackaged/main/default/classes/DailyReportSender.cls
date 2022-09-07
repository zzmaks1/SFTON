global class DailyReportSender{
    
    public static final Integer TYPE_TASK = 0;
    public static final Integer TYPE_EVENT = 1;
    public static final Integer TYPE_ASSET = 2;
    public static final Integer TYPE_SEND = 3;
    
    private string html = '';
    public integer type_subject {set;get;}
    public integer counter {set;get;}
    public integer step {set;get;}
    public integer total_steps {set;get;}
    public ID UserID = NULL;
        
    Set<Date> tmpDates = new Set<Date>();
    
    public boolean sendWindow {set;get;}
    public boolean finished {set;get;}

    public DailyReportSender () {
        ID selectedUserId = NULL;
        this.counter = 0;
        this.sendWindow = true;
        this.finished = false;
        this.type_subject = NULL;
        this.step = null;
        this.total_steps = null;
    }

    public boolean setUserID(ID uID){
        UserID = uID;    
        return true;
    }
    
    public String selectedUserId {set;get;}

    public List<SelectOption> tionUsers {
        get {
            selectedUserId = NULL;
            List<User__c> tionUsers = [select Id, Name, User__c from User__c];
            List<SelectOption> userOptionList = new List<SelectOption> ();
            userOptionList.add(new SelectOption( '' ,'---Выбрать---'));
            for(User__c u : tionUsers ){
                if(u.User__c == Userinfo.getUserID() || Userinfo.getLastName() == 'Системный администратор') userOptionList.add(new SelectOption(u.Id , u.Name));
            }
            return userOptionList;
        }
        set;
    }
    
    public PageReference sendReport() {        
        if(selectedUserId != NULL){
            UserID = selectedUserId;   
        }
        if(UserID == NULL) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Пожалуйста, выберите свою фамилию в списке, для того чтобы отправить отчет'));
            return null;
        }
        this.sendWindow = false;
        return this.processCommand();
    }
    
    public PageReference sendedReport(){        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Отчет отправлен. Теперь данное окно можно закрыть'));
        return NULL;
    }
    
    public PageReference processCommand() {
        try {
            this.startSend();
            if(this.finished == true){
                return sendedReport();
            }
        } catch (System.QueryException e) {
            this.finished = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'В процессе отправки отчета возникли проблемы. ' + e));
        }   
        
        return NULL;
    }
    
    public boolean startSend(){
        if(this.type_subject == NULL){
            this.type_subject = DailyReportSender.TYPE_TASK;   
        }
        if(this.type_subject == DailyReportSender.TYPE_TASK){
            return this.processTask();
        }
        if(this.type_subject == DailyReportSender.TYPE_EVENT){
            return this.processEvent();
        }
        if(this.type_subject == DailyReportSender.TYPE_ASSET){
            return this.processAsset();
        }
        if(this.type_subject == DailyReportSender.TYPE_SEND){
            return this.processSend();
        }
        return false;
    }
    
    private boolean processTask(){
        User__c user = [select Id, Name, Email__c, User__r.LastName from User__c where Id=:UserID];
        
        if(this.total_steps == null){
            Task[] tasks_all = [select Subject,Type,ActivityDate,What.Id,What.Type,WhoId,Description from Task where
                                                                DAY_ONLY(LastModifiedDate) =: Date.today() and
                                                                ActivityDate <=: Date.today() and
                                                                TionOwner__c =: user.Name ];
            this.total_steps = tasks_all.size();
            this.step = 0;
        }
        integer step = this.step;
        Task[] tasks = [select Subject,Type,ActivityDate,What.Id,What.Type,WhoId,Description from Task where
                                                                DAY_ONLY(LastModifiedDate) =: Date.today() and
                                                                ActivityDate <=: Date.today() and
                                                                TionOwner__c =: user.Name LIMIT 10 OFFSET :step];
        for (Task t : tasks) {
          tmpDates.add(t.ActivityDate);
        }
        for(Task t: tasks) {
            Contact contact = [select Name, AccountId, Title from Contact where Id=:t.WhoId];
            Account accnt = [select Name from Account where Id=:contact.AccountId];
            
            String soql = 'select Name from ' + t.What.Type + ' where Id=\'' + t.What.Id + '\'';
            sObject obj = Database.query(soql);
            String whatName = '';
            String regionName = '';
            if (obj.getSObjectType() == Asset.sObjectType) {
                whatName = ((Asset)obj).Name;
            } else if (obj.getSObjectType() == Campaign.sObjectType) {
                whatName = ((Campaign)obj).Name;
            } else if (obj.getSObjectType() == ProjectMember__c.sObjectType) {
            } else if (obj.getSObjectType() == Case.sObjectType) {
                whatName = ((Case)obj).Subject;
            } else if (obj.getSObjectType() == Account.sObjectType) {
                whatName = ((Account)obj).Name;
                Account acc = Database.query('select ShippingRegion__c from Account where Id=\'' + t.What.Id + '\'');
                regionName = acc.ShippingRegion__c;
            } else if (obj.getSObjectType() == Product2.sObjectType) {
                whatName = ((Product2)obj).Name;
            } else if (obj.getSObjectType() == Opportunity.sObjectType) {
                whatName = ((Opportunity)obj).Name;
                Opportunity opp = Database.query('select ProjectRegion__c from Opportunity where Id=\'' + t.What.Id + '\'');
                regionName = opp.ProjectRegion__c;
            } else if (obj.getSObjectType() == Solution.sObjectType) {
                whatName = ((Solution)obj).SolutionName;
            } else if (obj.getSObjectType() == Quote.sObjectType) {
                whatName = ((Quote)obj).Name;
            } else if (obj.getSObjectType() == Contract.sObjectType) {
                whatName = ((Contract)obj).Name;
            }
            this.html += '<tr><td>' + t.Subject + '</td><td>' +
                        t.Type + '</td><td>' +
                        t.ActivityDate.format() + '</td><td>' +
                        regionName + '</td><td>' + 
                        whatName + '</td><td>' +
                        accnt.Name + '</td><td>' +
                        contact.Name + '</td><td>' +
                        contact.Title + '</td><td>' +
                        t.Description + '</td></tr>';
        }
        this.step += 10;
        if(this.step >= this.total_steps) nextStep();
        return true;
    }
    private boolean processEvent(){
        User__c user = [select Id, Name, Email__c, User__r.LastName from User__c where Id=:UserID];
        
        if(this.total_steps == null){
            Event[] events_all = [select Subject,Type,ActivityDate,What.Id,What.Type,WhoId,Description from Event where
                                                                DAY_ONLY(LastModifiedDate) =: Date.today() and
                                                                ActivityDate <=: Date.today() and
                                                                TionOwner__c =: user.Name ];  
            this.total_steps = events_all.size();
            this.step = 0;
        }
        integer step = this.step;
        
        Event[] events = [select Subject,Type,ActivityDate,What.Id,What.Type,WhoId,Description from Event where
                                                                DAY_ONLY(LastModifiedDate) =: Date.today() and
                                                                ActivityDate <=: Date.today() and
                                                                TionOwner__c =: user.Name LIMIT 10 OFFSET :step]; 
        
        for (Event e : events) {
          tmpDates.add(e.ActivityDate);
        }
        for(Event e: events) {
            String whatName = '';
            String contactName = '';
            String contactTitle = '';
            String companyName = '';
            String regionName = '';
            try {
                Contact contact = [select Name, AccountId, Title from Contact where Id=:e.WhoId];
                contactName = contact.Name;
                contactTitle = contact.Title;
                Account accnt = [select Name from Account where Id=:contact.AccountId];
                companyName = accnt.Name;
                String soql = 'select Name from ' + e.What.Type + ' where Id=\'' + e.What.Id + '\'';
                sObject obj = Database.query(soql);
                
                if (obj.getSObjectType() == Asset.sObjectType) {
                    whatName = ((Asset)obj).Name;
                } else if (obj.getSObjectType() == Campaign.sObjectType) {
                    whatName = ((Campaign)obj).Name;
                } else if (obj.getSObjectType() == ProjectMember__c.sObjectType) {
                } else if (obj.getSObjectType() == Case.sObjectType) {
                    whatName = ((Case)obj).Subject;
                } else if (obj.getSObjectType() == Account.sObjectType) {
                    whatName = ((Account)obj).Name;
                    Account acc = Database.query('select ShippingRegion__c from Account where Id=\'' + e.What.Id + '\'');
                    regionName = acc.ShippingRegion__c;
                } else if (obj.getSObjectType() == Product2.sObjectType) {
                    whatName = ((Product2)obj).Name;
                } else if (obj.getSObjectType() == Opportunity.sObjectType) {
                    whatName = ((Opportunity)obj).Name;
                    Opportunity opp = Database.query('select ProjectRegion__c from Opportunity where Id=\'' + e.What.Id + '\'');
                    regionName = opp.ProjectRegion__c;
                } else if (obj.getSObjectType() == Solution.sObjectType) {
                    whatName = ((Solution)obj).SolutionName;
                } else if (obj.getSObjectType() == Quote.sObjectType) {
                    whatName = ((Quote)obj).Name;
                } else if (obj.getSObjectType() == Contract.sObjectType) {
                    whatName = ((Contract)obj).Name;
                }
            } catch(System.QueryException ex) {
            }
            html += '<tr><td>' + e.Subject + '</td><td>' +
                        e.Type + '</td><td>' +
                        e.ActivityDate.format() + '</td><td>' + 
                        regionName + '</td><td>' +
                        whatName + '</td><td>' +
                        companyName + '</td><td>' +
                        contactName + '</td><td>' +
                        contactTitle + '</td><td>' +
                        e.Description + '</td></tr>';
        }        
        this.step += 10;
        if(this.step >= this.total_steps) nextStep();
        return true;
    }
    private boolean processAsset(){        
        User__c user = [select Id, Name, Email__c, User__r.LastName from User__c where Id=:UserID];
        
        String action;
        if(user.User__r.LastName == 'Сервисный инженер'){
            List<Asset> Assets = [SELECT Id, LastModifiedDate, CreatedDate, Opportunity__r.Name, Opportunity__r.ProjectRegion__c, Description FROM asset WHERE UserTION__c = :user.Id AND DAY_ONLY(LastModifiedDate) =: Date.today()];
            for(Asset a: Assets){
                if(a.LastModifiedDate == a.CreatedDate) action = 'Создано';
                else action = 'Обновлено';
                html += '<tr><td>Оборудование</td><td>' +
                        action + '</td><td>' +
                        a.LastModifiedDate.format() + '</td><td>' + 
                        a.Opportunity__r.ProjectRegion__c + '</td><td>' +
                        a.Opportunity__r.Name + '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        a.Description + '</td></tr>';
            }
            List<Case> Cases = [SELECT Id, LastModifiedDate, CreatedDate, Opportunity__r.Name, Opportunity__r.ProjectRegion__c, Description FROM case WHERE UserTION__c = :user.Id AND DAY_ONLY(LastModifiedDate) =: Date.today()];
            for(Case c: Cases){
                if(c.LastModifiedDate == c.CreatedDate) action = 'Создано';
                else action = 'Обновлено';
                html += '<tr><td>Обращение</td><td>' +
                        action + '</td><td>' +
                        c.LastModifiedDate.format() + '</td><td>' + 
                        c.Opportunity__r.ProjectRegion__c + '</td><td>' +
                        c.Opportunity__r.Name + '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        c.Description + '</td></tr>';
            }
        }
        nextStep();
        return false;
    }
    private void nextStep(){
        this.type_subject += 1;
        this.step = null;
        this.total_steps = null;
    }
    
    private boolean processSend(){
        User__c user = [select Id, Name, Email__c, User__r.LastName from User__c where Id=:userId];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[]{};
        /*if(user.User__r.LastName == 'Сервисный инженер') toAddresses = new String[] {'md@tion.info','ko@tion.info','azh@tion.info'};
        else toAddresses = new String[] {'amel@tion.info','ko@tion.info','azh@tion.info','iam@tion.info','eg@tion.info','md@tion.info'};
        if(user.User__r.LastName == 'Менеджер по продажам Тион O2') toAddresses.add('sv@tion.info');*/
        if(user.Name == 'Вадим Семенихин') toAddresses = new String[] {'mukhortov-ia@tion.ru','ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Илья Мухортов') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Антон Чариков') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','eg@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Михаил Данилов') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Андрей Капкин') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Наталья Натфуллина') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','md@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Екатерина Горшенина') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Андрей Кузьмин') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Николай Мартышкин') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Павел Погожев') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Денис Могилёв') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Андрей Дюдюев') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Дмитрий Пронкин') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Николай Бурячковский') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','md@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Константин Парахин') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','md@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Роман Борисов') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Евгений Сафронов') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru','md@tion.ru','litvin-nl@tion.ru'};
        else if(user.Name == 'Кирилл Бабич') toAddresses = new String[] {'ko@tion.ru','zaa@tion.ru','ot@tion.ru','litvin-nl@tion.ru'};
        //else if(user.Name == 'Александр Бабин') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','md@tion.ru','pv@tion.ru'};
                        else toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','md@tion.ru','zaa@tion.ru','litvin-nl@tion.ru'};
        //String[] toAddresses = new String[] {'kds@tion.info'};
        //if(user.User__r.LastName == 'Менеджер по продажам Тион O2') toAddresses.add('kdss@tion.info');
        
        
        mail.setToAddresses(toAddresses);
        
        if(user.Email__c != '' && user.Email__c != NULL){
            String[] ccAddresses = new String[] {user.Email__c};
            mail.setCcAddresses(ccAddresses);
        }
        
        if(user.Email__c != '' && user.Email__c != NULL) mail.setInReplyTo(user.Email__c);
        else mail.setInReplyTo('no-reply@tion.info');
        
        mail.setSenderDisplayName(user.Name);
        
        List<Date> listOfReportDates = new List<Date>();
        listOfReportDates.addAll(tmpDates);
        listOfReportDates.sort(); 

        List<String> reportDates = new List<String>();
        for(Date d: listOfReportDates){
            reportDates.add(d.format());
        }
        
        mail.setSubject('Отчет за '+String.join(reportDates, ', ') +'. '+user.Name);
        
        String htmlBody = '';
        htmlBody += '<table  style=\'border:1px solid #ddd;\' border=\'1\' cellspacing=\'0\' cellpadding=\'2\' width=\'800\'>';
        htmlBody += '<tr><th>Тема</th><th>Тип события</th><th>Дата</th><th>Регион</th><th>Связано с</th><th>Контрагент</th><th>Контактное лицо</th><th>Должность</th><th>Содержание</th></tr>';
        htmlBody += html;
        htmlBody += '</table>';
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        html = '';
        nextStep();
        this.finished = true;
        return true;
    }
    
    
    public string getStringCounts(){
        string s = (this.step == NULL) ? 'выполнено, переход на следующий шаг' : String.valueOf(this.step) + ' из ' + String.valueOf(this.total_steps);
        return s;
    }
    
    public string gethtml(){
        return html;   
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*webService static void sendReport(Id userId) {
        User__c user = [select Id, Name, Email__c, User__r.LastName from User__c where Id=:userId];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[]{};
        if(user.Name == 'Вадим Семенихин') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info'};
        else if(user.Name == 'Тимофей Коркишко') toAddresses = new String[] {'amel@tion.info','azh@tion.info','iam@tion.info','ko@tion.info'};
        else if(user.Name == 'Андрей Капкин') toAddresses = new String[] {'amel@tion.info','azh@tion.info','iam@tion.info','ko@tion.info'};
        else if(user.Name == 'Сергей Мелентьев') toAddresses = new String[] {'amel@tion.info','azh@tion.info','iam@tion.info','ko@tion.info'};
        else if(user.Name == 'Иван Медведков') toAddresses = new String[] {'amel@tion.info','azh@tion.info','iam@tion.info','ko@tion.info'};
        else if(user.Name == 'Сергей Ушнурцев') toAddresses = new String[] {'amel@tion.info','azh@tion.info','iam@tion.info','ko@tion.info'};
        else if(user.Name == 'Евгений Гребенюк') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info'};
        else if(user.Name == 'Антон Чариков') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','eg@tion.info'};
        else if(user.Name == 'Михаил Данилов') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','naumov@tion.info'};
        else if(user.Name == 'Сергей Горячев') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','md@tion.info','naumov@tion.info'};
        else if(user.Name == 'Константин Наливайко') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','md@tion.info','naumov@tion.info'};
        else if(user.Name == 'Виктор Титов') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','md@tion.info','naumov@tion.info'};
        else if(user.Name == 'Николай Доронин') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','md@tion.info','naumov@tion.info'};
        else if(user.Name == 'Владислав Салимгареев') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','iam@tion.info'};
        else if(user.Name == 'Ярослав Шилов') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info'};
        else if(user.Name == 'Александра Потапова') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','ys@tion.info'};
        else if(user.Name == 'Алексей Ревякин') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','ys@tion.info'};
        else if(user.Name == 'Анастасия Суворова') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','ys@tion.info'};
        else if(user.Name == 'Кирина Воронкова') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','iam@tion.info'};
        else if(user.Name == 'Александр Бондарь') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','ys@tion.info'};
        else if(user.Name == 'Андрей Ефремов') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','ys@tion.info'};
        else if(user.Name == 'Наталья Натфуллина') toAddresses = new String[] {'amel@tion.info','azh@tion.info','ko@tion.info','md@tion.info'};
        else if(user.Name == 'Дмитрий Пронкин') toAddresses = new String[] {'ko@tion.ru','ot@tion.ru','zaa@tion.ru'};
                else toAddresses = new String[] {'amel@tion.info','ko@tion.info','azh@tion.info','iam@tion.info','eg@tion.info','md@tion.info'};
        //String[] toAddresses = new String[] {'kds@tion.info'};
        //if(user.User__r.LastName == 'Менеджер по продажам Тион O2') toAddresses.add('kdss@tion.info');
        
        
        mail.setToAddresses(toAddresses);
        
        if(user.Email__c != '' && user.Email__c != NULL){
            String[] ccAddresses = new String[] {user.Email__c};
            mail.setCcAddresses(ccAddresses);
        }
        
        if(user.Email__c != '' && user.Email__c != NULL) mail.setInReplyTo(user.Email__c);
        else mail.setInReplyTo('no-reply@tion.info');
        
        mail.setSenderDisplayName(user.Name);
        Task[] tasks = [select Subject,Type,ActivityDate,What.Id,What.Type,WhoId,Description from Task where
                                                                DAY_ONLY(LastModifiedDate) =: Date.today() and
                                                                ActivityDate <=: Date.today() and
                                                                TionOwner__c =: user.Name ];
        Event[] events = [select Subject,Type,ActivityDate,What.Id,What.Type,WhoId,Description from Event where
                                                                DAY_ONLY(LastModifiedDate) =: Date.today() and
                                                                ActivityDate <=: Date.today() and
                                                                TionOwner__c =: user.Name ];                                                        

        //Generating report dates for mail header        
        Set<Date> tmpDates = new Set<Date>();
        for (Task t : tasks) {
          tmpDates.add(t.ActivityDate);
        }
        for (Event e : events) {
          tmpDates.add(e.ActivityDate);
        }
        List<Date> listOfReportDates = new List<Date>();
        listOfReportDates.addAll(tmpDates);
        listOfReportDates.sort(); 

        List<String> reportDates = new List<String>();
        for(Date d: listOfReportDates){
            reportDates.add(d.format());
        }

        mail.setSubject('Отчет за '+String.join(reportDates, ', ') +'. '+user.Name);
        
        String htmlBody = '';
        htmlBody += '<table  style=\'border:1px solid #ddd;\' border=\'1\' cellspacing=\'0\' cellpadding=\'2\' width=\'800\'>';
        htmlBody += '<tr><th>Тема</th><th>Тип события</th><th>Дата</th><th>Регион</th><th>Связано с</th><th>Контрагент</th><th>Контактное лицо</th><th>Должность</th><th>Содержание</th></tr>';
        for(Task t: tasks) {
            Contact contact = [select Name, AccountId, Title from Contact where Id=:t.WhoId];
            Account accnt = [select Name from Account where Id=:contact.AccountId];
            
            String soql = 'select Name from ' + t.What.Type + ' where Id=\'' + t.What.Id + '\'';
            sObject obj = Database.query(soql);
            String whatName = '';
            String regionName = '';
            if (obj.getSObjectType() == Asset.sObjectType) {
                whatName = ((Asset)obj).Name;
            } else if (obj.getSObjectType() == Campaign.sObjectType) {
                whatName = ((Campaign)obj).Name;
            } else if (obj.getSObjectType() == ProjectMember__c.sObjectType) {
            } else if (obj.getSObjectType() == Case.sObjectType) {
                whatName = ((Case)obj).Subject;
            } else if (obj.getSObjectType() == Account.sObjectType) {
                whatName = ((Account)obj).Name;
                Account acc = Database.query('select ShippingRegion__c from Account where Id=\'' + t.What.Id + '\'');
                regionName = acc.ShippingRegion__c;
            } else if (obj.getSObjectType() == Product2.sObjectType) {
                whatName = ((Product2)obj).Name;
            } else if (obj.getSObjectType() == Opportunity.sObjectType) {
                whatName = ((Opportunity)obj).Name;
                Opportunity opp = Database.query('select ProjectRegion__c from Opportunity where Id=\'' + t.What.Id + '\'');
                regionName = opp.ProjectRegion__c;
            } else if (obj.getSObjectType() == Solution.sObjectType) {
                whatName = ((Solution)obj).SolutionName;
            } else if (obj.getSObjectType() == Quote.sObjectType) {
                whatName = ((Quote)obj).Name;
            } else if (obj.getSObjectType() == Contract.sObjectType) {
                whatName = ((Contract)obj).Name;
            }
            htmlBody += '<tr><td>' + t.Subject + '</td><td>' +
                        t.Type + '</td><td>' +
                        t.ActivityDate.format() + '</td><td>' +
                        regionName + '</td><td>' + 
                        whatName + '</td><td>' +
                        accnt.Name + '</td><td>' +
                        contact.Name + '</td><td>' +
                        contact.Title + '</td><td>' +
                        t.Description + '</td></tr>';
        }
        for(Event e: events) {
            String whatName = '';
            String contactName = '';
            String contactTitle = '';
            String companyName = '';
            String regionName = '';
            try {
                Contact contact = [select Name, AccountId, Title from Contact where Id=:e.WhoId];
                contactName = contact.Name;
                contactTitle = contact.Title;
                Account accnt = [select Name from Account where Id=:contact.AccountId];
                companyName = accnt.Name;
                String soql = 'select Name from ' + e.What.Type + ' where Id=\'' + e.What.Id + '\'';
                sObject obj = Database.query(soql);
                
                if (obj.getSObjectType() == Asset.sObjectType) {
                    whatName = ((Asset)obj).Name;
                } else if (obj.getSObjectType() == Campaign.sObjectType) {
                    whatName = ((Campaign)obj).Name;
                } else if (obj.getSObjectType() == ProjectMember__c.sObjectType) {
                } else if (obj.getSObjectType() == Case.sObjectType) {
                    whatName = ((Case)obj).Subject;
                } else if (obj.getSObjectType() == Account.sObjectType) {
                    whatName = ((Account)obj).Name;
                    Account acc = Database.query('select ShippingRegion__c from Account where Id=\'' + e.What.Id + '\'');
                    regionName = acc.ShippingRegion__c;
                } else if (obj.getSObjectType() == Product2.sObjectType) {
                    whatName = ((Product2)obj).Name;
                } else if (obj.getSObjectType() == Opportunity.sObjectType) {
                    whatName = ((Opportunity)obj).Name;
                    Opportunity opp = Database.query('select ProjectRegion__c from Opportunity where Id=\'' + e.What.Id + '\'');
                    regionName = opp.ProjectRegion__c;
                } else if (obj.getSObjectType() == Solution.sObjectType) {
                    whatName = ((Solution)obj).SolutionName;
                } else if (obj.getSObjectType() == Quote.sObjectType) {
                    whatName = ((Quote)obj).Name;
                } else if (obj.getSObjectType() == Contract.sObjectType) {
                    whatName = ((Contract)obj).Name;
                }
            } catch(System.QueryException ex) {
            }
            htmlBody += '<tr><td>' + e.Subject + '</td><td>' +
                        e.Type + '</td><td>' +
                        e.ActivityDate.format() + '</td><td>' + 
                        regionName + '</td><td>' +
                        whatName + '</td><td>' +
                        companyName + '</td><td>' +
                        contactName + '</td><td>' +
                        contactTitle + '</td><td>' +
                        e.Description + '</td></tr>';
        }
        String action;
        if(user.User__r.LastName == 'Сервисный инженер'){
            List<Asset> Assets = [SELECT Id, LastModifiedDate, CreatedDate, Opportunity__r.Name, Opportunity__r.ProjectRegion__c, Description FROM asset WHERE UserTION__c = :user.Id AND DAY_ONLY(LastModifiedDate) =: Date.today()];
            for(Asset a: Assets){
                if(a.LastModifiedDate == a.CreatedDate) action = 'Создано';
                else action = 'Обновлено';
                htmlBody += '<tr><td>Оборудование</td><td>' +
                        action + '</td><td>' +
                        a.LastModifiedDate.format() + '</td><td>' + 
                        a.Opportunity__r.ProjectRegion__c + '</td><td>' +
                        a.Opportunity__r.Name + '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        a.Description + '</td></tr>';
            }
            List<Case> Cases = [SELECT Id, LastModifiedDate, CreatedDate, Opportunity__r.Name, Opportunity__r.ProjectRegion__c, Description FROM case WHERE UserTION__c = :user.Id AND DAY_ONLY(LastModifiedDate) =: Date.today()];
            for(Case c: Cases){
                if(c.LastModifiedDate == c.CreatedDate) action = 'Создано';
                else action = 'Обновлено';
                htmlBody += '<tr><td>Обращение</td><td>' +
                        action + '</td><td>' +
                        c.LastModifiedDate.format() + '</td><td>' + 
                        c.Opportunity__r.ProjectRegion__c + '</td><td>' +
                        c.Opportunity__r.Name + '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        '</td><td>' +
                        c.Description + '</td></tr>';
            }
        }
        htmlBody += '</table>';
        mail.setHtmlBody(htmlBody);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }*/
}