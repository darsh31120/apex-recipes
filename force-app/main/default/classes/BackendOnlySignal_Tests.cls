@isTest(isParallel=true)
private class BackendOnlySignal_Tests {
    @isTest
    static void testRunMarker() {
        System.Assert.areEqual(
            'backend-only-signal',
            BackendOnlySignal.getRunMarker(),
            'Expected backend-only marker text'
        );
    }
}
