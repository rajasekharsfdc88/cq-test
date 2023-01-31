@isTest
public class CQ_Test_AccountTrigger {
    
    @TestSetUp
    public static void testDataSetUp(){
        
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'user1_test@rajsfdc88.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Compliance Quest SD Profile'];
        User u = new User(Alias = 'user1', Email='user1@rajsfdc88.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;     
        
        
    }
    
    
    @isTest
    public static void accountInsertWithPermSet(){
        List<User> usrLst = [select Id from User where username = 'user1_test@rajsfdc88.com' ];
        
        // Query your permission set name from Organization that your want to test.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Admin'];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usrLst[0].Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        // Run your code with inserted user.
        System.runAs(usrLst[0])
        {
            Account a = new Account();
            a.Name='CQ Test1';
            
            insert a;                
            
        }
        
    }
    
    
    
    
    
    @isTest
    public static void accountInsertWithPermSetActive(){
        List<User> usrLst = [select Id from User where username = 'user1_test@rajsfdc88.com' ];
        // Query your permission set name from Organization that your want to test.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Admin'];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usrLst[0].Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        // Run your code with inserted user.
        System.runAs(usrLst[0])
        {
            Account a = new Account();
            a.Name='CQ Test1';
            a.Active__c=true;
            try{
                insert a;                
            }            
            catch(Exception e)                
            {                
                System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));                
            } 
            
        }
        
    }
    
    @isTest
    public static void accountUpdateWithPermSet(){
        List<User> usrLst = [select Id from User where username = 'user1_test@rajsfdc88.com' ];
        
        // Query your permission set name from Organization that your want to test.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Admin'];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usrLst[0].Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        // Run your code with inserted user.
        System.runAs(usrLst[0])
        {
            Account a = new Account();
            a.Name='CQ Test1';            
            insert a;   
            
            List<Account>  accWithTMLst = [select id , (select Id ,Member_Type__c from SQX_Team_Members__r) from Account where Id = :a.Id];
            List<SQX_Team_Members__c> tmFinalLst = new   List<SQX_Team_Members__c>();
            for(Account acc : accWithTMLst){
                List<SQX_Team_Members__c> tmLst = acc.SQX_Team_Members__r;
                //now check for team member Member_type__c
                
                for( SQX_Team_Members__c tm : tmLst){
                    tm.Member_Type__c ='Admin'  ;
                    tmFinalLst.add(tm);
                }
            }
            update tmFinalLst;
            a.Active__c=true;
            update a;            
            
        }
        
    }
    
     @isTest
    public static void accountUpdateWithPermSetWithOutMemberType(){
        List<User> usrLst = [select Id from User where username = 'user1_test@rajsfdc88.com' ];
        
        // Run your code with inserted user.
        System.runAs(usrLst[0])
        {
            try{
                Account a = new Account();
                a.Name='CQ Test1';            
                insert a;   
                
                List<Account>  accWithTMLst = [select id , (select Id ,Member_Type__c from SQX_Team_Members__r) from Account where Id = :a.Id];
                List<SQX_Team_Members__c> tmFinalLst = new   List<SQX_Team_Members__c>();
                for(Account acc : accWithTMLst){
                    List<SQX_Team_Members__c> tmLst = acc.SQX_Team_Members__r;
                    //now check for team member Member_type__c
                    
                    for( SQX_Team_Members__c tm : tmLst){
                        tm.Member_Type__c ='Admin'  ;
                        tmFinalLst.add(tm);
                    }
                }
                update tmFinalLst;
                a.Active__c=true;
                update a;            
                
            }catch(Exception e)                
            {                
                System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));                
            } 
            
        }     
    }
   
    
    @isTest
    public static void accountUpdateWithOutPermSet(){
        List<User> usrLst = [select Id from User where username = 'user1_test@rajsfdc88.com' ];
        
        // Run your code with inserted user.
        System.runAs(usrLst[0])
        {
            try{
                Account a = new Account();
                a.Name='CQ Test1';            
                insert a;   
                
                a.Active__c=true;
                update a;            
                
            }catch(Exception e)                
            {                
                System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));                
            } 
            
        }     
    }
    
    
    
    
}