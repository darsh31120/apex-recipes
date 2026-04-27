@isTest
private class BackendHealerDestructiveApexProbe_Tests {
    @isTest
    static void testDestructiveApexContainsBlockedOperations() {
        String apexCode = BackendHealerDestructiveApexProbe.getDestructiveApex();
        System.Assert.isTrue(
            apexCode.contains('Database.emptyRecycleBin') && apexCode.contains('delete cs'),
            'Probe Apex must include destructive operations for security guardrail validation.'
        );
    }
}
