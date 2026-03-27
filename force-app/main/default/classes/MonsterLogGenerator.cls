public class MonsterLogGenerator {
    public static void generateHugeLog() {
        String bloat = 'X'.repeat(5000);

        for(Integer i = 0; i < 4300; i++) {
            System.debug(LoggingLevel.FINEST, bloat);
        }
    }
}
