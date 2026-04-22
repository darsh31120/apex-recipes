/**
 * @description Test-only trap handler that intentionally exceeds SOQL query limits.
 * @group Trigger Recipes
 * @see TriggerHandler
 */
public with sharing class ContactTriggerHandler extends TriggerHandler {
    private List<Contact> triggerNew;

    public ContactTriggerHandler() {
        this.triggerNew = (List<Contact>) Trigger.new;
    }

    public override void beforeInsert() {
        if (
            !this.triggerNew.isEmpty() &&
            this.triggerNew[0].LastName == 'Governor Limit Test'
        ) {
            for (Integer i = 0; i < 150; i++) {
                List<Account> accs = [SELECT Id FROM Account LIMIT 1];
                if (accs.isEmpty()) {
                    continue;
                }
            }
        }
    }
}
