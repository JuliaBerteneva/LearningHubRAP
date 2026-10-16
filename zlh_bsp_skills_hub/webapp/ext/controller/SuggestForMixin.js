sap.ui.define([
    "sap/ui/core/Fragment",
    "sap/m/MessageToast"
], function (Fragment, MessageToast) {
    "use strict";

    // Shared by ListReportExtend (multiple selected rows) and ObjectPageExtend (the current
    // object) - both just resolve their own contexts, then open the same dialog and invoke
    // the same action through this mixin.
    return {
        suggestForOpen: function (aContexts) {
            if (!aContexts.length) {
                MessageToast.show(this._getText("suggestForNoColleagueSelected"));
                return;
            }

            this._aSuggestForContexts = aContexts;

            this._getSuggestForDialog().then(function (oDialog) {
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
                contexts: this._aSuggestForContexts,
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
            this._oSuggestForDialog.close();
        },

        onSuggestForCancel: function () {
            Fragment.byId(this.base.getView().getId(), "suggestForColleaguesInput").setSelectedKeys([]);
            this._oSuggestForDialog.close();
        },

        _getSuggestForDialog: function () {
            var oView = this.base.getView();

            if (!this._pSuggestForDialog) {
                this._pSuggestForDialog = Fragment.load({
                    id: oView.getId(),
                    name: "zlhbspskillshub.ext.fragment.SuggestForDialog",
                    controller: this
                }).then(function (oDialog) {
                    this._oSuggestForDialog = oDialog;
                    oView.addDependent(oDialog);
                    return oDialog;
                }.bind(this));
            }

            return this._pSuggestForDialog;
        },

        _getText: function (sKey) {
            return this.base.getView().getModel("i18n").getResourceBundle().getText(sKey);
        }
    };
});
