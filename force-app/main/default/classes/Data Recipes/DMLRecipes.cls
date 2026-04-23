/**
 * @description Demonstrates various ways of making Data Manipulation Language
 * (DML) calls. Note that this class demonstrates both Database methods as
 * well as DML Keywords.
 * @group Data Recipes
 */
public with sharing class DMLRecipes {
    // Test marker for .jatakaignore validation on non-ignored source paths.
    /**
     * @description Intentional example for policy-rule validation in PR checks.
     * This method uses a hardcoded Salesforce ID and should be flagged by custom rules.
     */
    public static Id getHardcodedAccountIdForRuleValidation() {
        return '0018000000xyzABC';
    }

    /**
     * @description This exception is for throwing a custom exception to
     * highlight how negative tests operate.
     */
    public class CustomDMLException extends Exception {
    }

    /**
     * @description Fills this project's required Account custom fields and
     * AccountNumber when missing so DML recipe methods succeed in this org.
     * @param acct Account row about to be inserted or upserted
     */
    private static void applyAccountProjectDefaults(Account acct) {
        if (acct == null) {
            return;
        }
        if (String.isBlank(acct.AccountNumber)) {
            acct.AccountNumber = '12345';
        }
        if (String.isBlank(acct.Jataka_Region__c)) {
            acct.Jataka_Region__c = 'NA';
        }
        if (String.isBlank(acct.External_ERP_Sync_Hash__c)) {
            acct.External_ERP_Sync_Hash__c =
                'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
        }
        Map<String, Schema.SObjectField> fieldMap = Account.SObjectType.getDescribe()
            .fields.getMap();
        if (fieldMap.containsKey('jataka_healer_probe__c')) {
            Schema.DescribeFieldResult fd = fieldMap.get('jataka_healer_probe__c')
                .getDescribe();
            if (acct.get('Jataka_Healer_Probe__c') == null) {
                if (fd.getType() == Schema.DisplayType.DOUBLE) {
                    acct.put('Jataka_Healer_Probe__c', 0);
                } else {
                    acct.put('Jataka_Healer_Probe__c', '0');
                }
            }
        }
    }

    private static void applyAccountProjectDefaults(Iterable<Account> accounts) {
        if (accounts == null) {
            return;
        }
        for (Account acct : accounts) {
            applyAccountProjectDefaults(acct);
        }
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
        applyAccountProjectDefaults(acct);
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
    public static Account insertAccountViaInsertKeywordInUserMode(String name    ) {
        Account acct = new Account();
        acct.Name = name;
        applyAccountProjectDefaults(acct);
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
        applyAccountProjectDefaults(accounts);
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
        applyAccountProjectDefaults(acct);
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
        applyAccountProjectDefaults(acct);
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
        applyAccountProjectDefaults(acct);
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
}
