@isTest
private class AccountTriggerHandler_Test {
    
    /***************************************
     * Test DOMINO PUSH 1: createRelatedChildAccounts
     ***************************************/
    
    /**
     * @description Tests JATAKA BLOCKER for Evidence-Based Gate testing
     */
    @isTest
    static void testJatakaBlocker() {
        Account blockedAccount = new Account(
            Name = 'Architect Test Account - Trigger Verification'
        );
        
        Test.startTest();
        try {
            insert blockedAccount;
            System.assert(false, 'Expected JATAKA BLOCKER to prevent account creation');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('JATAKA BLOCKER: You cannot create an account with this test name!'), 
                         'Should catch JATAKA BLOCKER error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests the afterInsert logic that creates child accounts
     */
    @isTest
    static void testCreateRelatedChildAccounts() {
        Account testAccount = new Account(
            Name = 'Test Parent Account'
        );
        
        Test.startTest();
        insert testAccount;
        Test.stopTest();
        
        // Verify child account was created
        List<Account> childAccounts = [
            SELECT Name, ParentId 
            FROM Account 
            WHERE ParentId = :testAccount.Id
        ];
        
        System.assertEquals(1, childAccounts.size(), 'Should create exactly 1 child account');
        System.assertEquals('Test Parent Account - Regional Branch', childAccounts[0].Name, 'Child account name should match pattern');
        System.assertEquals(testAccount.Id, childAccounts[0].ParentId, 'Child should reference parent');
    }
    
    /**
     * @description Tests that child accounts are not created for existing child accounts
     */
    @isTest
    static void testNoChildAccountForExistingChildren() {
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;
        
        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccount.Id
        );
        
        Test.startTest();
        insert childAccount;
        Test.stopTest();
        
        // Verify no grandchild was created
        List<Account> grandChildren = [
            SELECT Name, ParentId 
            FROM Account 
            WHERE ParentId = :childAccount.Id
        ];
        
        System.assertEquals(0, grandChildren.size(), 'Should not create children for existing child accounts');
    }
    
    /**
     * @description Tests performance issues with SOQL queries in loops
     */
    @isTest
    static void testPerformanceIssues() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {  // Keep small to avoid governor limits in test
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        
        Test.startTest();
        insert accounts;
        Test.stopTest();
        
        // Should create 3 child accounts
        List<Account> childAccounts = [
            SELECT Name, ParentId 
            FROM Account 
            WHERE ParentId IN :accounts
        ];
        
        System.assertEquals(3, childAccounts.size(), 'Should create children for all parent accounts');
    }
    
    /***************************************
     * Test DOMINO PUSH 2: validateAndUpdateAccounts
     ***************************************/
    
    /**
     * @description Tests the beforeUpdate logic with industry change validation
     */
    @isTest
    static void testIndustryChangeValidation() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;
        
        // Create some won opportunities
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            opps.add(new Opportunity(
                Name = 'Test Opp ' + i,
                AccountId = testAccount.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Amount = 1000
            ));
        }
        insert opps;
        
        Test.startTest();
        testAccount.Industry = 'Finance';
        update testAccount;
        Test.stopTest();
        
        // Should succeed (less than 5 won opportunities)
        Account updatedAccount = [
            SELECT Industry, Description 
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        System.assertEquals('Finance', updatedAccount.Industry, 'Industry should be updated');
        System.assert(updatedAccount.Description.contains('Previous Industry: Technology'), 'Should track previous industry');
    }
    
    /**
     * @description Tests high value account processing
     */
    @isTest
    static void testHighValueAccountProcessing() {
        Account testAccount = new Account(
            Name = 'High Value Account',
            AnnualRevenue = 2000000,
            Industry = 'Technology'
        );
        insert testAccount;
        
        Test.startTest();
        testAccount.Industry = 'Finance';  // Trigger update logic
        update testAccount;
        Test.stopTest();
        
        // Verify account was updated with high value indicators
        Account updatedAccount = [
            SELECT Rating, CustomerPriority__c, Description 
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        System.assertEquals('Hot', updatedAccount.Rating, 'High value accounts should be marked as Hot');
        System.assertEquals('High', updatedAccount.CustomerPriority__c, 'Should set high priority');
        System.assert(updatedAccount.Description.contains('Last processed:'), 'Should track processing timestamp');
        
        // Verify follow-up task was created
        List<Task> tasks = [
            SELECT Subject, Priority, ActivityDate 
            FROM Task 
            WHERE WhatId = :testAccount.Id
        ];
        
        System.assertEquals(1, tasks.size(), 'Should create follow-up task');
        System.assertEquals('High', tasks[0].Priority, 'Task should be high priority');
        System.assert(tasks[0].Subject.contains('High Value Account Updated'), 'Task subject should be relevant');
    }
    
    /**
     * @description Tests validation rule blocking (for Evidence-Based Gate)
     */
    @isTest
    static void testValidationRuleBlock() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '555-0199'  // This will trigger the validation rule if it exists
        );
        
        Test.startTest();
        try {
            insert testAccount;
            System.assert(false, 'Expected validation rule to fire');
        } catch (DmlException e) {
            // This is expected if validation rule exists
            System.assert(e.getMessage().contains('Test Phone Numbers are not allowed') || 
                         e.getMessage().contains('INVALID_PHONE_NUMBER'), 
                         'Should catch validation rule error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests recursion prevention with circuit breaker
     */
    @isTest
    static void testRecursionPrevention() {
        AccountTriggerHandler.circuitBreaker = new DmlException('Test circuit breaker');
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Test.startTest();
        testAccount.Name = 'Updated Name';
        try {
            update testAccount;
            System.assert(false, 'Expected circuit breaker to prevent update');
        } catch (AccountTriggerHandler.AccountTriggerHandlerException e) {
            System.assert(e.getMessage().contains('Failed to insert tasks'), 'Should catch circuit breaker exception');
        }
        Test.stopTest();
        
        AccountTriggerHandler.circuitBreaker = null;
    }
    
    /***************************************
     * Test Integration Scenarios
     ***************************************/
    
    /**
     * @description Tests the complete domino effect scenario
     */
    @isTest
    static void testCompleteDominoEffect() {
        // Create parent account
        Account parentAccount = new Account(
            Name = 'Parent Account',
            AnnualRevenue = 1500000,
            Industry = 'Technology'
        );
        
        Test.startTest();
        insert parentAccount;  // Triggers afterInsert -> creates child account
        
        // Update parent account to trigger beforeUpdate logic
        parentAccount.Industry = 'Healthcare';
        update parentAccount;  // Triggers beforeUpdate -> validation and task creation
        Test.stopTest();
        
        // Verify complete cascade
        List<Account> childAccounts = [
            SELECT Name, ParentId 
            FROM Account 
            WHERE ParentId = :parentAccount.Id
        ];
        
        System.assertEquals(1, childAccounts.size(), 'Should have created child account');
        
        List<Task> tasks = [
            SELECT Subject, Priority 
            FROM Task 
            WHERE WhatId = :parentAccount.Id
        ];
        
        System.assertEquals(1, tasks.size(), 'Should have created follow-up task');
        
        Account updatedParent = [
            SELECT Rating, CustomerPriority__c, Description 
            FROM Account 
            WHERE Id = :parentAccount.Id
        ];
        
        System.assertEquals('Hot', updatedParent.Rating, 'Should be marked as hot');
        System.assert(updatedParent.Description.contains('Previous Industry: Technology'), 'Should track industry change');
    }
    
    /**
     * @description Tests bulk operations with mixed scenarios
     */
    @isTest
    static void testBulkOperations() {
        List<Account> accounts = new List<Account>();
        
        // Mix of high value and regular accounts
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Account ' + i,
                AnnualRevenue = i < 2 ? 2000000 : 500000,  // First 2 are high value
                Industry = 'Technology'
            ));
        }
        
        Test.startTest();
        insert accounts;  // Should create child accounts for all
        
        // Update all accounts to trigger beforeUpdate logic
        for (Account acc : accounts) {
            acc.Industry = 'Finance';
        }
        update accounts;
        Test.stopTest();
        
        // Verify child accounts created
        List<Account> childAccounts = [
            SELECT Name, ParentId 
            FROM Account 
            WHERE ParentId IN :accounts
        ];
        
        System.assertEquals(5, childAccounts.size(), 'Should create child for each parent');
        
        // Verify high value accounts got special treatment
        List<Account> highValueAccounts = [
            SELECT Rating, CustomerPriority__c 
            FROM Account 
            WHERE Id IN :accounts AND AnnualRevenue > 1000000
        ];
        
        for (Account acc : highValueAccounts) {
            System.assertEquals('Hot', acc.Rating, 'High value should be marked hot');
            System.assertEquals('High', acc.CustomerPriority__c, 'Should have high priority');
        }
        
        // Verify tasks created for high value accounts only
        List<Task> tasks = [
            SELECT WhatId, Subject 
            FROM Task 
            WHERE WhatId IN :accounts
        ];
        
        System.assertEquals(2, tasks.size(), 'Should create tasks only for high value accounts');
    }
}
