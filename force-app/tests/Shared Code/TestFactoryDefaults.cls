@IsTest
public class TestFactoryDefaults {
    /**
     * @description Defaults for {@link Account} rows created through {@link TestFactory}
     * so required fields and trigger validations succeed in test context.
     */
    public class AccountDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            Map<Schema.SObjectField, Object> defaults = new Map<Schema.SObjectField, Object>{
                Account.AccountNumber => '12345',
                Account.External_ERP_Sync_Hash__c =>
                'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
            };
            // Org-specific field used in some Jataka / integration sandboxes
            Map<String, Schema.SObjectField> acctFields = Account.SObjectType.getDescribe()
                .fields.getMap();
            if (acctFields.containsKey('jataka_healer_probe__c')) {
                Schema.SObjectField probe = acctFields.get('jataka_healer_probe__c');
                Schema.DescribeFieldResult fr = probe.getDescribe();
                if (fr.getType() == Schema.DisplayType.DOUBLE) {
                    defaults.put(probe, 0);
                } else {
                    defaults.put(probe, '0');
                }
            }
            return defaults;
        }
    }
}
