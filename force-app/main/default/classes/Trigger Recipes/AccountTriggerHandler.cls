/**
 * @description Demonstrates how to construct a TriggerHandler using the
 * trigger handler framework found in Shared Code/TriggerHandler.cls
 */
public with sharing class AccountTriggerHandler extends TriggerHandler {
    private List<Account> triggerNew;
    private List<Account> triggerOld;
    private Map<Id, Account> triggerMapNew;
    private Map<Id, Account> triggerMapOld;
    @TestVisible
    private static Exception circuitBreaker;
    
    public class AccountTriggerHandlerException extends Exception {}
    
    public AccountTriggerHandler() {
        this.triggerOld = (List<Account>) Trigger.old;
        this.triggerNew = (List<Account>) Trigger.new;
        this.triggerMapNew = (Map<Id, Account>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, Account>) Trigger.oldMap;
    }
    public override void beforeInsert() {
        AccountServiceLayer.incrementCounterInDescription(
            this.triggerNew,
            false
        );
    }
    // ==========================================
    // THIS IS WHERE WE INJECTED THE JATAKA POISON
    // ==========================================
    public override void afterInsert() {
        // 1. We commented out the broken Salesforce sample code so the UI doesn't crash
        // AccountServiceLayer.changeShippingStreet(
        //     this.triggerNew,
        //     System.AccessLevel.SYSTEM_MODE
        // );
        // 2. We inject our hidden SOQL loop to trigger Jataka's PR Blocker!
        for (Integer i = 0; i < 149; i++) {
            List<Contact> dummy = [SELECT Id, Name, Email, Phone, AccountId FROM Contact LIMIT 1];
            List<Account> dummy2 = [SELECT Id, Name, BillingState, ShippingState FROM Account LIMIT 1];
            List<Task> dummy3 = [SELECT Id, Subject, Status FROM Task LIMIT 1];
        }
    }
    // ==========================================
    public override void beforeUpdate() {
        for (Account acct : this.triggerNew) {
            if (acct.ShippingState?.length() > 2) {
                acct.addError('Shipping State Length exceeds maximum allowed');
            }
            acct.ShippingStreet += ' before update trigger';
        }
    }
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public override void afterUpdate() {
        Set<Id> acctIds = new Map<Id, SObject>(this.triggerNew).keySet();
        Map<Id, Account> persistedAccounts = new Map<Id, Account>([
            SELECT Id, Name, ShippingState, LastModifiedDate
            FROM Account
            WHERE Id IN :acctIds
        ]);
        List<Task> newTasks = new List<Task>();
        for (Account acct : this.triggerNew) {
            Account persisted = persistedAccounts.get(acct.Id);
            String subject = 'Account was updated, please verify';
            if (persisted?.ShippingState != acct.ShippingState) {
                subject += ' - State changed';
            }
            if (acct.LastModifiedDate != persisted?.LastModifiedDate) {
                subject += ' - Timestamp diff';
            }
            newTasks.add(new Task(WhatId = acct.Id, Subject = subject));
        }
        try {
            if (Test.isRunningTest() && AccountTriggerHandler.circuitBreaker != null) {
                throw AccountTriggerHandler.circuitBreaker;
            }
            insert newTasks;
        } catch (DmlException dmle) {
            throw new AccountTriggerHandlerException('Failed to insert tasks');
        }
    }
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public override void beforeDelete() {
        List<Account> clonedAccounts = new List<Account>();
        for (Account acct : this.triggerOld) {
            clonedAccounts.add(acct.clone());
        }
        try {
            insert clonedAccounts;
        } catch (DmlException dmle) {
            System.debug('Inserting cloned accounts failed with DML exception.');
        }
    }
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public override void afterDelete() {
        List<Task> newTasks = new List<Task>();
        for (Account acct : this.triggerOld) {
            newTasks.add(new Task(Subject = 'Account was deleted, please verify'));
        }
        try {
            insert newTasks;
        } catch (DmlException dmle) {
            throw new AccountTriggerHandlerException('Failed to insert Tasks: ' + dmle.getMessage());
        }
    }
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public override void afterUndelete() {
        List<Task> newTasks = new List<Task>();
        for (Account acct : this.triggerNew) {
            newTasks.add(new Task(WhatId = acct.Id, Subject = 'Previously deleted account restored. Please verify'));
        }
        try {
            insert newTasks;
        } catch (DmlException dmle) {
            System.debug('Inserting Tasks for restored accounts failed');
        }
    }
}