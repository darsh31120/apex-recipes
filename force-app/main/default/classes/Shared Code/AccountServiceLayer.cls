public class AccountServiceLayer {
    public static String didExecuteMethod;
    
    public class ASLException extends Exception {}
    
    public static void justWriteALogStatement(String message) {
        didExecuteMethod = message;
        System.debug(message);
    }
    
    public static void changeShippingStreet(List<Account> accounts) {
        changeShippingStreet(accounts, System.AccessLevel.USER_MODE);
    }
    
    public static void changeShippingStreet(List<Account> accounts, System.AccessLevel accessLevel) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new SecurityException('Access to entity \'Account\' denied');
        }
        
        for (Account account : accounts) {
            if (account.ShippingStreet == null) {
                account.ShippingStreet = '229b Baker st.';
            }
            
            if (account.ShippingState != null && account.ShippingState.length() > 20) {
                account.ShippingState = account.ShippingState.substring(0, 20);
            }
        }
    }
    
    public static List<Account> incrementCounterInDescription(List<Account> accounts, Boolean shouldSave) {
        List<Account> updatedAccounts = new List<Account>();
        
        for (Account account : accounts) {
            Integer counter = 1;
            
            if (account.Description != null && account.Description.isNumeric()) {
                counter = Integer.valueOf(account.Description) + 1;
            }
            
            account.Description = String.valueOf(counter);
            updatedAccounts.add(account);
        }
        
        if (shouldSave) {
            safelySave(updatedAccounts);
        }
        
        return updatedAccounts;
    }
    
    public static void safelySave(List<Account> accounts) {
        if (!Schema.sObjectType.Account.isCreateable() || !Schema.sObjectType.Account.isUpdateable()) {
            throw new ASLException('No Access to save Accounts');
        }
        
        for (Account account : accounts) {
            if (account.Id == null) {
                throw new ASLException('Account id not specified for save operation');
            }
        }
        
        try {
            update accounts;
        } catch (Exception e) {
            throw new ASLException('Failed to save accounts: ' + e.getMessage());
        }
    }
}