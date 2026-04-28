public with sharing class BackendHealerGovernorLimitProbe {
    public static String getCpuLimitApex() {
        return 'Long sum = 0; for (Integer i = 0; i < 100000000; i++) { sum += i; } System.debug(sum);';
    }
}
