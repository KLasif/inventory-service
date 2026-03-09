namespace com.healthcare.tracemeds;

using { managed, cuid } from '@sap/cds/common';

entity Hospitals : managed {
    key hospitalID      : String(10);
    hospitalName        : String(100) @mandatory;
    location            : String(100);
    state               : String(50);
    hospitalType        : String(20);  // Government, Private, District
    contactPerson       : String(100);
    email               : String(100);
    phone               : String(20);
    status              : String(20) default 'ACTIVE';
    
    // Associations
    indents             : Association to many Indents on indents.hospital = $self;
}
entity Products : managed {
    key productID       : String(10);
    productName         : String(100) @mandatory;
    category            : String(50);  // DRUG, SURGICAL, MEDICAL_DEVICE
    subCategory         : String(50);
    genericName         : String(100);
    manufacturer        : String(100);
    uom                 : String(20);  // Unit: BOX, PIECE, VIAL, STRIP
    scheduleDrug        : Boolean default false;
    requiresQC          : Boolean default true;
    storageCondition    : String(100);
    shelfLife           : Integer;
    status              : String(20) default 'ACTIVE';
    
    // Associations
    indentItems         : Association to many IndentItems on indentItems.product = $self;
    inventoryRecords    : Association to many InventoryRecords on inventoryRecords.product = $self;
}

entity Indents : cuid, managed {
    key ID              : UUID;
    indentNumber        : String(20) @mandatory;
    hospital            : Association to Hospitals @mandatory;
    indentDate          : Date @mandatory;
    requiredByDate      : Date;
    priority            : String(20) default 'MEDIUM';  // HIGH, MEDIUM, LOW
    status              : String(20) default 'DRAFT';
    remarks             : String(500);
    
    // Composition - Indent OWNS items
    items               : Composition of many IndentItems on items.indent = $self;
}

entity IndentItems : cuid {
    key ID              : UUID;
    indent              : Association to Indents @mandatory;
    itemNumber          : Integer @mandatory;
    product             : Association to Products @mandatory;
    quantity            : Integer @mandatory;
    urgency             : String(20) default 'NORMAL';
    remarks             : String(200);
}

entity PurchaseOrders : cuid, managed {
    key ID              : UUID;
    poNumber            : String(20) @mandatory;
    poDate              : Date @mandatory;
    expectedDelivery    : Date;
    totalValue          : Decimal(15, 2);
    paymentTerms        : String(100);
    deliveryLocation    : String(200);
    status              : String(20) default 'CREATED';
    
    items               : Composition of many PurchaseOrderItems on items.purchaseOrder = $self;
}

entity PurchaseOrderItems : cuid {
    key ID              : UUID;
    purchaseOrder       : Association to PurchaseOrders @mandatory;
    itemNumber          : Integer @mandatory;
    product             : Association to Products @mandatory;
    quantity            : Integer @mandatory;
    unitPrice           : Decimal(10, 2);
    totalPrice          : Decimal(15, 2);
    taxPercentage       : Decimal(5, 2);
    expectedDate        : Date;
}

entity InventoryRecords : cuid, managed {
    key ID              : UUID;
    product             : Association to Products @mandatory;
    location            : String(100);  // Central Warehouse, Hospital A
    batchNumber         : String(50) @mandatory;
    quantity            : Integer @mandatory;
    manufactureDate     : Date;
    expiryDate          : Date;
    status              : String(20) default 'AVAILABLE';  // AVAILABLE, RESERVED, DISPATCHED
    remarks             : String(200);
}
