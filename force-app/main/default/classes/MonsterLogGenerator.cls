public class MonsterLogGenerator {
    public static void generateHugeLog() {
        // Unique version string to force deployment
        System.debug('LOG_TRUNCATION_FINAL_TEST_V5'); 

        // 5,000 characters per line
        String bloat = 'X'.repeat(5000); 

        // 6,000 iterations = 30,000,000 chars (30 MB)
        // This is guaranteed to blow past the 20.9 MB limit
        for(Integer i = 0; i < 6000; i++) {
            // Using ERROR level so the SFGuardianV3 'INFO' filter doesn't block it
            System.debug(LoggingLevel.ERROR, 'LOOP_' + i + ': ' + bloat);
        }
    }
}