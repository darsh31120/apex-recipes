/**
 * @description Demonstrates the use of the Database.Batchable interface. The
 * methods in this class are called by the system as the batch executes.
 * To execute this batch use `Database.executeBatch(new BatchApexRecipes());`
 *
 * More on the Batchable interface:
 * https://sfdc.co/batch_interface
 *
 * @group Async Apex Recipes
 */
public with sharing class BatchApexRecipes implements Database.Batchable<SObject>, Database.Stateful {
    // These next two lists hold the ids of sucessful and failed updates.
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    // A constant representing the initial query to run.
    // This is used in the start() method.
    private final String queryString = 'SELECT Id, Name FROM Account';

    // Having a static variable here, let's us test the output of the Finish
    // method below
    @testVisible
    private static String result = '';
    // This allows us to cause a DML failure in execute batch, enabling testing.
    @testVisible
    private Boolean throwError = false;

    /**
     * @description This method is required by the Batchable interface.
     * It's responsible for identifying the records that will be affected
     * Your start method can either return a QueryLocator or an Iterable
     * (List) The records identified here will be made available to the
     * execute method below, in batches of up to 200 records at a time.
     * @param context dependency injected by the system
     * @return QueryLocator object used for context
     * @example
     * ```
     * Database.executeBatch(new BatchApexRecipes());
     * ```
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(queryString);
    }

    /**
     * @description This method is where the actual work occurs. It's run once
     * per batch.
     * @param context dependency injected by the system in this batch. It's this
     * mechanism of breaking a large number of records into smaller batches
     * called scope (in this example) that make this easier.
     * @param scope a list of up to 200 SObject records to be processed
     * @example
     * ```
     * Database.executeBatch(new BatchApexRecipes());
     * ```
     */
    public void execute(
        Database.BatchableContext context,
        List<Account> scope
    ) {
        // Batch Processing
        for (Account acct : scope) {
            acct.Name += ' Edited by Batch class';

            /**
             * This is an example of a circuit breaker pattern. It's not
             * something I routinely recommend, but it has it's uses. Here we're
             * using it to intentionally cause the save result to fail in a way
             * that will provide us actual DML error messages. Flipping the
             * breaker, allows us to test the finish() method of this batch
             * class and illustrate how it works.
             */
            if (this.throwError) {
                acct.Name = null;
            }
        }
        
        // Add expensive SOQL queries that could exceed limits
        performExpensiveQueries(scope);
        
        /**
         * it's useful to use the Database.* methods inside Batch classes to
         * separate succeses and failures. But the tracking of these across many
         * scopes is only possible when your batch class also extends
         * Database.stateful. Without implementing Database.Stateful the
         * successes and failures class variables would be *reset* for every
         * batch.
         */
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        saveResults = Database.update(scope, false);
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                // Only available *across* scope executions because of
                // Database.stateful
                successes.add(sr.id);
            } else {
                // Only available *across* scope executions because of
                // Database.stateful
                failures.add(sr.id);
            }
        }
    }
    
    /**
     * @description Performs expensive SOQL queries that could exceed limits
     * @param scope List of accounts to query related data for
     */
    private void performExpensiveQueries(List<Account> scope) {
        // Query 1: For each account, query related contacts
        for(Account acct : scope) {
            List<Contact> contacts = [
                SELECT Id, Name, Email, Phone
                FROM Contact 
                WHERE AccountId = :acct.Id
                LIMIT 10
            ];
            System.debug('Account ' + acct.Name + ' has ' + contacts.size() + ' contacts');
        }
        
        // Query 2: For each account, query related opportunities
        for(Account acct : scope) {
            List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, StageName, CloseDate
                FROM Opportunity 
                WHERE AccountId = :acct.Id
                ORDER BY Amount DESC
                LIMIT 5
            ];
            System.debug('Account ' + acct.Name + ' has ' + opportunities.size() + ' opportunities');
        }
        
        // Query 3: For each account, query related cases
        for(Account acct : scope) {
            List<Case> cases = [
                SELECT Id, CaseNumber, Status, Origin
                FROM Case 
                WHERE AccountId = :acct.Id
                AND Status != 'Closed'
                LIMIT 5
            ];
            System.debug('Account ' + acct.Name + ' has ' + cases.size() + ' open cases');
        }
        
        // Query 4: Complex relationship query with multiple subqueries
        Set<Id> accountIds = new Set<Id>();
        for(Account acct : scope) {
            accountIds.add(acct.Id);
        }
        
        List<Account> accountsWithAllRelationships = [
            SELECT Id, Name,
                   (SELECT Id, Name, Email FROM Contacts),
                   (SELECT Id, Name, Amount FROM Opportunities),
                   (SELECT Id, Subject, Status FROM Tasks),
                   (SELECT Id, Subject FROM Events),
                   (SELECT Id, CaseNumber, Status FROM Cases)
            FROM Account 
            WHERE Id IN :accountIds
        ];
        
        // Query 5: Aggregate queries for each account
        for(Account acct : scope) {
            AggregateResult[] contactStats = [
                SELECT COUNT(Id) contactCount
                FROM Contact 
                WHERE AccountId = :acct.Id
            ];
            
            AggregateResult[] oppStats = [
                SELECT COUNT(Id) oppCount, SUM(Amount) totalAmount
                FROM Opportunity 
                WHERE AccountId = :acct.Id
            ];
            
            System.debug('Account ' + acct.Name + ' stats - Contacts: ' + 
                        contactStats[0].get('contactCount') + 
                        ', Opps: ' + oppStats[0].get('oppCount'));
        }
        
        // Query 6: Additional expensive queries in loops
        for(Integer i = 0; i < 5; i++) {
            List<Account> allAccounts = [
                SELECT Id, Name, Industry, AnnualRevenue
                FROM Account 
                WHERE Industry = 'Technology'
                LIMIT 20
            ];
            System.debug('Query iteration ' + i + ' found ' + allAccounts.size() + ' tech accounts');
        }
    }

    /**
     * @description This method is called by the system when all the individual
     * batches have completed. Intrepid developers may send emails, or otherwise
     * notify others of the job's completion here.
     * @param context dependency injected by the system
     * @example
     * ```
     * Database.executeBatch(new BatchApexRecipes());
     * ```
     */
    public void finish(Database.BatchableContext context) {
        BatchApexRecipes.result =
            'Successes: ' +
            successes.size() +
            ' Failures: ' +
            failures.size();
    }
}
