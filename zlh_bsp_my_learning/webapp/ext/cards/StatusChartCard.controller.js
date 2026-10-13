sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    function stateForStatus(sStatus) {
        if (!sStatus) {
            return "None";
        }
        if (sStatus.indexOf("FINISH") !== -1) {
            return "Success";
        }
        if (sStatus.indexOf("PROCESS") !== -1) {
            return "Warning";
        }
        return "Information";
    }

    return Controller.extend("zlhbspmylearning.ext.cards.StatusChartCard", {
        onInit: function () {
            var sUrl = "/sap/opu/odata4/sap/zlh_personal_growth/srvd/sap/zlh_personal_growth/0001/" +
                "zlh_c_my_course_chart?$apply=groupby((Status,Status_Text),aggregate(TotalAmount with sum as TotalAmountAggregate))";

            var oModel = new JSONModel({ items: [] });
            this.getView().setModel(oModel, "statusChart");

            fetch(sUrl, {
                headers: { "Accept": "application/json" },
                credentials: "same-origin"
            }).then(function (oResponse) {
                return oResponse.json();
            }).then(function (oData) {
                var aRows = (oData && oData.value) || [];
                var iTotal = aRows.reduce(function (iSum, oRow) {
                    return iSum + Number(oRow.TotalAmountAggregate || 0);
                }, 0);

                var aItems = aRows.map(function (oRow) {
                    var iCount = Number(oRow.TotalAmountAggregate || 0);
                    return {
                        status: oRow.Status,
                        statusText: oRow.Status_Text || oRow.Status,
                        count: iCount,
                        percent: iTotal ? Math.round((iCount / iTotal) * 100) : 0,
                        state: stateForStatus(oRow.Status)
                    };
                });

                oModel.setProperty("/items", aItems);
                oModel.setProperty("/total", iTotal);
            }).catch(function () {
                oModel.setProperty("/items", []);
                oModel.setProperty("/total", 0);
            });
        }
    });
});
