trigger vm_CaseTrigger on Case (before insert, before delete, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        for(Case c: Trigger.New){
            if(c.Origin == 'Phone'){
                c.Priority = 'High';
            }else{
                c.Priority = 'Low';
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        vm_CaseTriggerHandler.handle_CaseDeleteByAdminOnly_beforeDelete(Trigger.Old);
    }

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        vm_CaseTriggerHandler.handle_CreateZendeskTicketCallout_afterInsertUpdate(Trigger.New, Trigger.OldMap);
    }
}