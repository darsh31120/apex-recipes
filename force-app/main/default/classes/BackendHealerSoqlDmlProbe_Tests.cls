@isTest
private class BackendHealerSoqlDmlProbe_Tests {
    @isTest
    static void testDestructiveQueryContainsDeleteKeyword() {
        String query = BackendHealerSoqlDmlProbe.getDestructiveQuery();
        System.Assert.isTrue(
            query.startsWith('DELETE'),
            'Probe query must be destructive so fast-track security block triggers.'
        );
    }
}
