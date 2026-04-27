public with sharing class BackendHealerApexSyntaxProbe {
    public static String getBrokenApex() {
        return 'Account a = new Account(NumberOfEmployees = \'Five\'); insert a;';
    }
}
