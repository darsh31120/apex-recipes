public with sharing class MonsterPayloadRecipe {
    @AuraEnabled
    public static void generateMassiveLogs() {
        // Loop 50,000 times to easily exceed the Salesforce Log Size Limit
        // and trigger the "*** MAXIMUM DEBUG LOG SIZE REACHED ***" truncation warning.
        for (Integer i = 0; i < 50000; i++) {
            System.debug(LoggingLevel.FINEST, 'MONSTER PAYLOAD SPAM ROW: ' + i + 
                ' - PADDING TO INCREASE BYTE SIZE PADDING PADDING PADDING PADDING ' + 
                'PADDING PADDING PADDING PADDING PADDING PADDING PADDING PADDING');
        }
        
        // Do a harmless DML so Jataka thinks something functional happened
        Account a = new Account(Name = 'Jataka Monster Test ' + System.currentTimeMillis());
        insert a;
    }
}
