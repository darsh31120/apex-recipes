public with sharing class BackendHealerDestructiveApexProbe {
    public static String getDestructiveApex() {
        return 'List<Contact> cs = [SELECT Id FROM Contact LIMIT 1]; Database.emptyRecycleBin(cs); delete cs;';
    }
}
