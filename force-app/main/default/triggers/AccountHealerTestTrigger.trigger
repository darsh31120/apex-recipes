trigger AccountHealerTestTrigger on Account (before insert, before update) {
    for (Account acc : Trigger.new) {
        if (acc.Name != null && acc.Name.containsIgnoreCase('Test')) {
            acc.addError('HEALER_CHALLENGE: Account names cannot contain the word "Test". You must use a realistic company name (e.g., "Global Industries").');
        }
    }
}
trigger AccountHealerTestTrigger on Account (before insert, before update) {
    for (Account acc : Trigger.new) {
        if (acc.Name != null && acc.Name.containsIgnoreCase('Test')) {
            acc.addError('HEALER_CHALLENGE: Account names cannot contain the word "Test". You must use a realistic company name (e.g., "Global Industries").');
        }
    }
}
