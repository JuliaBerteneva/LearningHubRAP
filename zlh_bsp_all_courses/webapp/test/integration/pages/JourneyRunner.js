sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"zlhbspallcourses/test/integration/pages/zlh_c_courseList.gen",
	"zlhbspallcourses/test/integration/pages/zlh_c_courseObjectPage.gen",
	"zlhbspallcourses/test/integration/pages/zlh_c_materialObjectPage.gen"
], function (JourneyRunner, zlh_c_courseListGenerated, zlh_c_courseObjectPageGenerated, zlh_c_materialObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('zlhbspallcourses') + '/test/flp.html#app-preview',
        pages: {
			onThezlh_c_courseListGenerated: zlh_c_courseListGenerated,
			onThezlh_c_courseObjectPageGenerated: zlh_c_courseObjectPageGenerated,
			onThezlh_c_materialObjectPageGenerated: zlh_c_materialObjectPageGenerated
        },
        async: true
    });

    return runner;
});

