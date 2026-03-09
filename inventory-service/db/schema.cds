namespace tracemeds.db;

using { managed, cuid } from '@sap/cds/common';

entity Products : managed {
    key productID        : String(10);
    productName          : String(100);
    category             : String(50);
    subCategory          : String(50);
    genericName          : String(100);
    manufacturer         : String(100);
    uom                  : String(20);
    scheduleDrug         : Boolean default false;
    requiresQC           : Boolean default true;
    storageCondition     : String(100);
    shelfLife            : Integer;
    status               : String(20) default 'ACTIVE';

    inventoryRecords     : Association to many InventoryRecords
                               on inventoryRecords.product = $self;
}
entity InventoryRecords : cuid, managed {
    key ID               : UUID;
    product              : Association to Products @mandatory;
    location             : String(100) @mandatory;
    batchNumber          : String(50)  @mandatory;
    quantity             : Integer     @mandatory;
    quantityOnHand       : Integer default 0;
    reservedQuantity     : Integer default 0;
    dispatchedQuantity   : Integer default 0;
    manufactureDate      : Date;
    expiryDate           : Date;
    sourceShipmentID     : UUID;
    status               : String(20) default 'AVAILABLE';
    remarks              : String(200);

    movements            : Composition of many InventoryMovements
                               on movements.inventoryRecord = $self;
}

entity InventoryMovements : cuid, managed {
    key ID               : UUID;
    inventoryRecord      : Association to InventoryRecords @mandatory;
    movementType         : String(20) @mandatory;
    quantity             : Integer    @mandatory;
    quantityBefore       : Integer;
    quantityAfter        : Integer;
    fromLocation         : String(100);
    toLocation           : String(100);
    reason               : String(200);
    referenceDoc         : String(50);
    performedBy          : String(100);
}
