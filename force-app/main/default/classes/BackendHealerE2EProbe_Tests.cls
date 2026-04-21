@isTest(isParallel=true)
private class BackendHealerE2EProbe_Tests {
    @isTest
    static void testProbeSeedNames() {
        System.Assert.areEqual(
            'Healer Smoke Account',
            BackendHealerE2EProbe.getSafeAccountSeedName(),
            'Expected deterministic safe backend seed name'
        );
        System.Assert.isTrue(
            BackendHealerE2EProbe.getForbiddenAccountSeedName().contains('Test'),
            'Expected probe forbidden name to include Test marker'
        );
    }
}
