public class MonsterLogGenerator {
    public static void generateHugeLog() {
        // ADDING THIS TO BREAK THE CACHE
        System.debug('Forcing Salesforce to accept this new version!'); 
        
        String bloat = 'X'.repeat(5000);
        for(Integer i = 0; i < 12000; i++) {
            System.debug(LoggingLevel.ERROR, bloat);
        }
    }
}