public with sharing class BackendHealerProbe {
    public static String getProbeLabel(String labelPrefix) {
        String prefix = String.isBlank(labelPrefix) ? 'Healer' : labelPrefix.trim();
        return prefix + ' Probe';
    }
}
