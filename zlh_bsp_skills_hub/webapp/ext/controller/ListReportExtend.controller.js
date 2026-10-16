sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "./SuggestForMixin"
], function (ControllerExtension, SuggestForMixin) {
    "use strict";

    return ControllerExtension.extend("zlhbspskillshub.ext.controller.ListReportExtend", Object.assign({
        onSuggestFor: function () {
            var oExtensionAPI = this.base.getExtensionAPI(),
                aSelectedContexts = oExtensionAPI.getSelectedContexts();

            this.suggestForOpen(aSelectedContexts);
        }
    }, SuggestForMixin));
});
