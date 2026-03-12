using InventoryService as service from '../../srv/service';

// ─────────────────────────────────────────────────────────────────────────────
// INVENTORY RECORDS — List Report + Object Page
// ─────────────────────────────────────────────────────────────────────────────

annotate service.InventoryRecords with @(

    // ── What shows in the LIST TABLE ─────────────────────────────────────────
    // Each Value maps to exact field names from schema.cds
    UI.LineItem                   : [
        {
            Value: productName,
            Label: 'Product'
        },
        {
            Value: genericName,
            Label: 'Generic Name'
        },
        {
            Value: location,
            Label: 'Location'
        },
        {
            Value: batchNumber,
            Label: 'Batch No.'
        },
        {
            Value: quantity,
            Label: 'Total Qty'
        },
        {
            Value: quantityOnHand,
            Label: 'On Hand'
        },
        {
            Value: reservedQuantity,
            Label: 'Reserved'
        },
        {
            Value: dispatchedQuantity,
            Label: 'Dispatched'
        },
        {
            Value: expiryDate,
            Label: 'Expiry Date'
        },
        {
            Value: status,
            Label: 'Status'
        },
        // Action buttons shown as columns in the table
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'InventoryService.reserve',
            Label : 'Reserve'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'InventoryService.dispatch',
            Label : 'Dispatch'
        }
    ],

    // ── Filter fields shown in the LEFT SIDEBAR ───────────────────────────────
    UI.SelectionFields            : [
        productName,
        location,
        status,
        expiryDate
    ],

    // ── OBJECT PAGE header (shown when you click a row) ───────────────────────
    UI.HeaderInfo                 : {
        TypeName      : 'Inventory Record',
        TypeNamePlural: 'Inventory Records',
        Title         : {Value: productName},
        Description   : {Value: batchNumber}
    },

    // ── Small info cards shown in the header area of Object Page ─────────────
    UI.HeaderFacets               : [{
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#StatusInfo',
        Label : 'Status'
    }],

    // ── TABS/SECTIONS on the Object Page ─────────────────────────────────────
    UI.Facets                     : [
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#ProductDetails',
            Label : 'Product Details'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.FieldGroup#QuantityDetails',
            Label : 'Quantity Details'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: 'movements/@UI.LineItem',
            Label : 'Movement History'
        }
    ],

    // ── Fields inside "Product Details" tab ──────────────────────────────────
    UI.FieldGroup #ProductDetails : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                Value: productName,
                Label: 'Product Name'
            },
            {
                Value: genericName,
                Label: 'Generic Name'
            },
            {
                Value: uom,
                Label: 'Unit of Measure'
            },
            {
                Value: location,
                Label: 'Location'
            },
            {
                Value: batchNumber,
                Label: 'Batch Number'
            },
            {
                Value: manufactureDate,
                Label: 'Manufacture Date'
            },
            {
                Value: expiryDate,
                Label: 'Expiry Date'
            },
            {
                Value: storageCondition,
                Label: 'Storage Condition'
            },
            {
                Value: remarks,
                Label: 'Remarks'
            }
        ]
    },

    // ── Fields inside "Quantity Details" tab ─────────────────────────────────
    UI.FieldGroup #QuantityDetails: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                Value: quantity,
                Label: 'Total Quantity'
            },
            {
                Value: quantityOnHand,
                Label: 'On Hand'
            },
            {
                Value: reservedQuantity,
                Label: 'Reserved'
            },
            {
                Value: dispatchedQuantity,
                Label: 'Dispatched'
            }
        ]
    },

    // ── Small status card in header ───────────────────────────────────────────
    UI.FieldGroup #StatusInfo     : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            Value: status,
            Label: 'Status'
        }]
    }
);

// ─────────────────────────────────────────────────────────────────────────────
// INVENTORY MOVEMENTS — sub-table inside Object Page "Movement History" tab
// ─────────────────────────────────────────────────────────────────────────────
annotate service.InventoryMovements with @(UI.LineItem: [
    {
        Value: movementType,
        Label: 'Type'
    },
    {
        Value: quantity,
        Label: 'Quantity'
    },
    {
        Value: quantityBefore,
        Label: 'Qty Before'
    },
    {
        Value: quantityAfter,
        Label: 'Qty After'
    },
    {
        Value: fromLocation,
        Label: 'From'
    },
    {
        Value: toLocation,
        Label: 'To'
    },
    {
        Value: reason,
        Label: 'Reason'
    },
    {
        Value: performedBy,
        Label: 'Performed By'
    },
    {
        Value: referenceDoc,
        Label: 'Reference Doc'
    }
]);

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTS — for reference (used in dropdowns)
// ─────────────────────────────────────────────────────────────────────────────
annotate service.Products with @(
    UI.LineItem  : [
        {
            Value: productID,
            Label: 'Product ID'
        },
        {
            Value: productName,
            Label: 'Product Name'
        },
        {
            Value: category,
            Label: 'Category'
        },
        {
            Value: genericName,
            Label: 'Generic Name'
        },
        {
            Value: uom,
            Label: 'UOM'
        },
        {
            Value: status,
            Label: 'Status'
        }
    ],

    UI.HeaderInfo: {
        TypeName      : 'Product',
        TypeNamePlural: 'Products',
        Title         : {Value: productName},
        Description   : {Value: genericName}
    }
);