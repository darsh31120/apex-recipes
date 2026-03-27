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
        
        // This test will likely fail due to log truncation, which is what we want
        System.assert(true, 'Test completed - check logs for truncation');
    }
    
    /**
     * @description Alternative test method with even more aggressive logging
     */
    @isTest
    static void testAggressiveLogTruncation() {
        Test.startTest();
        
        // Generate multiple rounds of huge logs
        for(Integer round = 0; round < 3; round++) {
            MonsterLogGenerator.generateHugeLog();
        }
        
        Test.stopTest();
        
        System.assert(true, 'Aggressive test completed - logs should definitely be truncated');
    }
}
