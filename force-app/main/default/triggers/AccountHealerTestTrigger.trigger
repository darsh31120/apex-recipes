trigger AccountHealerTestTrigger on Account (before insert) {
    // 1. Fire your custom Healer Challenge
    for (Account a : Trigger.new) {
        if (a.Name != null && a.Name.contains('Test')) {
            a.addError(
                'HEALER_CHALLENGE: Account names cannot contain the word "Test".'
            );
        }
    }

    // 2. Tell the Apex Recipes framework to skip its own Account logic to avoid Address errors
    TriggerHandler.bypass('AccountTriggerHandler');
}
