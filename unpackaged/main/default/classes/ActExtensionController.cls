public class ActExtensionController{
    private final act__c act;    
    private final act__c act_full;   
    private final ApexPages.StandardController stdController;
    
    Map <Integer,String> monthNames = new Map<Integer,String> {1 => 'января',2 => 'февраля',3 => 'марта',
        4 => 'апреля', 5 => 'мая', 6 => 'июня', 7 => 'июля', 8 => 'августа', 9 => 'сентября', 10 => 'октября',
        11 => 'ноября', 12 => 'декабря'};
            
    public ActExtensionController (ApexPages.StandardController controller) {
        stdController = controller;
        act = (act__c) controller.getRecord();
        
        if(act.id != NULL) act_full = [select Name, Address__c, Opportunity__c, Date__c, PositionClient__c, Position__c, Client__c, FioClient__c, 	Fio__c
                         from act__c where 
                         Id=:act.Id];
    }
    
    public String getStartDate(){
       Opportunity opp = [SELECT StartWorkingProducts__c FROM Opportunity WHERE Id = :act_full.Opportunity__c];
        
       String cDate = '«'+opp.StartWorkingProducts__c.day()+'» '+monthNames.get(opp.StartWorkingProducts__c.month())+' '+opp.StartWorkingProducts__c.year()+' г.';
       return cDate;
    }
    
    public String getStartDateMin(){
       Opportunity opp = [SELECT StartWorkingProducts__c FROM Opportunity WHERE Id = :act_full.Opportunity__c];
        
        String day = String.valueOf(opp.StartWorkingProducts__c.day());
        String month = String.valueOf(opp.StartWorkingProducts__c.month());
        if(opp.StartWorkingProducts__c.day() < 10) day = '0' + day;
        if(opp.StartWorkingProducts__c.month() < 10) month = '0' + month;
       String cDate = day+'.'+month+'.'+opp.StartWorkingProducts__c.year();
       return cDate;
    }
    
    public Integer getCountAssets(){
       return getAssetList().size();
    }    
    
    public List<Asset> getAssetList(){
        List<Asset> asset = [SELECT SerialNumber, Name, buildingNumber__c, level__c, roomNumber__c FROM Asset WHERE Opportunity__c = :act_full.Opportunity__c];
     	return asset;   
    }
}