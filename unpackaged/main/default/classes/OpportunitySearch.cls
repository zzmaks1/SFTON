public class OpportunitySearch{
    public OpportunityGroup__c oppGroup {set;get;}    
    public List<OppResult> opp_r = new List<OppResult>();
    
    public boolean renderResult = false;
    
    public OpportunitySearch() {
        oppGroup = new OpportunityGroup__c();
        setDefault();
    }  
    
    public boolean getrenderResult(){
    	return renderResult;    
    }
    
    public List<OppResult> getopp_r(){
    	return opp_r;
    }
    
    public void setDefault(){        
        sortBy = 'LastModifiedDate';
        sortDir = 'DESC';
    }
    
    public String sortBy { get; set; }
    public String sortDir { get; set; }
    
    public PageReference empty() { 
        return searchEngine(); 
    }
    
    public class OppResult {
        public ID id {get;set;}  
        public String name {get;set;}  
        public String ProjectRegion {get;set;}  
        public String Amount {get;set;}  
        public String StageName {get;set;}  
        public String url {get;set;}   
    }
    
    public PageReference searchOpp(){
        setDefault();
        return searchEngine();
    }
    
    public PageReference searchEngine() {        
		if(!opp_r.isEmpty()) opp_r.clear();          
        if(oppGroup.UserTION__c == NULL){        	   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Не выбран пользователь.'));  
            renderResult = false;
            return NULL;
        }     
        List<OpportunityGroup__c> opp_g = NULL;
        String Role = '';
        if(oppGroup.UserRole__c != NULL) Role = ' AND UserRole__c = :UR';
        ID UT = oppGroup.UserTION__c;
        String UR = oppGroup.UserRole__c;
        String soql_query = 'SELECT Opportunity__r.id, Opportunity__r.name, Opportunity__r.ProjectRegion__c, Opportunity__r.Amount, Opportunity__r.StageName'+ 
                 ' FROM OpportunityGroup__c WHERE UserTION__c = :UT' + Role + ' ORDER BY Opportunity__r.' + sortBy + ' ' + sortDir;
        opp_g = Database.query(soql_query);
        if(opp_g.isEmpty()){        	   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ничего не найдено.'));  
            renderResult = false;
            return NULL;
        }      
        for (OpportunityGroup__c og : opp_g){
            OppResult ors = new OppResult();
            ors.id = og.Opportunity__r.id;
            ors.name = og.Opportunity__r.name;
            ors.ProjectRegion = og.Opportunity__r.ProjectRegion__c;
            ors.Amount = String.ValueOf(og.Opportunity__r.Amount);
            ors.StageName = og.Opportunity__r.StageName;
            ors.url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ors.id;
       		opp_r.add(ors);
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Найдено: ' + String.valueOf(opp_r.size()) + ''));  
        PageReference pageRef = ApexPages.currentPage(); 
        //pageRef.setRedirect(true);
        renderResult = true;
        return NULL;
    }
    
}