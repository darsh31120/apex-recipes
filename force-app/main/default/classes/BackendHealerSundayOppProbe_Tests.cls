@isTest
private class BackendHealerSundayOppProbe_Tests {
    @isTest
    static void testBlockedPayloadIsOpportunityPostBody() {
        String payload = BackendHealerSundayOppProbe.getBlockedPayload();
        System.Assert.isTrue(
            payload.contains('StageName') && payload.contains('CloseDate'),
            'Probe payload should resemble an Opportunity create request.'
        );
    }
}
