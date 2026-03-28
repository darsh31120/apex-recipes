public class MonsterLogGenerator {
    public static void generateHugeLog() {
        // Change the string to be even bigger so we hit 20MB faster
        // 10,000 chars * 2,500 loops = 25MB (Safely over 20MB)
        String bloat = 'X'.repeat(10000); 

        for(Integer i = 0; i < 2500; i++) {
            // Use ERROR level to ensure it is captured
            System.debug(LoggingLevel.ERROR, 'TRUNCATE_TEST: ' + bloat);
        }
    }
}