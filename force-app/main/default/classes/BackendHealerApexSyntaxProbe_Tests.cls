@isTest
private class BackendHealerApexSyntaxProbe_Tests {
    @isTest
    static void testBrokenApexContainsStringIntegerMismatch() {
        String apexCode = BackendHealerApexSyntaxProbe.getBrokenApex();
        System.Assert.isTrue(
            apexCode.contains('NumberOfEmployees = \'Five\''),
            'Probe must keep intentional String-to-Integer mismatch.'
        );
    }
}
