@isTest
private inherited sharing class AccountTriggerHandler_Tests {
    @isTest
    static void afterUpdateUpdatesContactDescriptionWhenNameChanges() {
        Account acc = new Account(Name = 'Acme One');
        insert acc;

        Contact con = new Contact(LastName = 'Primary Contact', AccountId = acc.Id, Description = 'before');
        if (Schema.SObjectType.Contact.fields.getMap().containsKey('IsPriorityRecord')) {
            con.put('IsPriorityRecord', true);
        }
        insert con;

        Test.startTest();
        acc.Name = 'Acme Two';
        AccountTriggerHandler.handleAfterUpdate(new List<Account>{ acc }, new Map<Id, Account>{ acc.Id => new Account(Id = acc.Id, Name = 'Acme One') });
        Test.stopTest();

        Contact updated = [
            SELECT Description
            FROM Contact
            WHERE Id = :con.Id
            LIMIT 1
        ];

        System.Assert.isTrue(
            updated.Description != null && updated.Description.contains('Acme Two'),
            'Expected Contact.Description to be updated using the new Account name'
        );
    }

    @isTest
    static void afterUpdateSkipsWhenNameUnchanged() {
        Account acc = new Account(Name = 'Stable Name');
        insert acc;

        Contact con = new Contact(LastName = 'Primary Contact', AccountId = acc.Id, Description = 'unchanged');
        if (Schema.SObjectType.Contact.fields.getMap().containsKey('IsPriorityRecord')) {
            con.put('IsPriorityRecord', true);
        }
        insert con;

        Test.startTest();
        AccountTriggerHandler.handleAfterUpdate(new List<Account>{ acc }, new Map<Id, Account>{ acc.Id => new Account(Id = acc.Id, Name = 'Stable Name') });
        Test.stopTest();

        Contact checked = [
            SELECT Description
            FROM Contact
            WHERE Id = :con.Id
            LIMIT 1
        ];

        System.Assert.areEqual(
            'unchanged',
            checked.Description,
            'Expected Contact.Description to remain unchanged when Account.Name does not change'
        );
    }
}
