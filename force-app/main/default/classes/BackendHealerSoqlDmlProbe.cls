public with sharing class BackendHealerSoqlDmlProbe {
    public static String getDestructiveQuery() {
        return 'DELETE [SELECT Id FROM Account]';
    }
}
