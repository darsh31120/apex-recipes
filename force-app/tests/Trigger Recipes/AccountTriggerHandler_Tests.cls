@isTest
private inherited sharing class AccountTriggerHandler_Tests {
    @isTest
    static void afterUpdateUpdatesContactDescriptionWhenNameChanges() {
        Account acc = new Account(Name = 'Acme One');
        insert acc;

        Contact con = new Contact(LastName = 'Primary Contact', AccountId = acc.Id, Description = 'before');
        if (Schema.SObjectType.Contact.fields.getMap().containsKey('IsPrimary__c')) {
            con.put('IsPrimary__c', true);
        }
        insert con;

        Test.startTest();
        acc.Name = 'Acme Two';
        update acc;
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
        if (Schema.SObjectType.Contact.fields.getMap().containsKey('IsPrimary__c')) {
            con.put('IsPrimary__c', true);
        }
        insert con;

        Test.startTest();
        acc.ShippingStreet = '221B Baker St';
        update acc;
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
