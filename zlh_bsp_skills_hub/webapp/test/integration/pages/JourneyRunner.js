sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"zlhbspskillshub/test/integration/pages/zlh_c_skillList.gen",
	"zlhbspskillshub/test/integration/pages/zlh_c_skillObjectPage.gen"
], function (JourneyRunner, zlh_c_skillListGenerated, zlh_c_skillObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('zlhbspskillshub') + '/test/flp.html#app-preview',
        pages: {
			onThezlh_c_skillListGenerated: zlh_c_skillListGenerated,
			onThezlh_c_skillObjectPageGenerated: zlh_c_skillObjectPageGenerated
        },
        async: true
    });

    return runner;
});

