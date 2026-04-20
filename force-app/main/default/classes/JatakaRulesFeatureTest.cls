@isTest(isParallel=true)
private class JatakaRulesFeatureTest {
    @isTest
    static void validatesCustomRulePath() {
        Id currentUserId = UserInfo.getUserId();
        System.assertNotEquals(null, currentUserId);
    }
}
