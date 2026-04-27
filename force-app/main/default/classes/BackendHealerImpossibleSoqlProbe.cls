public with sharing class BackendHealerImpossibleSoqlProbe {
    public static String getImpossibleQuery() {
        return 'SELECT Id FROM Imaginary_Object_Does_Not_Exist__c LIMIT 1';
    }
}
