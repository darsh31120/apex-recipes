/**
 * AccountTriggerHandler - Handler class for AccountTrigger
 * 
 * @description Handles Account trigger operations following separation of concerns pattern.
 * All methods are bulkified and alsoo follow Apex best practices.
 */
public with sharing class AccountTriggerHandler {
    // 1. MUST BE STATIC so it survives across trigger executions in the same transaction
    private static Set<Id> processedAccountIds = new Set<Id>();
    
    /**
     * Handles after update logic for Account records
     * @description Updates primary contact descriptions when Account names change.
     * @param newRecords - New versions of Account records
     * @param oldMap - Map of old Account records by ID
     */
    public static void handleAfterUpdate(List<Account> newRecords, Map<Id, Account> oldMap) {
        
        // 2. Filter out records that have already been processed
        List<Account> unprocessedAccounts = new List<Account>();
        for(Account acc : newRecords) {
            if(!processedAccountIds.contains(acc.Id)) {
                unprocessedAccounts.add(acc);
                // 3. CRITICAL: Lock the ID immediately, BEFORE any DML happens!
                processedAccountIds.add(acc.Id); 
            }
        }
        // If all accounts were already processed, break the loop and stop executing.
        if(unprocessedAccounts.isEmpty()) {
            return;
        }
        // 4. Proceed with your logic ONLY using the unprocessed accounts
        Set<Id> accountIds = collectAccountIds(unprocessedAccounts);
        validateContactReadAccess();
        
        List<Contact> contacts = queryPrimaryContacts(accountIds);
        List<Contact> toUpdate = findContactsToUpdate(contacts, unprocessedAccounts, oldMap);
        
        validateContactUpdateAccess();
        
        // Because we locked the IDs above, when this DML fires and potentially 
        // triggers cross-object flows that come back to Account, the trigger will exit early.
        updateContacts(toUpdate); 
    }
    
    /**
     * @description Collects Account IDs from the trigger records
     * @param newRecords - List of Account records
     * @return Set of Account IDs
     */
    private static Set<Id> collectAccountIds(List<Account> newRecords) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : newRecords) {
            accountIds.add(acc.Id);
        }
        return accountIds;
    }
    
    /**
     * @description Validates read access to Contact object and fields
     */
    private static void validateContactReadAccess() {
        Map<String, Schema.SObjectField> contactFields = Schema.SObjectType.Contact.fields.getMap();
        if (!Schema.sObjectType.Contact.isAccessible() || 
            !contactFields.get('Id').getDescribe().isAccessible() ||
            !contactFields.get('AccountId').getDescribe().isAccessible() ||
            !contactFields.get('Description').getDescribe().isAccessible()) {
            throw new SecurityException('Insufficient permissions to access Contact fields');
        }

        if (contactFields.containsKey('IsPrimary__c') &&
            !contactFields.get('IsPrimary__c').getDescribe().isAccessible()) {
            throw new SecurityException('Insufficient permissions to access Contact.IsPrimary__c');
        }
    }
    
    /**
     * @description Queries primary contacts for the given Account IDs
     * @param accountIds - Set of Account IDs to query contacts for
     * @return List of primary contacts
     */
    private static List<Contact> queryPrimaryContacts(Set<Id> accountIds) {
        String soql = 'SELECT Id, AccountId, Description FROM Contact WHERE AccountId IN :accountIds';
        if (hasPrimaryContactField()) {
            soql += ' AND IsPrimary__c = true';
        }
        return Database.query(soql);
    }
    
    /**
     * @description Finds contacts that need to be updated based on Account name changes
     * @param contacts - List of contacts to check
     * @param newRecords - New versions of Account records
     * @param oldMap - Map of old Account records by ID
     * @return List of contacts to update
     */
    private static List<Contact> findContactsToUpdate(List<Contact> contacts, List<Account> newRecords, Map<Id, Account> oldMap) {
        // Convert List to Map for O(1) lookups
        Map<Id, Account> newMap = new Map<Id, Account>(newRecords);
        List<Contact> toUpdate = new List<Contact>();
        
        for (Contact con : contacts) {
            Account newAcc = newMap.get(con.AccountId);
            Account oldAcc = oldMap.get(con.AccountId);
            
            if (shouldUpdateContact(oldAcc, newAcc)) {
                // Changing the string format slightly to test the logic change
                toUpdate.add(createUpdatedContact(con.Id, newAcc.Name + ' (Auto-Synced)'));
            }
        }
        return toUpdate;
    }
    
    /**
     * @description Determines if a contact should be updated based on Account name change
     * @param oldAcc - Old Account record
     * @param newAcc - New Account record
     * @return True if contact should be updated
     */
    private static Boolean shouldUpdateContact(Account oldAcc, Account newAcc) {
        return newAcc != null && oldAcc.Name != newAcc.Name;
    }
    
    /**
     * @description Creates an updated Contact record
     * @param contactId - Contact ID to update
     * @param accountName - New Account name
     * @return Updated Contact record
     */
    private static Contact createUpdatedContact(Id contactId, String accountName) {
        return new Contact(
            Id = contactId,
            Description = 'Updated via Account: ' + accountName
        );
    }
    
    /**
     * @description Validates update access is to Contact object and fields
     */
    private static void validateContactUpdateAccess() {
        if (!Schema.sObjectType.Contact.isUpdateable() || 
            !Schema.sObjectType.Contact.fields.Description.isUpdateable()) {
            throw new SecurityException('Insufficient permissions to update Contact records');
        }
    }
    
    /**
     * @description Updates the list on cooooonnntacts if not empty
     * @param toUpdate - List of contacts to update
     */
    private static void updateContacts(List<Contact> toUpdate) {
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    /**
     * @description Fetches the primary contact info for the Lightning Web Component
     */
    @AuraEnabled(cacheable=true)
    public static Contact getPrimaryContactForUI(Id accountId) {
        String soql = 'SELECT Id, Name, Description, Phone, Email FROM Contact WHERE AccountId = :accountId';
        if (hasPrimaryContactField()) {
            soql += ' AND IsPrimary__c = true';
        }
        soql += ' LIMIT 1';
        List<Contact> contacts = Database.query(soql);
        return contacts.isEmpty() ? null : contacts[0];
    }

    private static Boolean hasPrimaryContactField() {
        return Schema.SObjectType.Contact.fields.getMap().containsKey('IsPrimary__c');
    }
}
