trigger Claimtrigger on Claim__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        if(!ClaimTriggerHandler.isRecursive){
            List<Claim__c> claimsToGenerateReq = new List<Claim__c> ();

            List<Claim__c> claimsToExtractRefId = new List<Claim__c> ();

            for(Claim__c claim : trigger.new){
                if(claim.Is_Ready_For_Submission__c && !trigger.oldMap.get(claim.Id).Is_Ready_For_Submission__c){
                    claimsToGenerateReq.add(claim);
                }else if(claim.Confirmation_Note_Long__c!=null && trigger.oldMap.get(claim.Id).Confirmation_Note_Long__c != trigger.newMap.get(claim.Id).Confirmation_Note_Long__c ){
                    claimsToExtractRefId.add(claim);
                }  
            }
            if(!claimsToGenerateReq.isEmpty()){
               ClaimTriggerHandler.generateClaimsRequest(claimsToGenerateReq);
            }

            if(!claimsToExtractRefId.isEmpty()){
                ClaimTriggerHandler.extratctReferenceId(claimsToExtractRefId);
            }
        }          
        
      }  

}