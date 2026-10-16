sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "./SuggestForMixin"
], function (ControllerExtension, SuggestForMixin) {
    "use strict";

    return ControllerExtension.extend("zlhbspskillshub.ext.controller.ObjectPageExtend", Object.assign({
        onSuggestFor: function () {
            var oContext = this.base.getExtensionAPI().getBindingContext();

            this.suggestForOpen(oContext ? [oContext] : []);
        }
    }, SuggestForMixin));
});
