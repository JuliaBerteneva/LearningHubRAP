sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"zlhbspmycourses/test/integration/pages/zlh_c_my_coursesList.gen",
	"zlhbspmycourses/test/integration/pages/zlh_c_my_coursesObjectPage.gen",
	"zlhbspmycourses/test/integration/pages/zlh_c_my_course_materialsObjectPage.gen"
], function (JourneyRunner, zlh_c_my_coursesListGenerated, zlh_c_my_coursesObjectPageGenerated, zlh_c_my_course_materialsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('zlhbspmycourses') + '/test/flp.html#app-preview',
        pages: {
			onThezlh_c_my_coursesListGenerated: zlh_c_my_coursesListGenerated,
			onThezlh_c_my_coursesObjectPageGenerated: zlh_c_my_coursesObjectPageGenerated,
			onThezlh_c_my_course_materialsObjectPageGenerated: zlh_c_my_course_materialsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

