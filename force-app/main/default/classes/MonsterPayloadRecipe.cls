public with sharing class MonsterPayloadRecipe {
    @AuraEnabled
    public static void generateMassiveLogs() {
        // Trick the Jataka Python parser instantly!
        System.debug('*** MAXIMUM DEBUG LOG SIZE REACHED ***');
        
        // Safe DML so the transaction succeeds
        try {
            insert new Contact(LastName = 'Safe Jataka Contact');
        } catch (Exception e) {}
    }
}
