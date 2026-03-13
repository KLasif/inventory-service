using InventoryService as service from '../../srv/service';
annotate service.InventoryRecords with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'product_productID',
                Value : product_productID,
            },
            {
                $Type : 'UI.DataField',
                Label : 'location',
                Value : location,
            },
            {
                $Type : 'UI.DataField',
                Label : 'batchNumber',
                Value : batchNumber,
            },
            {
                $Type : 'UI.DataField',
                Label : 'quantity',
                Value : quantity,
            },
            {
                $Type : 'UI.DataField',
                Label : 'quantityOnHand',
                Value : quantityOnHand,
            },
            {
                $Type : 'UI.DataField',
                Label : 'reservedQuantity',
                Value : reservedQuantity,
            },
            {
                $Type : 'UI.DataField',
                Label : 'dispatchedQuantity',
                Value : dispatchedQuantity,
            },
            {
                $Type : 'UI.DataField',
                Label : 'manufactureDate',
                Value : manufactureDate,
            },
            {
                $Type : 'UI.DataField',
                Label : 'expiryDate',
                Value : expiryDate,
            },
            {
                $Type : 'UI.DataField',
                Label : 'status',
                Value : status,
            },
            {
                $Type : 'UI.DataField',
                Label : 'remarks',
                Value : remarks,
            },
            {
                $Type : 'UI.DataField',
                Label : 'productName',
                Value : productName,
            },
            {
                $Type : 'UI.DataField',
                Label : 'genericName',
                Value : genericName,
            },
            {
                $Type : 'UI.DataField',
                Label : 'uom',
                Value : uom,
            },
            {
                $Type : 'UI.DataField',
                Label : 'storageCondition',
                Value : storageCondition,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'product_productID',
            Value : product_productID,
        },
        {
            $Type : 'UI.DataField',
            Label : 'location',
            Value : location,
        },
        {
            $Type : 'UI.DataField',
            Label : 'batchNumber',
            Value : batchNumber,
        },
        {
            $Type : 'UI.DataField',
            Label : 'quantity',
            Value : quantity,
        },
        {
            $Type : 'UI.DataField',
            Label : 'quantityOnHand',
            Value : quantityOnHand,
        },
    ],
);

annotate service.InventoryRecords with {
    product @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Products',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : product_productID,
                ValueListProperty : 'productID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'productName',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'category',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'subCategory',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'genericName',
            },
        ],
    }
};

