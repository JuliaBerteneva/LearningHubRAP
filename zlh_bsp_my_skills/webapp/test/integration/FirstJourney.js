sap.ui.define([
    "sap/ui/test/opaQunit"
], function (opaTest) {
    "use strict";

    var Journey = {
        run: function() {
            QUnit.module("First journey");

            opaTest("Start application", function (Given, When, Then) {
                Given.iStartMyApp();

                Then.onThezlh_c_my_skillsList.iSeeThisPage();

            });


            opaTest("Navigate to ObjectPage", function (Given, When, Then) {
                // Note: this test will fail if the ListReport page doesn't show any data
                
                When.onThezlh_c_my_skillsList.onFilterBar().iExecuteSearch();
                
                Then.onThezlh_c_my_skillsList.onTable().iCheckRows();

                When.onThezlh_c_my_skillsList.onTable().iPressRow(0);
                Then.onThezlh_c_my_skillsObjectPage.iSeeThisPage();

            });

            opaTest("Teardown", function (Given, When, Then) { 
                // Cleanup
                Given.iTearDownMyApp();
            });
        }
    }

    return Journey;
});