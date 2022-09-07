public with sharing class CustomAccountLookupController {
 
  public Account account {get;set;} // new account to create
  public List<Account> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  
  public CustomAccountLookupController() {
    account = new Account();
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
  private List<Account> performSearch(string searchString) {
 
    String soql = 'select id, name,shippingregion__c from account';
    if(searchString != '' && searchString != null)
      soql = soql +  ' where name LIKE \'%' + searchString +'%\' or HiddenRegionFieldForSearch__c LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25 ';
    System.debug(soql);
    return database.query(soql); 
 
  }
 
  // save the new account record
  public PageReference saveAccount() {
    insert account;
    // reset the account
    account = new Account();
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
  
  @isTest static void mainTestMethod() {
        PageReference pageRef = Page.CustomAccountLookup;
        pageRef.getParameters().put('lksrch','asdff');
        pageRef.getParameters().put('frm','form');
        pageRef.getParameters().put('txt','text');
        Test.setCurrentPageReference(pageRef);
        CustomAccountLookupController controller = new CustomAccountLookupController();
        controller.account.Name='test acc';
        controller.search();
        controller.runSearch();
        controller.performSearch('asdf');
        controller.saveAccount();
        controller.getFormTag();
        controller.getTextBox();
  } 
}