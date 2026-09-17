sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'myskills',
            componentId: 'zlh_c_my_skillsObjectPage',
            contextPath: '/zlh_c_my_skills'
        },
        CustomPageDefinitions
    );
});