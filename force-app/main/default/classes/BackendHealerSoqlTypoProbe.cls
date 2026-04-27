public with sharing class BackendHealerSoqlTypoProbe {
    public static String getBrokenQuery() {
        return 'SELECT Idd, Nammme FROM Account LIMIT 1';
    }
}
