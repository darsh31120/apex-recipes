@isTest
private class BackendHealerImpossibleSoqlProbe_Tests {
    @isTest
    static void testImpossibleQueryTargetsMissingObject() {
        String query = BackendHealerImpossibleSoqlProbe.getImpossibleQuery();
        System.Assert.isTrue(
            query.contains('Imaginary_Object_Does_Not_Exist__c'),
            'Probe query must target a non-existent custom object to exhaust retries.'
        );
    }
}
