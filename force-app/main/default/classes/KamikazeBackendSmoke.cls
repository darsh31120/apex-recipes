public with sharing class KamikazeBackendSmoke {
    public static Integer addTwoNumbers(Integer leftValue, Integer rightValue) {
        Integer safeLeft = leftValue == null ? 0 : leftValue;
        Integer safeRight = rightValue == null ? 0 : rightValue;
        return safeLeft + safeRight;
    }
}
