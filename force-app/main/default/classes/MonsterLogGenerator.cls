public class MonsterLogGenerator {
    public static void generateHugeLog() {
        // Generates ~50MB+ of debug statements to guarantee log truncation
        String bloat = 'X'.repeat(15000); 
        
        // Pattern 1: Massive string logging
        for(Integer i = 0; i < 5000; i++) {
            System.debug(LoggingLevel.FINEST, 'BLOAT_LOG_' + i + ': ' + bloat + ' ITERATION_' + i);
        }
        
        // Pattern 2: Object serialization logging
        for(Integer i = 0; i < 1000; i++) {
            Account mockAccount = new Account(
                Name = 'Mock Account ' + i + ' ' + bloat,
                Description = 'This is a very long description that contains ' + bloat + ' repeated text to increase log size ' + i,
                BillingStreet = '123 Very Long Street Name With Lots Of Characters ' + bloat,
                BillingCity = 'City With Extremely Long Name ' + bloat,
                BillingState = 'State With Ridiculously Long Name ' + bloat,
                BillingPostalCode = '1234567890' + bloat,
                BillingCountry = 'Country With Insanely Long Name That Contains Lots Of Text ' + bloat,
                Phone = '123-456-7890' + bloat,
                Website = 'https://very-long-website-name-with-lots-of-characters.com/' + bloat,
                Industry = 'Technology With Very Long Industry Name ' + bloat,
                AnnualRevenue = 1000000.0 + i
            );
            System.debug(LoggingLevel.INFO, 'MOCK_ACCOUNT_' + i + ': ' + JSON.serialize(mockAccount));
        }
        
        // Pattern 3: Exception stack traces
        for(Integer i = 0; i < 500; i++) {
            try {
                throw new DmlException('This is a test exception with lots of details: ' + bloat + ' ERROR_NUMBER_' + i);
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, 'EXCEPTION_' + i + ': ' + e.getStackTraceString() + ' MESSAGE: ' + e.getMessage() + ' EXTRA_DATA: ' + bloat);
            }
        }
        
        // Pattern 4: Collection logging
        List<String> massiveList = new List<String>();
        for(Integer i = 0; i < 2000; i++) {
            massiveList.add('Item_' + i + '_WITH_LOTS_OF_DATA_' + bloat);
        }
        System.debug(LoggingLevel.WARN, 'MASSIVE_LIST_SIZE: ' + massiveList.size() + ' CONTENTS: ' + String.join(massiveList, ','));
        
        // Pattern 5: Recursive method calls with logging
        recursiveLogGenerator(100, bloat);
        
        // Pattern 6: Final massive log entry
        System.debug(LoggingLevel.FINEST, 'FINAL_BULK_LOG: ' + bloat.repeat(100));
    }
    
    private static void recursiveLogGenerator(Integer depth, String bloat) {
        if(depth <= 0) return;
        
        System.debug(LoggingLevel.DEBUG, 'RECURSIVE_DEPTH_' + depth + ': ' + bloat);
        
        // Create more data at each level
        for(Integer i = 0; i < 50; i++) {
            System.debug(LoggingLevel.FINEST, 'DEPTH_' + depth + '_ITERATION_' + i + ': ' + bloat);
        }
        
        recursiveLogGenerator(depth - 1, bloat);
    }
}
