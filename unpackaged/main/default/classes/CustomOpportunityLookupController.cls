public with sharing class CustomOpportunityLookupController {

  public Opportunity opp {get;set;} 
  public List<Opportunity> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  
  public CustomOpportunityLookupController() {
    opp = new Opportunity();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    runSearch();  
  }
 
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
 
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
 
  // run the search and return the records found. 
  private List<Opportunity> performSearch(string searchString) {
 
    String soql = 'select id, name, stagename from opportunity';
    if(searchString != '' && searchString != null)
      soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25 ';
    System.debug(soql);
    return database.query(soql); 
 
  }
 
  // save the new opportunity record
  public PageReference saveOpportunity() {
    opp.Owner = [SELECT Id FROM User
                   WHERE Id = :UserInfo.getUserId()];
    Integer stageIndex = 0;
    RecordType recType = [select developername from RecordType where id=:opp.RecordTypeId];
    if(recType.DeveloperName == 'BuildingStageProjectType') stageIndex = 6;
    opp.StageName = Opportunity.StageName.getDescribe().getPicklistValues().get(stageIndex).getValue();
    insert opp;
    // reset the opportunity
    opp = new Opportunity();
    searchString = '';
    runSearch();
    return System.currentPageReference();
  }
 
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
 
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
  @isTest(SeeAllData=true)
  static void mainTestMethod() {
        PageReference pageRef = Page.CustomOpportunityLookup;
        pageRef.getParameters().put('lksrch','asdff');
        pageRef.getParameters().put('frm','form');
        pageRef.getParameters().put('txt','text');
        Test.setCurrentPageReference(pageRef);
        CustomOpportunityLookupController controller = new CustomOpportunityLookupController();
        controller.opp.Name='Test opp';
        controller.opp.StageName='Подбор оборудования';
        controller.opp.CloseDate=Date.today();
        controller.opp.RecordTypeId='012b0000000L3bI';
      	User__c UT = new User__c(User__c = UserInfo.getUserId(), Name = 'tester');
        insert UT;
        controller.opp.UserTION__c= UT.id;
        controller.search();
        controller.runSearch();
        controller.performSearch('asdf');
        controller.saveOpportunity();
        controller.getFormTag();
        controller.getTextBox();
  } 
}