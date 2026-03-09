using { com.healthcare.tracemeds as db } from '../db/schema';

@path: '/odata/v4/indent'
service IndentService @(requires: 'HospitalUser') {

    @odata.draft.enabled
    entity Indents as projection on db.Indents {
        *,
        hospital.hospitalName as hospitalName,
        items : redirected to IndentItems
    } actions {
        action submit()                     returns Indents;
        action approve()                    returns Indents;
        action reject(reason: String)       returns Indents;
    };

    @readonly
    entity IndentItems as projection on db.IndentItems {
        *,
        product.productName as productName,
        product.uom         as uom
    };

    @readonly
    entity Hospitals as projection on db.Hospitals;

    @readonly
    entity Products  as projection on db.Products;

    // Functions
    function getIndentsByStatus(status: String) returns array of Indents;
    function getIndentStatistics() returns {
        totalIndents  : Integer;
        pending       : Integer;
        approved      : Integer;
        consolidated  : Integer;
    };
}

@path: '/odata/v4/po'
service POService @(requires: 'ProcurementOfficer') {

    @odata.draft.enabled
    entity PurchaseOrders as projection on db.PurchaseOrders {
        *,
        items : redirected to PurchaseOrderItems
    } actions {
        action sendToSupplier()             returns PurchaseOrders;
        action acknowledge()                returns PurchaseOrders;
        action markInProduction()           returns PurchaseOrders;
        action cancel(reason: String)       returns PurchaseOrders;
    };

    @readonly
    entity PurchaseOrderItems as projection on db.PurchaseOrderItems {
        *,
        product.productName as productName
    };

    @readonly
    entity Indents as projection on db.Indents {
        *,
        hospital.hospitalName as hospitalName
    };

    @readonly
    entity IndentItems as projection on db.IndentItems {
        *,
        product.productName as productName
    };

    @readonly
    entity Products  as projection on db.Products;

    // Functions
    function getApprovedIndents()                           returns array of Indents;
    function consolidateIndents(indentIDs: array of UUID)   returns PurchaseOrders;
    function getPOStatistics() returns {
        totalPOs      : Integer;
        created       : Integer;
        sent          : Integer;
        acknowledged  : Integer;
        inProduction  : Integer;
        shipped       : Integer;
        delivered     : Integer;
    };
}

@path: '/odata/v4/inventory'
service InventoryService @(requires: 'InventoryManager') {

    entity InventoryRecords as projection on db.InventoryRecords {
        *,
        product.productName  as productName,
        product.genericName  as genericName,
        product.uom          as uom
    } actions {
        action reserve(quantity: Integer)                   returns InventoryRecords;
        action release(quantity: Integer)                   returns InventoryRecords;
        action dispatch(quantity: Integer)                  returns InventoryRecords;
        action adjustStock(quantity: Integer, reason: String) returns InventoryRecords;
    };

    @readonly
    entity Products as projection on db.Products;

    // Functions
    function getAvailableStock(productID: String, location: String)     returns Integer;
    function getExpiringBatches(withinDays: Integer)                     returns array of InventoryRecords;
    function getStockByLocation(location: String)                        returns array of InventoryRecords;
    function getInventorySummary() returns {
        totalProducts       : Integer;
        totalQuantity       : Integer;
        availableQuantity   : Integer;
        reservedQuantity    : Integer;
        dispatchedQuantity  : Integer;
        expiringIn30Days    : Integer;
    };
}

@path: '/odata/v4/admin'
service AdminService @(requires: 'SystemAdmin') {

    // Full CRUD on master data
    entity Hospitals  as projection on db.Hospitals;
    entity Products   as projection on db.Products;

    // Read-only view across all transactional data
    @readonly
    entity Indents          as projection on db.Indents;

    @readonly
    entity PurchaseOrders   as projection on db.PurchaseOrders;

    @readonly
    entity InventoryRecords as projection on db.InventoryRecords;

    function getSystemStatistics() returns {
        totalHospitals      : Integer;
        activeHospitals     : Integer;
        totalSuppliers      : Integer;
        activeSuppliers     : Integer;
        totalProducts       : Integer;
        totalIndents        : Integer;
        totalPOs            : Integer;
        totalInventoryValue : Decimal;
    };
}
