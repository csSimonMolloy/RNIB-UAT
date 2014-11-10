trigger ContactTrigger on Contact (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if (trigger.isBefore){
        if (trigger.isInsert){
            ContactTriggerMethods.assignContactToAccount(trigger.new);
        }
        
        if (trigger.isUpdate){
            List<Contact> processList = new List<Contact>();
            for (Contact c : trigger.new){
                Contact oldContact = trigger.oldMap.get(c.Id);
                if (c.MailingStreet != oldContact.MailingStreet || 
                    c.MailingCity != oldContact.MailingCity ||
                    c.MailingState != oldContact.MailingState || 
                    c.MailingPostalCode != oldContact.MailingPostalCode || 
                    c.MailingCountry != oldContact.MailingCountry){
                        processList.add(c);
                    }
            }
            ContactTriggerMethods.clearLocationFields(processList);
        }
    }

    if (trigger.isAfter){
        if (trigger.isUpdate){
            ContactTriggerMethods.setHolidayField(trigger.new);
        }
    }

}