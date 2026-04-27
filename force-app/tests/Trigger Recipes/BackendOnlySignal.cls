@isTest
private class BackendOnlySignal {
    @isTest
    static void backendSignalShouldFail() {
        Account testHealerAcc = new Account();
        testHealerAcc.Name = 'Testing AI Healer';
        testHealerAcc.Industry = 'Education';
        insert testHealerAcc;

        System.assert(
            false,
            'Intentional backend failure signal for PR test validation.'
        );
    }
}
