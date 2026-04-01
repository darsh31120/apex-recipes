public class SafeAccountCreator {
    public static void createAccount() {
        // This is perfectly safe code. Only 1 DML statement.
        Account a = new Account(Name = 'Jataka Fast-Track Test');
        insert a;
    }
}
