public with sharing class BackendHealerE2EProbe {
    public static String getSafeAccountSeedName() {
        return 'Healer Smoke Account';
    }

    public static String getForbiddenAccountSeedName() {
        // Intentionally mirrors the org validation phrase so generated scripts
        // can be diagnosed/healed during backend-only Kamikaze runs.
        return 'Test Healer Challenge Account';
    }
}
