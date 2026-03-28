@isTest
private class MonsterLogGenerator_Test {
    
    /**
     * @description Test method that will trigger log truncation
     * This test is designed to exceed Salesforce log limits (20MB)
     */
    @isTest
    static void testLogTruncationTrigger() {
        Test.startTest();
        
        // Call the monster log generator - this should trigger log truncation
        MonsterLogGenerator.generateHugeLog();
        
        Test.stopTest();
        
        System.assert(true, 'Test completed - check logs for truncation');
    }
}
