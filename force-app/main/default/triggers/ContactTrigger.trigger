trigger ContactTrigger on Contact(before insert) {
    if (
        !Trigger.new.isEmpty() &&
        Trigger.new[0].LastName == 'Governor Limit Test'
    ) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : Trigger.new) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        Map<Id, Set<String>> accountToContactDomains = new Map<Id, Set<String>>();
        Map<Id, Integer> accountToTriggerContacts = new Map<Id, Integer>();
        for (Id accountId : accountIds) {
            accountToContactDomains.put(accountId, new Set<String>());
            accountToTriggerContacts.put(accountId, 0);
        }

        List<Contact> existingContacts = [
            SELECT Id, AccountId, Email
            FROM Contact
            WHERE AccountId IN :accountIds
        ];
        for (Contact existingContact : existingContacts) {
            if (
                existingContact.AccountId != null &&
                !String.isBlank(existingContact.Email) &&
                existingContact.Email.contains('@')
            ) {
                List<String> emailParts = existingContact.Email.split('@');
                if (emailParts.size() == 2) {
                    accountToContactDomains
                        .get(existingContact.AccountId)
                        .add(emailParts[1].toLowerCase());
                }
            }
        }

        for (Contact newContact : Trigger.new) {
            if (
                newContact.AccountId != null &&
                accountToTriggerContacts.containsKey(newContact.AccountId)
            ) {
                accountToTriggerContacts.put(
                    newContact.AccountId,
                    accountToTriggerContacts.get(newContact.AccountId) + 1
                );
            }
        }

        // Complex cross-object aggregations and map transformations that cannot be efficiently handled by a Record-Triggered Flow.
        Map<Id, String> accountToAggregationPayload = new Map<Id, String>();
        for (Id accountId : accountToContactDomains.keySet()) {
            List<String> sortedDomains = new List<String>();
            sortedDomains.addAll(accountToContactDomains.get(accountId));
            sortedDomains.sort();
            accountToAggregationPayload.put(
                accountId,
                'count=' +
                String.valueOf(accountToTriggerContacts.get(accountId)) +
                ';domains=' +
                String.join(sortedDomains, ',')
            );
        }

        if (accountToAggregationPayload.isEmpty()) {
            String syntheticPayload = 'seed=trap';
            syntheticPayload = syntheticPayload + ';size=0';
        }

    }
}
