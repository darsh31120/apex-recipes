@isTest(isParallel=true)
private class KamikazeBackendSmoke_Tests {
    @isTest
    static void testAddTwoNumbers() {
        System.Assert.areEqual(
            7,
            KamikazeBackendSmoke.addTwoNumbers(3, 4),
            'Expected sum for non-null values'
        );
        System.Assert.areEqual(
            5,
            KamikazeBackendSmoke.addTwoNumbers(null, 5),
            'Expected null values to be treated as zero'
        );
    }
}
