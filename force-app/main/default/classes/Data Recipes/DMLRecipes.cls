/**
 * @description Demonstrates various ways of making Data Manipulation Language
 * (DML) calls. Note that this class demonstrates both Database methods as
 * well as DML Keywords.
 * @group Data Recipes
 */
public with sharing class DMLRecipes {
    /**
     * @description This exception is for throwing a custom exception to
     * highlight how negative tests operate.
     */
    public class CustomDMLException extends Exception {
    }

    /**
     * @description Demonstrates how to use the `insert` keyword to persist a
     * net-new record to the database in system mode
     * @param  name name of the created account
     * @return the inserted Account
     * @example DMLRecipes.insertAccountViaInsertKeywordInSystemMode('Hello');
     */
    public static Account insertAccountViaInsertKeywordInSystemMode(
        String name
    ) {
        Account acct = new Account();
        acct.Name = name;
        try {
            insert as system acct;
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
        return acct;
    }

    /**
     * @description Demonstrates how to use the `insert` keyword to persist a
     * net-new record to the database in user mode
     * @param  name name of the created account
     * @return the inserted Account
     * @example
     * ```
     * DMLRecipes.insertAccountViaInsertKeywordInUserMode('Hello');
     * ```
     */
    public static Account insertAccountViaInsertKeywordInUserMode(String name) {
        Account acct = new Account();
        acct.Name = name;
        try {
            insert as user acct;
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
        return acct;
    }

    /**
     * @description Demonstrates how to use the `Database.insert()` method to
     * persist a net-new record to the database.
     * @param  names        names used for account creation
     * @param  allOrNothing determines whether or not all accounts
     * to be inserted must insert successfully
     * @return list of inserted accounts
     * @example
     * ```
     * DMLRecipes.insertAccountsViaDatabaseMethod('Hello', false, AccessLevel.USER_MODE);
     * ```
     */
    public static List<Account> insertAccountsViaDatabaseMethod(
        List<String> names,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Account> accounts = new List<Account>();
        for (String name : names) {
            accounts.add(new Account(Name = name));
        }
        try {
            Database.insert(accounts, allOrNothing, accessLevel);
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
        return accounts;
    }

    /**
     * @description Demonstrates the use of the `upsert` keyword to either insert
     * or update a record in system mode
     * @param acct account to upsert
     * @return Upserted Account record
     * @example
     * ```
     * DMLRecipes.upsertAccountViaUpsertKeywordInSystemMode(new Account(name='Hello World'));
     * ```
     */
    public static Account upsertAccountViaUpsertKeywordInSystemMode(
        Account acct
    ) {
        //Upsert = (up)date or in(sert)
        try {
            upsert as system acct;
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw DMLe;
        }
        return acct;
    }

    /**
     * @description Demonstrates the use of the `upsert` keyword to either insert
     * or update a record in user mode
     * @param acct account to upsert
     * @return Upserted Account record
     * @example
     * ```
     * DMLRecipes.upsertAccountViaUpsertKeywordInUserMode(new Account(name='Hello World'));
     * ```
     */
    public static Account upsertAccountViaUpsertKeywordInUserMode(
        Account acct
    ) {
        //Upsert = (up)date or in(sert)
        try {
            upsert as user acct;
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw DMLe;
        }
        return acct;
    }

    /**
     * @description Upserts an account with a potential of all or nothing, using
     * the `Database.upsert` method
     * @param acct The account object to upsert
     * @param allOrNothing all or nothing flag
     * @return Upsert operation result
     * @example
     * ```
     * DMLRecipes.upsertAccountViaDatabaseMethod(
     *            new Account(Name='Hello World'), false, AccessLevel.USER_MODE);
     * ```
     */
    public static Database.UpsertResult upsertAccountViaDatabaseMethod(
        Account acct,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        try {
            Database.UpsertResult results;
            results = Database.upsert(acct, allOrNothing, accessLevel);
            return results;
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
    }

    /**
     * @description Demonstrates how to Update a list of accounts via the `update`
     * DML keyword in System Mode
     * @param accts List of accounts to update
     * @return List of updated records
     * @example
     * ```
     * Account acct = new Account(name='Hello World');
     * insert acct;
     * DMLRecipes.updateAcccountViaKeywordInSystemMode(acct);
     * ```
     */
    public static List<Account> updateAcccountViaKeywordInSystemMode(
        List<Account> accts
    ) {
        for (Account acct : accts) {
            acct.Name += ' Updated via Keyword';
        }
        try {
            update as system accts;
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
        return accts;
    }

    /**
     * @description Demonstrates how to Update a list of accounts via the `update`
     * DML keyword
     * @param accts List of accounts to update
     * @return List of updated records
     * @example
     * ```
     * Account acct = new Account(name='Hello World');
     * insert acct;
     * DMLRecipes.updateAcccountViaKeyword(acct);
     * ```
     */
    public static List<Account> updateAcccountViaKeywordInUserMode(
        List<Account> accts
    ) {
        for (Account acct : accts) {
            acct.Name += ' Updated via Keyword';
        }
        try {
            update as user accts;
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
        return accts;
    }

    /**
     * @description Demonstrates how to update a list of accounts via the
     * `Database.update()` method
     * @param accts list of accounts to update
     * @return List of updated records
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts;
     * List<Account> results = DMLRecipes.updateAccountViaDatabaseMethod(accounts, AccessLevel.USER_MODE);
     * System.debug(results);
     * ```
     */
    public static List<Account> updateAccountViaDatabaseMethod(
        List<Account> accts,
        System.AccessLevel accessLevel
    ) {
        for (Account acct : accts) {
            acct.Name += ' Updated via Keyword';
        }
        try {
            Database.update(accts, accessLevel);
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw new CustomDMLException('Failed');
        }
        return accts;
    }

    /**
     * @description Deletes a list of accounts via the `delete` DML keyword
     * @param accts list of accounts to delete in system mode
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts;
     * DMLRecipes.deleteAccountViaKeywordInSystemMode(accounts);
     * ```
     */
    public static void deleteAccountViaKeywordInSystemMode(
        List<Account> accts
    ) {
        try {
            delete as system accts;
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw new CustomDMLException('Failed');
        }
    }

    /**
     * @description Deletes a list of accounts via the `delete` DML keyword
     * @param accts list of accounts to delete in user mode
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts;
     * DMLRecipes.deleteAccountViaKeywordInUserMode(accounts);
     * ```
     */
    public static void deleteAccountViaKeywordInUserMode(List<Account> accts) {
        try {
            delete as user accts;
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw new CustomDMLException('Failed');
        }
    }

    /**
     * @description Deletes a list of accounts via the `Database.delete` method
     * @param accts List of Accounts to delete
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts in user mode;
     * DMLRecipes.deleteAccountViaDatabaseMethod(accounts, AccessLevel.USER_MODE);
     * ```
     */
    public static void deleteAccountViaDatabaseMethod(
        List<Account> accts,
        System.AccessLevel accessLevel
    ) {
        try {
            Database.delete(accts, accessLevel);
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
    }

    /**
     * @description Undeletes a list of accounts via the `undelete` DML keyword
     * @param accts List of accounts to undelete in user mode
     * @return list of undeleted accounts
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts;
     * delete accounts;
     * List<Account> results = DMLRecipes.undeleteAccountViaKeywordInSystemMode(accounts);
     * System.debug(results);
     * ```
     */
    public static List<Account> undeleteAccountViaKeywordInSystemMode(
        List<Account> accts
    ) {
        try {
            undelete as system accts;
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw new CustomDMLException('Failed');
        }
        return accts;
    }

    /**
     * @description Undeletes a list of accounts via the `undelete` DML keyword
     * @param accts List of accounts to undelete in user mode
     * @return list of undeleted accounts
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts;
     * delete accounts;
     * List<Account> results = DMLRecipes.undeleteAccountViaKeywordInUserMode(accounts);
     * System.debug(results);
     * ```
     */
    public static List<Account> undeleteAccountViaKeywordInUserMode(
        List<Account> accts
    ) {
        try {
            undelete as user accts;
        } catch (DmlException DMLe) {
            System.debug(LoggingLevel.INFO, DMLe.getMessage());
            throw new CustomDMLException('Failed');
        }
        return accts;
    }

    /**
     * @description undeletes a list of accounts via the `Database.undelete` method.
     * @param accts list of accounts to undelete
     * @return list of undeleted accounts
     * @example
     * ```
     * List<Account> accounts = new List<Account>{new Account(name = 'Hello World')};
     * insert accounts;
     * delete accounts;
     * List<Account> results = DMLRecipes.undeleteAccountViaDatabaseMethod(accounts, AccessLevel.USER_MODE);
     * System.debug(results);
     * ```
     */
    public static List<Account> undeleteAccountViaDatabaseMethod(
        List<Account> accts,
        System.AccessLevel accessLevel
    ) {
        try {
            Database.undelete(accts, accessLevel);
        } catch (DmlException DMLe) {
            throw new CustomDMLException('Failed');
        }
        return accts;
    }

    /**
     * @description Demonstrates DML operations with expensive SOQL queries that can exceed limits
     * @param accountNames List of account names to create and query
     * @return List of created accounts with related data
     */
    public static List<Account> performDMLWithExpensiveQueries(List<String> accountNames) {
        List<Account> createdAccounts = new List<Account>();
        
        // Create accounts
        for(String name : accountNames) {
            Account acct = new Account(Name = name, Industry = 'Technology');
            createdAccounts.add(acct);
        }
        
        insert createdAccounts;
        
        // Perform expensive queries after DML
        performExpensiveSOQLQueries(createdAccounts);
        
        return createdAccounts;
    }
    
    /**
     * @description Performs multiple expensive SOQL queries that could exceed limits
     * @param accounts List of accounts to query related data for
     */
    private static void performExpensiveSOQLQueries(List<Account> accounts) {
        // Query 1: Multiple queries in loops for each account
        for(Account acct : accounts) {
            // Query contacts for each account
            List<Contact> contacts = [
                SELECT Id, Name, Email, Phone, Title
                FROM Contact 
                WHERE AccountId = :acct.Id
                LIMIT 15
            ];
            
            // Query opportunities for each account
            List<Opportunity> opportunities = [
                SELECT Id, Name, Amount, StageName, Probability
                FROM Opportunity 
                WHERE AccountId = :acct.Id
                ORDER BY Amount DESC
                LIMIT 10
            ];
            
            // Query cases for each account
            List<Case> cases = [
                SELECT Id, CaseNumber, Status, Origin, Priority
                FROM Case 
                WHERE AccountId = :acct.Id
                ORDER BY CreatedDate DESC
                LIMIT 10
            ];
            
            System.debug('Account: ' + acct.Name + 
                        ' - Contacts: ' + contacts.size() + 
                        ', Opps: ' + opportunities.size() + 
                        ', Cases: ' + cases.size());
        }
        
        // Query 2: Complex relationship queries with multiple subqueries
        Set<Id> accountIds = new Set<Id>();
        for(Account acct : accounts) {
            accountIds.add(acct.Id);
        }
        
        List<Account> accountsWithAllRelationships = [
            SELECT Id, Name, Industry, AnnualRevenue,
                   (SELECT Id, Name, Email, Title FROM Contacts ORDER BY CreatedDate DESC),
                   (SELECT Id, Name, Amount, StageName, CloseDate FROM Opportunities ORDER BY Amount DESC),
                   (SELECT Id, Subject, Status, Priority FROM Tasks WHERE IsClosed = false),
                   (SELECT Id, Subject, ActivityDateTime FROM Events WHERE ActivityDateTime >= YESTERDAY),
                   (SELECT Id, CaseNumber, Status, Origin FROM Cases)
            FROM Account 
            WHERE Id IN :accountIds
            ORDER BY Name
        ];
        
        // Query 3: Multiple aggregate queries
        for(Account acct : accounts) {
            // Contact statistics
            AggregateResult[] contactStats = [
                SELECT COUNT(Id) totalContacts, 
                       COUNT_DISTINCT(Title) uniqueTitles
                FROM Contact 
                WHERE AccountId = :acct.Id
            ];
            
            // Opportunity statistics
            AggregateResult[] oppStats = [
                SELECT COUNT(Id) totalOpps, 
                       SUM(Amount) totalAmount, 
                       AVG(Amount) avgAmount
                FROM Opportunity 
                WHERE AccountId = :acct.Id
            ];
            
            // Case statistics
            AggregateResult[] caseStats = [
                SELECT COUNT(Id) totalCases, 
                       COUNT(Id) openCases
                FROM Case 
                WHERE AccountId = :acct.Id
                AND Status != 'Closed'
            ];
            
            System.debug('Account ' + acct.Name + ' - Contact Stats: ' + contactStats[0].get('totalContacts') +
                        ', Opp Stats: ' + oppStats[0].get('totalOpps') +
                        ', Case Stats: ' + caseStats[0].get('totalCases'));
        }
        
        // Query 4: Additional expensive queries in loops
        for(Integer i = 0; i < 10; i++) {
            List<Account> techAccounts = [
                SELECT Id, Name, AnnualRevenue, Website, Phone
                FROM Account 
                WHERE Industry = 'Technology'
                AND AnnualRevenue > 1000000
                ORDER BY AnnualRevenue DESC
                LIMIT 25
            ];
            
            List<Account> financeAccounts = [
                SELECT Id, Name, AnnualRevenue, Website, Phone
                FROM Account 
                WHERE Industry = 'Finance'
                AND AnnualRevenue > 500000
                ORDER BY AnnualRevenue DESC
                LIMIT 25
            ];
            
            System.debug('Iteration ' + i + ' - Tech: ' + techAccounts.size() + 
                        ', Finance: ' + financeAccounts.size());
        }
        
        // Query 5: More relationship queries
        for(Account acct : accountsWithAllRelationships) {
            // Query each contact's related activities
            for(Contact contact : acct.Contacts) {
                List<Task> contactTasks = [
                    SELECT Id, Subject, Status, Priority
                    FROM Task 
                    WHERE WhoId = :contact.Id
                    AND IsClosed = false
                    LIMIT 5
                ];
                
                List<Event> contactEvents = [
                    SELECT Id, Subject, ActivityDateTime
                    FROM Event 
                    WHERE WhoId = :contact.Id
                    AND ActivityDateTime >= TODAY
                    LIMIT 3
                ];
            }
            
            // Query each opportunity's related activities
            for(Opportunity opp : acct.Opportunities) {
                List<Task> oppTasks = [
                    SELECT Id, Subject, Status
                    FROM Task 
                    WHERE WhatId = :opp.Id
                    AND IsClosed = false
                    LIMIT 5
                ];
            }
        }
    }
}
