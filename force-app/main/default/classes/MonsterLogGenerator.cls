public class MonsterLogGenerator {
    public static void generateHugeLog() {
        // 5000 chars * 4500 iterations = ~22.5MB
        String bloat = 'X'.repeat(5000);

        for(Integer i = 0; i < 4500; i++) {
            // Changed from FINEST to ERROR so it bypasses the SFGuardianV3 'INFO' filter
            System.debug(LoggingLevel.ERROR, bloat);
        }
    }
}