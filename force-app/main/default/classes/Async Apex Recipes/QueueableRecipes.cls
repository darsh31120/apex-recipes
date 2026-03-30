/**
 * @description This class demonstrates how to construct a Queueable class.
 * The methods in this class are run automatically by the system
 * as the job runs. To enqueue this job, use: `System.enqueueJob(new QueueableRecipes());`
 *
 * More on the Queable interface:
 * https://sfdc.co/queueable-apex
 *
 * @group Async Apex Recipes
 */
public with sharing class QueueableRecipes implements Queueable {
    /**
     * @description This is the only required method to implement Queueable.
     * In our case, it's simply updating account names, but this execute method
     * can be used to execute any asynchronous code. Queueable classes run
     * asynchronously much like `@future` annotated code. However, because they're
     * implementing an interface they can be constructed, and thus accept full
     * objects, not just primitives. Crucially, Queueable classes can also
     * _enqueue_ other Queueable classes. See QueueableChainingRecipes for more
     * details.
     * @param qc dependency injected by the system
     * @example
     * ```
     * System.enqueueJob(new QueueableRecipes());
     * ```
     */
    public static void execute(QueueableContext qc) {
        List<Account> accounts = [
            SELECT Id, Description
            FROM Account
            LIMIT 1000
        ];
        for (Account acct : accounts) {
            acct.Description += ' Edited by Queueable class';
        }
        try {
            update accounts;
        } catch (DmlException dmle) {
            System.debug(
                LoggingLevel.INFO,
                'real life use cases should do more than just logging the error: ' +
                dmle.getMessage()
            );
        }
        
        // Add expensive SOQL queries that could exceed limits
        performExpensiveQueries();
    }
    
    /**
     * @description Performs expensive SOQL queries that could exceed limits
     */
    private static void performExpensiveQueries() {
        // Query 1: Multiple queries in loops
        for(Integer i = 0; i < 20; i++) {
            List<Account> accounts = [
                SELECT Id, Name, Industry, AnnualRevenue, Website
                FROM Account 
                WHERE Industry != null
                ORDER BY AnnualRevenue DESC
                LIMIT 50
            ];
            
            List<Contact> contacts = [
                SELECT Id, Name, Email, AccountId
                FROM Contact 
                WHERE Email != null
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
            
            List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, AccountId
                FROM Opportunity 
                WHERE Amount > 0
                ORDER BY Amount DESC
                LIMIT 50
            ];
            
            System.debug('Iteration ' + i + ' - Accounts: ' + accounts.size() + 
                        ', Contacts: ' + contacts.size() + 
                        ', Opps: ' + opportunities.size());
        }
        
        // Query 2: Complex relationship queries
        List<Account> accountsWithRelationships = [
            SELECT Id, Name,
                   (SELECT Id, Name, Email FROM Contacts LIMIT 20),
                   (SELECT Id, Name, Amount FROM Opportunities LIMIT 20),
                   (SELECT Id, Subject FROM Tasks WHERE IsClosed = false LIMIT 10),
                   (SELECT Id, Subject FROM Events WHERE ActivityDateTime >= TODAY LIMIT 10),
                   (SELECT Id, CaseNumber FROM Cases LIMIT 10)
            FROM Account 
            WHERE Industry = 'Technology'
            LIMIT 100
        ];
        
        // Query 3: For each account with relationships, query more related data
        for(Account acct : accountsWithRelationships) {
            // Query each contact's related opportunities
            for(Contact contact : acct.Contacts) {
                List<Opportunity> contactOpps = [
                    SELECT Id, Name, Amount, PrimaryContactId
                    FROM Opportunity 
                    WHERE PrimaryContactId = :contact.Id
                    LIMIT 5
                ];
            }
            
            // Query each opportunity's line items
            for(Opportunity opp : acct.Opportunities) {
                List<OpportunityLineItem> lineItems = [
                    SELECT Id, Quantity, UnitPrice, TotalPrice
                    FROM OpportunityLineItem 
                    WHERE OpportunityId = :opp.Id
                ];
            }
        }
        
        // Query 4: Multiple aggregate queries
        AggregateResult[] accountStats = [
            SELECT Industry, COUNT(Id) total, AVG(AnnualRevenue) avgRev
            FROM Account 
            WHERE Industry != null
            GROUP BY Industry
            ORDER BY total DESC
        ];
        
        AggregateResult[] oppStats = [
            SELECT StageName, COUNT(Id) total, SUM(Amount) totalAmount
            FROM Opportunity 
            GROUP BY StageName
            ORDER BY totalAmount DESC
        ];
        
        AggregateResult[] contactStats = [
            SELECT AccountId, COUNT(Id) contactCount
            FROM Contact 
            WHERE AccountId != null
            GROUP BY AccountId
            HAVING COUNT(Id) > 3
        ];
        
        // Query 5: More expensive queries in nested loops
        for(Account acct : accountsWithRelationships) {
            for(Integer j = 0; j < 5; j++) {
                List<Task> accountTasks = [
                    SELECT Id, Subject, Status, Priority
                    FROM Task 
                    WHERE WhatId = :acct.Id
                    AND Status != 'Completed'
                    LIMIT 10
                ];
                
                List<Event> accountEvents = [
                    SELECT Id, Subject, ActivityDateTime
                    FROM Event 
                    WHERE WhatId = :acct.Id
                    AND ActivityDateTime >= TODAY
                    LIMIT 5
                ];
            }
        }
    }
}
