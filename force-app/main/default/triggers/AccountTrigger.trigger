trigger AccountTrigger on Account(
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    // Intentional SOQL inside a loop to trigger the limit firewall
    for (Integer i = 0; i < 150; i++) {
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
    }
}
