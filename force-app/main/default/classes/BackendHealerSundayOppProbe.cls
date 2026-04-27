public with sharing class BackendHealerSundayOppProbe {
    public static String getEndpoint() {
        return '/services/data/v60.0/sobjects/Opportunity';
    }

    public static String getMethod() {
        return 'POST';
    }

    public static String getBlockedPayload() {
        return '{"Name":"Sunday Opportunity Blocker","StageName":"Prospecting","CloseDate":"2026-12-31"}';
    }
}
