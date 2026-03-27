public class MonsterLogGenerator {
    public static void generateHugeLog() {
        // Generates ~30MB of debug statements
        String bloat = 'X'.repeat(10000); 
        for(Integer i = 0; i < 3002; i++) {
            System.debug(LoggingLevel.FINEST, 'BLOAT_LOG: ' + bloat);
        }
    }
}
