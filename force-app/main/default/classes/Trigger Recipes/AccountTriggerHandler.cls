public override void afterInsert() {
        
        // 1. COMMENT OUT THE BROKEN SALESFORCE SAMPLE CODE
        // AccountServiceLayer.changeShippingStreet(
        //     this.triggerNew,
        //     System.AccessLevel.SYSTEM_MODE
        // );

        // 2. INJECT YOUR "POISON" SOQL LOOP TO DEMO JATAKA
        for(Integer i = 0; i < 95; i++) {
            List<Contact> dummy =[SELECT Id FROM Contact LIMIT 1];
        }
    }