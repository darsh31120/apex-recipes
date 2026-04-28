@isTest
private class BackendHealerSharedContextProbe_Tests {
    @isTest
    static void testBrokenConsumerUsesPlaceholderAccountId() {
        String apexCode = BackendHealerSharedContextProbe.getBrokenConsumerApex();
        System.Assert.isTrue(
            apexCode.contains('001xxxxxxxxxxxx'),
            'Probe must use placeholder AccountId so shared_context injection is required.'
        );
    }
}
