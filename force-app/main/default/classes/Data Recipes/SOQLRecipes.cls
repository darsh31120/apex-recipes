/**
 * @description Demonstrates how to make various types of SOQL calls
 * including multi-object queries, and aggregate queries
 * @group Data Recipes
 */
public with sharing class SOQLRecipes {
    /**
     * @description Demonstrates the proper way to query accounts with SOQL
     *   keeping FLS and CRUD in account.
     *
     * @example
     * ```
     * List<Account> results = SOQLRecipes.querySingleObject();
     * System.debug(results);
     * ```
     */
    public static List<Account> getRecords() {
        List<Account> accounts = new List<Account>();
        accounts = [
            SELECT Name, ShippingStreet, ShippingCity
            FROM Account
            WITH USER_MODE
        ];
        return accounts;
    }

    /**
     * @description Demonstrates how to loop over a SOQL query
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getLargeNumberOfRecords());
     * ```
     */
    public static Integer getLargeNumberOfRecords() {
        Integer count = 0;
        /**
         * You'll see this pattern, called a SQOL for loop used
         * whenever you're iterating over a massive number of rows.
         * Doing a SOQL for loop like this helps you avoid hitting
         * Heap limits.
         */

        for (Account acct : [SELECT Name FROM Account WITH USER_MODE]) {
            count++;
        }
        return count;
    }

    /**
     * @description One of the little known features of SOQL for loops is that
     * you can iterate not only over each record returned by the query, but also
     * over each *chunk of records*. As the code below demonstrates, specifying
     * the iteration variable as a list/array will return 200 record chunks
     * from the query, rather than individual records.
     *
     * Note: Normally, if you're only dealing with counts of records, you'd
     * utilize the Count() soql method, but in this case we're demonstrating
     * that this form of a soql for loop gives you access both to a list of
     * records, and to the records themselves.
     */
    public static Integer[] getChunksOfLargeNumbersOfRecords() {
        Integer countOfChunks = 0;
        Integer recordCount = 0;

        for (List<Account> accounts : [
            SELECT Name
            FROM Account
            WITH USER_MODE
        ]) {
            countOfChunks += 1;
            recordCount += accounts.size();
        }
        return new List<Integer>{ countOfChunks, recordCount };
    }

    /**
     * @description Demonstrates how to use a WHERE clause in a SOQL query
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getRecordsByFieldValue());
     * ```
     */
    public static List<Account> getRecordsByFieldValue() {
        return [
            SELECT Name
            FROM Account
            WHERE ShippingCountry = 'UK'
            WITH USER_MODE
        ];
    }

    /**
     * @description Demonstrates how to use a complex WHERE clause in a SOQL
     * query
     * @example
     * ```
     * System.debug(SOQLRecipes.getRecordsByMultipleFieldValues());
     * ```
     */
    public static List<Account> getRecordsByMultipleFieldValues() {
        return [
            SELECT Name
            FROM Account
            WHERE
                ShippingCountry = 'US'
                AND ShippingState = 'IN'
                AND (Industry = 'Fast Food - made whole'
                OR Industry = 'Slow Food - Made quickly')
            WITH USER_MODE
        ];
    }

    /**
     * @description Demonstrates how to use the LIMIT clause in a SOQL statement
     * @example
     * ```
     * System.debug(SOQLRecipes.getSpecificNumberOfRecords());
     * ```
     */
    public static List<Account> getSpecificNumberOfRecords() {
        //LIMIT clause
        return [
            SELECT Name
            FROM Account
            WITH USER_MODE
            ORDER BY Industry DESC
            LIMIT 10
        ];
    }

    /**
     * @description Demonstrates how to use a bound variable to define the LIMIT
     * @param wantedNumberOfRows the number of rows desired
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getFirstXRecords(5));
     * ```
     */
    public static List<Account> getFirstXRecords(Integer wantedNumberOfRows) {
        return [
            SELECT Name
            FROM Account
            WITH USER_MODE
            ORDER BY Industry DESC
            LIMIT :wantedNumberOfRows
        ];
    }

    /**
     * @description Demonstrates how to use a bound variable in a WHERE clause
     * @param state String representing a US State code (AK, KS, etc.)
     * @example
     * ```
     * System.debug(SOQLRecipes.getAccountRecordsInState('ks'));
     * ```
     */
    public static List<Account> getAccountRecordsInState(String state) {
        return [
            SELECT Name
            FROM Account
            WHERE ShippingState = :state
            WITH USER_MODE
        ];
    }

    /**
     * @description Demonstrates how to get a limited number of results with a
     * given offset; Ie: get the second set of 10 records.
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getSecond10AccountRecords());
     * ```
     */
    public static List<Account> getSecond10AccountRecords() {
        return [
            SELECT Id
            FROM Account
            WITH USER_MODE
            ORDER BY Industry DESC
            LIMIT 10
            OFFSET 10
        ];
    }

    /**
     * @description Demonstrates how to query an object, as well as it's related
     * child objects
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getRecordsWithRelatedRecords());
     * ```
     */
    public static List<Account> getRecordsWithRelatedRecords() {
        return [
            SELECT Name, (SELECT Name, AccountId FROM Contacts)
            FROM Account
            WITH USER_MODE
        ];
    }

    /**
     * @description Demonstrates how to query fields from a parent object
     * through the relationship field
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getParentRecordDetailsFromChildRecord());
     * ```
     */
    public static List<Contact> getParentRecordDetailsFromChildRecord() {
        return [
            SELECT Id, Name, Email, Account.Name, Account.ShippingState
            FROM Contact
            WHERE Account.ShippingState = 'KS'
            WITH USER_MODE
        ];
    }

    /**
     * @description Demonstrates how to write a query that pulls information
     * from two parent objects through a junction object
     *
     * @example
     * ```
     * System.debug(SOQLRecipes.getDetailsFromBothParentRecords());
     * ```
     */
    public static List<Junction__c> getDetailsFromBothParentRecords() {
        return [
            SELECT Id, parent1__r.Name, Parent2__r.Name
            FROM Junction__c
            WITH USER_MODE
        ];
    }

    /**
     * @description demonstrates how to use aggregate methods, like Sum() or
     * Count() in a SOQL query. This example generates the sum of opportunities
     * associated with a specified Account
     *
     * @param accountId an AccountId
     * @example
     * ```
     * Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
     * System.debug(SOQLRecipes.getSumOfOpportunityRecords(accountId));
     * ```
     */
    public static Double getSumOfOpportunityRecords(Id accountId) {
        List<AggregateResult> groupedResults = [
            SELECT SUM(Amount) total
            FROM Opportunity
            WHERE AccountId = :accountId
            WITH USER_MODE
        ];
        return (Double) groupedResults[0].get('total');
    }

    /**
     * @description Demonstrates multiple SOQL queries that could exceed limits
     * This method intentionally performs multiple queries in a loop to show
     * how query limits can be exceeded
     * @param numberOfQueries Number of iterations to perform
     * @return List of account counts found
     */
    public static List<Integer> demonstrateQueryLimitExceeded(Integer numberOfQueries) {
        List<Integer> counts = new List<Integer>();
        
        // Query 1: Basic account query in loop
        for(Integer i = 0; i < numberOfQueries; i++) {
            List<Account> accounts = [
                SELECT Id, Name, Industry
                FROM Account 
                WHERE Industry = 'Technology'
                LIMIT 10
            ];
            counts.add(accounts.size());
        }
        
        // Query 2: Contact queries in loop
        for(Integer i = 0; i < numberOfQueries; i++) {
            List<Contact> contacts = [
                SELECT Id, Name, Email
                FROM Contact 
                WHERE Email != null
                LIMIT 5
            ];
            counts.add(contacts.size());
        }
        
        // Query 3: Opportunity queries in loop
        for(Integer i = 0; i < numberOfQueries; i++) {
            List<Opportunity> opps = [
                SELECT Id, Name, Amount
                FROM Opportunity 
                WHERE Amount > 1000
                LIMIT 5
            ];
            counts.add(opps.size());
        }
        
        return counts;
    }

    /**
     * @description Demonstrates complex relationship queries that can be expensive
     * @return Map of account to related records count
     */
    public static Map<Id, Integer> demonstrateExpensiveRelationshipQueries() {
        Map<Id, Integer> accountRecordCounts = new Map<Id, Integer>();
        
        // Expensive relationship query with multiple subqueries
        List<Account> accountsWithEverything = [
            SELECT Id, Name,
                   (SELECT Id, Name FROM Contacts),
                   (SELECT Id, Name, Amount FROM Opportunities),
                   (SELECT Id, Subject FROM Tasks),
                   (SELECT Id, Subject FROM Events),
                   (SELECT Id, CaseNumber FROM Cases)
            FROM Account 
            WHERE Industry != null
            LIMIT 50
        ];
        
        for(Account acct : accountsWithEverything) {
            Integer totalRelated = acct.Contacts.size() + acct.Opportunities.size() + 
                                 acct.Tasks.size() + acct.Events.size() + acct.Cases.size();
            accountRecordCounts.put(acct.Id, totalRelated);
        }
        
        // Additional expensive queries for each account found
        for(Id accountId : accountRecordCounts.keySet()) {
            // Query each account's related leads
            List<Lead> relatedLeads = [
                SELECT Id, Company, Status
                FROM Lead 
                WHERE Company = :accountId
                LIMIT 10
            ];
            accountRecordCounts.put(accountId, accountRecordCounts.get(accountId) + relatedLeads.size());
        }
        
        return accountRecordCounts;
    }

    /**
     * @description Demonstrates aggregate queries that can be resource intensive
     * @return List of aggregate results
     */
    public static List<AggregateResult> demonstrateExpensiveAggregateQueries() {
        List<AggregateResult> results = new List<AggregateResult>();
        
        // Multiple aggregate queries
        AggregateResult[] acctByIndustry = [
            SELECT Industry, COUNT(Id) acctCount, AVG(AnnualRevenue) avgRevenue
            FROM Account 
            WHERE Industry != null
            GROUP BY Industry
            ORDER BY COUNT(Id) DESC
        ];
        results.addAll(acctByIndustry);
        
        AggregateResult[] oppByStage = [
            SELECT StageName, COUNT(Id) stageCount, SUM(Amount) totalAmount
            FROM Opportunity 
            GROUP BY StageName
            ORDER BY SUM(Amount) DESC
        ];
        results.addAll(oppByStage);
        
        AggregateResult[] contactsByAccount = [
            SELECT AccountId, COUNT(Id) contactCount
            FROM Contact 
            WHERE AccountId != null
            GROUP BY AccountId
            HAVING COUNT(Id) > 5
        ];
        results.addAll(contactsByAccount);
        
        return results;
    }
}
