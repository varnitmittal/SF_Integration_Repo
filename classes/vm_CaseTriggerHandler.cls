public class vm_CaseTriggerHandler {
    public static void handle_CaseDeleteByAdminOnly_beforeDelete(List<Case> caseList){
        Id SysAdmId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id currentUserId = UserInfo.getProfileId();
        System.debug(SysAdmId + ' ' + currentUserId);
        for(Case c: caseList){
            if(SysAdmId != currentUserId){
             	   c.addError('Only sys admin can perform delete!');
            }   
        }       
    }

    public static void handle_CreateZendeskTicketCallout_afterInsertUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        Map<Id, Case> validatedCases = new Map<Id, Case>(); //would hold valid cases for callout
        Map<Id, Id> contactId_mapped_caseId = new Map<Id, Id>();
        Map<Id, Contact> caseId_mapped_Contact = new Map<Id, Contact>();
        //getting correct recordtype Id 
        String zendesk_Case_RT_Id = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Zendesk_Integration_Type').getRecordTypeId();
        
        for(Case c: newCaseList){ //looping all cases
            if(c.RecordTypeId == zendesk_Case_RT_Id){ //filtering correct record type
                if(oldCaseMap != null && oldCaseMap.containsKey(c.Id)){ //when an existing case is updated
                    //filtering existing cases with checkbox true that was false earlier
                    if(c.Create_Zendesk_Ticket__c == true && oldCaseMap.get(c.Id).Create_Zendesk_Ticket__c != c.Create_Zendesk_Ticket__c){
                        validatedCases.put(c.id, c); //valid cases
                        if(c.ContactId != null){
                            contactId_mapped_caseId.put(c.ContactId, c.Id);
                        }
                    }
                }
                else{ //when an new case is created
                    if(c.Create_Zendesk_Ticket__c == true){
                        validatedCases.put(c.id, c); //valid cases
                        if(c.ContactId != null){
                            contactId_mapped_caseId.put(c.ContactId, c.Id);
                        }
                    }
                }
            }
        }
        System.debug(validatedCases);

        if(!validatedCases.isEmpty()){
            System.debug('Some Validated Cases are there');
            
            //querying contact data for Ticket Requester
            for(Contact con: [SELECT Id, Name, Email, Account.Name FROM Contact WHERE ID IN :contactId_mapped_caseId.keySet()]){
                caseId_mapped_Contact.put(contactId_mapped_caseId.get(con.Id), con);
            }

            //instance of body wrapper to hold all tickets
            VM_ZendeskUtil.ticketsBodyWrapper tbw = new VM_ZendeskUtil.ticketsBodyWrapper();
            //list of all tickets to be created
            List<VM_ZendeskUtil.cls_tickets> ticketList =  new List<VM_ZendeskUtil.cls_tickets>();
            for(Case c: validatedCases.values()){
                System.debug(c);
                //instance of ticket class, would be accumulated
                VM_ZendeskUtil.cls_tickets t =  new VM_ZendeskUtil.cls_tickets();
                t.status = c.Status != 'Closed' ? 'Open' : 'Solved';
                t.tags = new List<String>{'Created_Via_SF_Automation', 'A', 'B', 'C'};
                t.comment = new VM_ZendeskUtil.cls_comment(String.valueOf(Date.today()).removeEnd(' 00:00:00') + ' ' + caseId_mapped_Contact?.get(c.Id)?.Account.Name);
                t.priority = c.Priority;
                t.subject = c.Subject;
                VM_ZendeskUtil.cls_requester reqstr = new VM_ZendeskUtil.cls_requester();
                    reqstr.locale_id = 93;
                    reqstr.details = caseId_mapped_Contact?.get(c.Id)?.Id; //c.ContactId is also fine
                    reqstr.name = caseId_mapped_Contact?.get(c.Id)?.Name;
                    reqstr.email = caseId_mapped_Contact?.get(c.Id)?.Email; //c.ContactEmail is also fine
                t.requester = reqstr;

                ticketList.add(t);
            }
            System.debug(ticketList);
            tbw.tickets = ticketList;
            System.debug(JSON.serialize(tbw));
            System.enqueueJob(new VM_ZendeskCreateTickets(tbw));
        } else {
            System.debug('No valid cases found for callout');
        }

    }
}
