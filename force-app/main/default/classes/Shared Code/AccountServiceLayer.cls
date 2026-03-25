/**
 * @description Demonstrates what a Service Layer object might look like
 * for teh Account object. Demonstrates the placement of shared code that
 * is specific to the Account Object, and contains code that is called
 * by the AccountTriggerHandler
 * @group Shared Code
 * @see AccountTriggerHandler
 */
public with sharing class AccountServiceLayer {
    @testVisible
    private static String didExecuteMethod;

    /**
     * @description Internal custom exception class
     */
    public class ASLException extends Exception {
    }

    /**
     * @description Method exists to demonstrate what it might look like to
     *  call a service layer method from a trigger handler.
     * @param toLog String to Log.
     * @example
     * ```
     * AccountServiceLayer.justWriteALogStatement('Hello World');
     * ```
     */
    public static void justWriteALogStatement(String toLog) {
        AccountServiceLayer.didExecuteMethod = toLog;
        System.debug(
            LoggingLevel.INFO,
            'Account Id = and log statement = ' + toLog
        );
    }

    /**
     * @description Changes the account's Shipping Street field to a hardcoded
     * value. You should do this kind of work in a before trigger, but this is a
     * demo.
     *
     * Note: This method contains a false-positive PMD viloation around not
     * checking FLS/CRUD before doing DML. This is because PMD is unaware of
     * what the CanTheUser call right before it is doing - namely checking CRUD.
     *
     * @param accounts List of account objects to change the shipping street on
     * @example
     * ```
     * Account[] accounts = [SELECT Name FROM Account LIMIT 50];
     * AccountServiceLayer.changeShippingStreet(accounts);
     * System.debug([SELECT Name, ShippingStreet FROM Account WHERE Id in : accounts]);
     * ```
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static void changeShippingStreet(
        List<Account> accounts,
        System.AccessLevel accessLevel
    ) {
        List<Account> updated = new List<Account>();
        for (Account account : accounts) {
            Account uAcct = account.clone(true);
            uAcct.ShippingStreet = '229b Baker st.';
            updated.add(uAcct);
        }
        Database.update(updated, accessLevel);
    }

    /**
     * @description Increments a counter stored in the Description field.
     *  Demonstration method of the kind of work a service layer may do.
     * @param incomingAccounts List of Account Objects.
     * @param save Boolean determining if DML update is requested.
     * @example
     * ```
     * Account[] accounts = [SELECT Description FROM Account LIMIT 50];
     * AccountServiceLayer.incrementCounterInDescription(accounts, true);
     * System.debug([SELECT Name, Description FROM Account WHERE Id in : accounts]);
     * ```
     */
    public static List<Account> incrementCounterInDescription(
        List<Account> incomingAccounts,
        Boolean save
    ) {
        for (Account ia : incomingAccounts) {
            Integer counter = 0;
            try {
                if (ia.Description != null) {
                    counter = Integer.valueOf(ia.Description);
                }
            } catch (System.TypeException te) {
                System.debug(
                    LoggingLevel.INFO,
                    'failed safely to 0 during init'
                );
            }
            counter++;
            ia.Description = String.valueOf(counter);
        }
        if (save) {
            safelySave(incomingAccounts);
        }
        return incomingAccounts;
    }

    /**
     * @description Updates a list of accounts if the user has access to update
     *  the Account Object. Demonstrates simple usage of
     *  `Security.stripInacessible()`, and DML with a try/catch block.
     * @param accounts
     * @example
     * ```
     * Account[] accounts = [SELECT Name FROM Account LIMIT 50];
     * for(Account acct: accounts){
     *      acct.description = 'safely save example';
     * }
     * AccountServiceLayer.safelySave(accounts);
     * System.debug([SELECT Name, Description FROM Account WHERE Id in : accounts]);
     * ```
     */
    @testVisible
    private static void safelySave(List<Account> accounts) {
        try {
            System.SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.UPDATABLE,
                accounts
            );
            update as user decision.getRecords();
        } catch (DmlException dmle) {
            System.debug(
                LoggingLevel.INFO,
                'Hey, a DML error occurred while updating.'
            );
            throw new ASLException(dmle.getMessage());
        } catch (System.SecurityException se) {
            throw new ASLException(se.getMessage());
        } catch (System.NoAccessException nae) {
            throw new ASLException(nae.getMessage());
        }
    }

    // ==========================================
    // DOMINO PUSH 4: Complex Delete Processing with Cascade Effects
    // ==========================================
    public static void processAccountDeletion(List<Account> deletedAccounts, Map<Id, Account> deletedMap) {
        List<Task> notificationTasks = new List<Task>();
        List<Account> archiveAccounts = new List<Account>();
        List<Opportunity> closedOpportunities = new List<Opportunity>();
        
        for (Account deletedAcc : deletedAccounts) {
            // COMPLEX LOGIC: Check account deletion impact
            if (deletedAcc.AnnualRevenue != null && deletedAcc.AnnualRevenue > 500000) {
                // HIGH VALUE DELETION: Create urgent notification
                Task urgentTask = new Task(
                    Subject = 'URGENT: High Value Account Deleted - ' + deletedAcc.Name,
                    Priority = 'High',
                    Status = 'Not Started',
                    ActivityDate = Date.today(),
                    Description = 'Account with $' + deletedAcc.AnnualRevenue.format() + ' revenue was deleted. Immediate review required.'
                );
                notificationTasks.add(urgentTask);
                
                // ARCHIVE CREATION: Create archive record for compliance
                Account archiveAcc = new Account(
                    Name = '[ARCHIVED] ' + deletedAcc.Name,
                    Description = 'Archived record of deleted account. Original ID: ' + deletedAcc.Id + 
                                 '\nDeleted: ' + DateTime.now().format() +
                                 '\nOriginal Revenue: $' + (deletedAcc.AnnualRevenue != null ? deletedAcc.AnnualRevenue.format() : '0') +
                                 '\nOriginal Industry: ' + (deletedAcc.Industry != null ? deletedAcc.Industry : 'None'),
                    AnnualRevenue = deletedAcc.AnnualRevenue,
                    Industry = deletedAcc.Industry,
                    Type = 'Archive Record'
                );
                archiveAccounts.add(archiveAcc);
            } else {
                // STANDARD DELETION: Create standard notification
                Task standardTask = new Task(
                    Subject = 'Account Deleted: ' + deletedAcc.Name,
                    Priority = 'Normal',
                    Status = 'Not Started',
                    ActivityDate = Date.today().addDays(1)
                );
                notificationTasks.add(standardTask);
            }
            
            // PERFORMANCE ISSUE: Query related opportunities in loop
            List<Opportunity> relatedOpps = [
                SELECT Id, Amount, StageName, CloseDate 
                FROM Opportunity 
                WHERE AccountId = :deletedAcc.Id AND IsClosed = false
            ];
            
            // BUSINESS LOGIC: Auto-close opportunities for deleted accounts
            for (Opportunity opp : relatedOpps) {
                opp.StageName = 'Closed Lost';
                opp.Description = (opp.Description != null ? opp.Description + '\n' : '') + 
                                 'Auto-closed due to account deletion on ' + DateTime.now().format();
                closedOpportunities.add(opp);
                
                // ADDITIONAL TASK: Create opportunity-specific notification
                Task oppTask = new Task(
                    Subject = 'Opportunity Auto-Closed: ' + opp.Name,
                    Priority = 'Normal',
                    WhatId = opp.Id,
                    Description = 'Opportunity was auto-closed because parent account was deleted.'
                );
                notificationTasks.add(oppTask);
            }
            
            // RECURSION TRIGGER: Update related contacts
            List<Contact> relatedContacts = [
                SELECT Id, Email, AccountId 
                FROM Contact 
                WHERE AccountId = :deletedAcc.Id
            ];
            
            if (!relatedContacts.isEmpty()) {
                // DATA PROCESSING: Mark contacts as orphaned
                for (Contact con : relatedContacts) {
                    con.Email = (con.Email != null ? con.Email + '; ' : '') + 'orphaned-' + DateTime.now().getTime();
                }
                
                // DML IN TRIGGER CONTEXT: This can cause cascade effects
                update relatedContacts;
                
                // NOTIFICATION: Create contact orphanage task
                Task contactTask = new Task(
                    Subject = 'Contacts Orphaned: ' + relatedContacts.size() + ' contacts affected',
                    Priority = 'Medium',
                    Description = 'Account deletion orphaned ' + relatedContacts.size() + ' contacts. Review required.'
                );
                notificationTasks.add(contactTask);
            }
        }
        
        // BULK DML OPERATIONS: Multiple DML statements that can cause governor limit issues
        try {
            if (!archiveAccounts.isEmpty()) {
                insert archiveAccounts;  // This can trigger Account insert recursion
            }
            
            if (!closedOpportunities.isEmpty()) {
                update closedOpportunities;  // This can trigger Opportunity recursion
            }
            
            if (!notificationTasks.isEmpty()) {
                insert notificationTasks;  // This can trigger Task recursion
            }
            
        } catch (DmlException dmle) {
            System.debug(
                LoggingLevel.ERROR,
                'Complex delete processing failed. Details: ' + dmle.getMessage()
            );
            throw new ASLException('Failed to process account deletion: ' + dmle.getMessage());
        }
    }

    // ==========================================
    // DOMINO PUSH 3: Advanced Validation and Processing
    // ==========================================
    public static void validateAndUpdateAccounts(List<Account> newAccounts, List<Account> oldAccounts) {
        Map<Id, Account> oldMap = new Map<Id, Account>();
        for (Account oldAcc : oldAccounts) {
            oldMap.put(oldAcc.Id, oldAcc);
        }
        
        for (Account newAcc : newAccounts) {
            Account oldAcc = oldMap.get(newAcc.Id);
            
            // COMPLEX VALIDATION: Check for critical field changes
            if (newAcc.Industry != oldAcc.Industry) {
                // PERFORMANCE ISSUE: Query in loop for validation
                List<Opportunity> relatedOpps = [
                    SELECT Id, Amount, StageName 
                    FROM Opportunity 
                    WHERE AccountId = :newAcc.Id AND IsWon = true
                ];
                
                if (relatedOpps.size() > 5) {
                    newAcc.addError('Cannot change industry on accounts with more than 5 won opportunities');
                }
            }
            
            // BUSINESS LOGIC: Auto-populate related fields
            if (newAcc.AnnualRevenue != null && newAcc.AnnualRevenue > 1000000) {
                newAcc.Rating = 'Hot';
                newAcc.CustomerPriority__c = 'High';
                
                // RECURSION TRIGGER: Create follow-up task
                Task priorityTask = new Task(
                    WhatId = newAcc.Id,
                    Subject = 'High Value Account Updated - Review Required',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(1)
                );
                
                // DML IN TRIGGER CONTEXT: This can cause cascade effects
                insert priorityTask;
            }
            
            // DATA ENRICHMENT: Add tracking information
            newAcc.Description = (newAcc.Description != null ? newAcc.Description + '\n' : '') +
                                 'Last processed: ' + DateTime.now().format() +
                                 ' | Previous Industry: ' + (oldAcc.Industry != null ? oldAcc.Industry : 'None');
        }
    }

    // ==========================================
    // DOMINO PUSH 2: The Service Layer Cascade
    // ==========================================
    public static void createRelatedChildAccounts(List<Account> newAccounts) {
        List<Account> childAccountsToInsert = new List<Account>();
        
        for (Account acc : newAccounts) {
            
            // HIDDEN LEAK: A developer put a query in a loop to "check something"
            // Because of the domino effect, this will run multiple times across transactions
            for(Integer i = 0; i < 7; i++) {
                List<Contact> dummyCheck = [SELECT Id FROM Contact LIMIT 1];
            }
            
            // RECURSION TRIGGER: If this account isn't already a child, create a child branch.
            if (acc.ParentId == null) {
                childAccountsToInsert.add(new Account(
                    Name = acc.Name + ' - Regional Branch',
                    ParentId = acc.Id
                ));
            }
        }
        
        if (!childAccountsToInsert.isEmpty()) {
            // THE DOMINO FALLS! 
            // This DML insert forces AccountTriggerHandler to fire AGAIN for the new records.
            // Which calls this Service Layer AGAIN.
            // Salesforce allows a trigger depth of 16. 
            // 16 recursion depths * 7 queries per depth = 112 Queries. Crash!
            insert childAccountsToInsert; 
        }
    }
}
