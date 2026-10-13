sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/core/Fragment",
    "sap/m/MessageToast"
], function (ControllerExtension, Fragment, MessageToast) {
    "use strict";

    return ControllerExtension.extend("zlhbspskillshub.ext.controller.ListReportExtend", {
        onSuggestFor: function () {
            var oExtensionAPI = this.base.getExtensionAPI(),
                aSelectedContexts = oExtensionAPI.getSelectedContexts();

            if (!aSelectedContexts.length) {
                MessageToast.show(this._getText("suggestForNoColleagueSelected"));
                return;
            }

            this._aSelectedContexts = aSelectedContexts;

            this._getDialog().then(function (oDialog) {
                oDialog.open();
            });
        },

        onSuggestForConfirm: function () {
            var oMultiComboBox = Fragment.byId(this.base.getView().getId(), "suggestForColleaguesInput"),
                aSelectedKeys = oMultiComboBox.getSelectedKeys();

            if (!aSelectedKeys.length) {
                MessageToast.show(this._getText("suggestForNoColleagueSelected"));
                return;
            }

            // Backend action only evaluates the "Colleague" key of each entry (zbp_lh_r_skill->suggestFor);
            // TeamLead/FullName are declared non-nullable in the OData type but unused server-side.
            // All declared parameters must be supplied, otherwise EditFlow falls back to its own dialog
            // despite skipParameterDialog.
            this.base.editFlow.invokeAction("com.sap.gateway.srvd.zlh_skills.v0001.suggestFor", {
                contexts: this._aSelectedContexts,
                skipParameterDialog: true,
                parameterValues: [{
                    name: "TeamLead",
                    value: ""
                }, {
                    name: "_Colleagues",
                    value: aSelectedKeys.map(function (sKey) {
                        return { Colleague: sKey, FullName: "", TeamLead: "" };
                    })
                }]
            });

            oMultiComboBox.setSelectedKeys([]);
            this._oDialog.close();
        },

        onSuggestForCancel: function () {
            Fragment.byId(this.base.getView().getId(), "suggestForColleaguesInput").setSelectedKeys([]);
            this._oDialog.close();
        },

        _getDialog: function () {
            var oView = this.base.getView();

            if (!this._pDialog) {
                this._pDialog = Fragment.load({
                    id: oView.getId(),
                    name: "zlhbspskillshub.ext.fragment.SuggestForDialog",
                    controller: this
                }).then(function (oDialog) {
                    this._oDialog = oDialog;
                    oView.addDependent(oDialog);
                    return oDialog;
                }.bind(this));
            }

            return this._pDialog;
        },

        _getText: function (sKey) {
            return this.base.getView().getModel("i18n").getResourceBundle().getText(sKey);
        }
    });
});
