@isTest
private class BackendHealerGovernorLimitProbe_Tests {
    @isTest
    static void testCpuLimitProbePayloadLooksCorrect() {
        String apexCode = BackendHealerGovernorLimitProbe.getCpuLimitApex();
        System.Assert.isTrue(
            apexCode.contains('100000000'),
            'Probe should contain a large loop bound to trigger CPU limit.'
        );
    }
}
