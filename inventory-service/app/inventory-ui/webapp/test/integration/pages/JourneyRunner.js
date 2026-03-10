sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"inventoryui/test/integration/pages/InventoryRecordsMain"
], function (JourneyRunner, InventoryRecordsMain) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('inventoryui') + '/test/flpSandbox.html#inventoryui-tile',
        pages: {
			onTheInventoryRecordsMain: InventoryRecordsMain
        },
        async: true
    });

    return runner;
});

