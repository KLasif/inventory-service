using { tracemeds.db as db } from '../db/schema';

@(requires:'authenticated-user')
service InventoryService {

    @(restrict:[
        { grant: ['CREATE','READ','UPDATE','DELETE'], to: 'InventoryManager'    },
        { grant: ['READ'],                            to: 'HospitalUser'        },
        { grant: ['READ'],                            to: 'ProcurementOfficer'  },
        { grant: ['CREATE','READ','UPDATE','DELETE'], to: 'SystemAdmin'         }
    ])
    entity InventoryRecords as projection on db.InventoryRecords {
        *,
        @readonly @mandatory: false product.productName      as productName,
        @readonly @mandatory: false product.genericName      as genericName,
        @readonly @mandatory: false product.uom              as uom,
        @readonly @mandatory: false product.storageCondition as storageCondition,
        movements : redirected to InventoryMovements
    } actions {
        @(requires: ['InventoryManager', 'SystemAdmin'])
        action reserve(quantity: Integer)                     returns InventoryRecords;

        @(requires: ['InventoryManager', 'SystemAdmin'])
        action release(quantity: Integer)                     returns InventoryRecords;

        @(requires: ['InventoryManager', 'SystemAdmin'])
        action dispatch(quantity: Integer)                    returns InventoryRecords;

        @(requires: ['InventoryManager', 'SystemAdmin'])
        action adjustStock(quantity: Integer, reason: String) returns InventoryRecords;
    };

    @(restrict:[
        { grant: ['CREATE','READ','UPDATE','DELETE'], to: 'InventoryManager'    },
        { grant: ['READ'],                            to: 'HospitalUser'        },
        { grant: ['READ'],                            to: 'ProcurementOfficer'  },
        { grant: ['CREATE','READ','UPDATE','DELETE'], to: 'SystemAdmin'         }
    ])
    entity InventoryMovements as projection on db.InventoryMovements;

    @(restrict:[
        { grant: ['CREATE','READ','UPDATE','DELETE'], to: 'InventoryManager'   },
        { grant: ['READ'],                            to: 'HospitalUser'       },
        { grant: ['READ'],                            to: 'ProcurementOfficer' },
        { grant: ['CREATE','READ','UPDATE','DELETE'], to: 'SystemAdmin'        }
    ])
    entity Products as projection on db.Products;

    @(requires: ['InventoryManager','ProcurementOfficer','SystemAdmin'])
    function getAvailableStock(productID: String, location: String) returns Integer;

    @(requires: ['InventoryManager','SystemAdmin'])
    function getExpiringBatches(withinDays: Integer) returns array of InventoryRecords;

    @(requires: ['InventoryManager','ProcurementOfficer','SystemAdmin'])
    function getStockByLocation(location: String) returns array of InventoryRecords;

    @(requires: ['InventoryManager','ProcurementOfficer','SystemAdmin'])
    function getLowStockProducts(threshold: Integer) returns array of {
        productID    : String;
        productName  : String;
        location     : String;
        currentStock : Integer;
        threshold    : Integer;
    };

    @(requires: ['InventoryManager','SystemAdmin'])
    function getInventorySummary() returns {
        totalProducts      : Integer;
        totalQuantity      : Integer;
        availableQuantity  : Integer;
        reservedQuantity   : Integer;
        dispatchedQuantity : Integer;
        expiringIn30Days   : Integer;
    };
}
