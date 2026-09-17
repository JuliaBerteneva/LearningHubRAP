sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'myskills/test/integration/FirstJourney',
		'myskills/test/integration/pages/zlh_c_my_skillsList',
		'myskills/test/integration/pages/zlh_c_my_skillsObjectPage'
    ],
    function(JourneyRunner, opaJourney, zlh_c_my_skillsList, zlh_c_my_skillsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('myskills') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onThezlh_c_my_skillsList: zlh_c_my_skillsList,
					onThezlh_c_my_skillsObjectPage: zlh_c_my_skillsObjectPage
                }
            },
            opaJourney.run
        );
    }
);