@isTest(isParallel=true)
private class BackendHealerProbe_Tests {
    @isTest
    static void testGetProbeLabel() {
        System.Assert.areEqual(
            'Healer Probe',
            BackendHealerProbe.getProbeLabel(null),
            'Expected default label prefix'
        );
        System.Assert.areEqual(
            'Smoke Probe',
            BackendHealerProbe.getProbeLabel('  Smoke  '),
            'Expected trimmed prefix in output'
        );
    }
}
