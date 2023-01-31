trigger CQ_AccountTrigger on Account (before insert,after insert,before update) {
    
    
    List<Account> actLst = Trigger.new;
    if(Trigger.isBefore){
        System.debug('Trigger.isBefore start----');
        
        if(Trigger.isInsert){
            List<String> accIdLst = new List<String>();
            for(Account acc : actLst){
                System.debug('Account : '+acc.active__c)     ; 
                if(acc.active__c){
                    Trigger.new[0].Active__c.addError('Account cannot be created with Active field true');
                }
            }
        }
        
        //for update when the Active is true then check for team member's Member_Type__C HR/Admin
        
        if(Trigger.isUpdate){
            //Get User permission to make Account active 
            //SELECT Id, AssigneeId, Assignee.Name, PermissionSet.IsOwnedByProfile
            List<PermissionSetAssignment>  psaLst = [SELECT Id, AssigneeId, Assignee.Name, PermissionSet.IsOwnedByProfile FROM PermissionSetAssignment
                                                     WHERE PermissionSetId in (select Id FROM PermissionSet  where name='Account_Admin') and AssigneeId = :UserInfo.getUserId() ] ;
            System.debug(psaLst.size()+'-:psaLst.size()---------------psaLst----------------'+psaLst);
            if(psaLst!=null && psaLst.size()>0){
                System.debug('---In if part user is from Account_Admin permission Set');
                List<String> accIdLst = new List<String>();
                for(Account acc : actLst){
                    System.debug('Account : '+acc.active__c)     ;           
                    if(acc.active__c){
                        //check for Team member Member_Type__c is HR/Admin  then only make active or else throw error
                        accIdLst.add(acc.Id);
                    }
                }
                //Now get the teamMembers Associated to Each Account            
                List<Account>  accWithTMLst = [select id , (select Id ,Member_Type__c from SQX_Team_Members__r) from Account where Id in :accIdLst];
                for(Account acc : accWithTMLst){
                    List<SQX_Team_Members__c> tmLst = acc.SQX_Team_Members__r;
                    //now check for team member Member_type__c
                    
                    for( SQX_Team_Members__c tm : tmLst){
                        System.debug('Team Members : tm : '+tm);
                        if(tm.Member_Type__c !='Admin'  && tm.Member_Type__c !='HR'  ){
                            Trigger.new[0].Active__c.addError('Account cannot be active ,since one of the team members Member_Type is neither Admin nor HR');
                        }
                    }
                }
            }else{
                System.debug('--In else part for non Account_Admin permission set throw error ');
                Trigger.new[0].addError('Logged in User not menber of Account_Admin permission set');
            }
        }
        
        System.debug('Trigger.isBefore end----');
    } if(Trigger.isAfter){
        System.debug('Trigger.isAfter start----');
        
        if(Trigger.isInsert){
            System.debug('Trigger.isInsert start----');
            //create team members  for each Account record
            //Name = Team Member 1, Contact Info = Blank, Member Type = Blank
            //Name = Team Member 2, Contact Info = Blank, Member Type = Blank
            
            //bulkify
            List<SQX_Team_Members__c> lstSTM = new  List<SQX_Team_Members__c>();
            for(Account acc : actLst){                
                SQX_Team_Members__c   stm1 = new SQX_Team_Members__c();
                stm1.name='Team Member 1'+' '+acc.name;
                stm1.Member_Type__c='';
                stm1.Contact_Info__c='';
                stm1.Account__c=acc.Id;
                
                SQX_Team_Members__c   stm2 = new SQX_Team_Members__c();                
                stm2.name='Team Member 2'+' '+acc.name;
                stm2.Member_Type__c='';
                stm2.Contact_Info__c='';
                stm2.Account__c=acc.Id;
                
                lstSTM.add(stm1);
                lstSTM.add(stm2);                
            }           
            
            insert lstSTM;
            System.debug('Trigger.isInsert end----');
        }
        
        System.debug('Trigger.isAfter end----');
        
    }
    
    
}