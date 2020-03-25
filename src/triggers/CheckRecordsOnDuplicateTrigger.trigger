/**
 * Created by vvalitsky on 10/17/2019.
 */

trigger CheckRecordsOnDuplicateTrigger on Product2 (before insert, before update, after insert ) {
    if (Trigger.isBefore) {
        for (Product2 product : Trigger.new) {
            product.Name__c = product.Name;
        }
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        List<Product2> productsWithoutExtIds = new List<Product2>();
        for (Product2 product : Trigger.new) {
            if (String.isBlank(product.ExtId__c)) {
                Product2 productToUpdate = new Product2(
                        Id = product.Id,
                        ExtId__c = product.Id
                );
                productsWithoutExtIds.add(productToUpdate);
            }
        }
        if (!productsWithoutExtIds.isEmpty()) {
            update productsWithoutExtIds;
        }
    }
}