sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"zlhbspskillscategory/test/integration/pages/zlh_c_skill_categoryList.gen",
	"zlhbspskillscategory/test/integration/pages/zlh_c_skill_categoryObjectPage.gen"
], function (JourneyRunner, zlh_c_skill_categoryListGenerated, zlh_c_skill_categoryObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('zlhbspskillscategory') + '/test/flp.html#app-preview',
        pages: {
			onThezlh_c_skill_categoryListGenerated: zlh_c_skill_categoryListGenerated,
			onThezlh_c_skill_categoryObjectPageGenerated: zlh_c_skill_categoryObjectPageGenerated
        },
        async: true
    });

    return runner;
});

