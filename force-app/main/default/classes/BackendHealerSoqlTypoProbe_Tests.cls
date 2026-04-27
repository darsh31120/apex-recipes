@isTest(isParallel=true)
private class BackendHealerSoqlTypoProbe_Tests {
    @isTest
    static void testBrokenQueryContainsIntentionalTypos() {
        String query = BackendHealerSoqlTypoProbe.getBrokenQuery();
        System.Assert.isTrue(
            query.contains('Idd') && query.contains('Nammme'),
            'Probe query must preserve intentional SOQL typos for healer validation.'
        );
    }
}
