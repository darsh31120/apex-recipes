public with sharing class BackendHealerSharedContextProbe {
    public static String getSeedApex() {
        return 'Account a = new Account(Name = \'SharedContextParent\'); insert a; System.debug(\'NEW_ACCOUNT_ID=\' + a.Id);';
    }

    public static String getBrokenConsumerApex() {
        // Placeholder Account Id intentionally invalid so healer must inject shared_context value.
        return 'Contact c = new Contact(LastName = \'SharedContextChild\', AccountId = \'001xxxxxxxxxxxx\'); insert c;';
    }
}
