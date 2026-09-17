sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'myskills',
            componentId: 'zlh_c_my_skillsList',
            contextPath: '/zlh_c_my_skills'
        },
        CustomPageDefinitions
    );
});