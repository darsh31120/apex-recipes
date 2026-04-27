@isTest
private class BackendHealerMissingRequiredProbe_Tests {
    @isTest
    static void testBrokenPayloadOmitsAwsRegion() {
        String payload = BackendHealerMissingRequiredProbe.getBrokenPayload();
        System.Assert.isFalse(
            payload.contains('AWS_Region__c'),
            'Probe payload must omit AWS_Region__c to trigger REQUIRED_FIELD_MISSING.'
        );
    }
}
