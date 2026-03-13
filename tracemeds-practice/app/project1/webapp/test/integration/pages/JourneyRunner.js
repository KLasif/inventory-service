sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"project1/test/integration/pages/InventoryRecordsList",
	"project1/test/integration/pages/InventoryRecordsObjectPage"
], function (JourneyRunner, InventoryRecordsList, InventoryRecordsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('project1') + '/test/flpSandbox.html#project1-tile',
        pages: {
			onTheInventoryRecordsList: InventoryRecordsList,
			onTheInventoryRecordsObjectPage: InventoryRecordsObjectPage
        },
        async: true
    });

    return runner;
});

