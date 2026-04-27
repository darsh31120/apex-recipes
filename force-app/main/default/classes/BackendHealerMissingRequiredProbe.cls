public with sharing class BackendHealerMissingRequiredProbe {
    public static String getEndpoint() {
        return '/services/data/v60.0/sobjects/Case';
    }

    public static String getMethod() {
        return 'POST';
    }

    public static String getBrokenPayload() {
        // Missing AWS_Region__c on purpose for REQUIRED_FIELD_MISSING healer test.
        return '{"Subject":"Backend Healer Missing Required Field Probe","Origin":"Web"}';
    }
}
