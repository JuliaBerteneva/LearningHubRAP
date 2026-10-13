sap.ui.define(
    ["sap/ovp/app/Component", "sap/ui/model/odata/v4/ODataMetaModel"],
    function (Component, ODataMetaModel) {
        "use strict";

        // Polyfill: this ABAP system ships sap.ovp 1.120.7, whose getViewSettings()
        // still calls the OData V2-only metamodel method getODataEntitySet() even for
        // V4 apps (globalFilterEntitySet processing), crashing the whole app on init.
        // Add a minimal V4-compatible shim instead of waiting for a library patch.
        if (ODataMetaModel.prototype && !ODataMetaModel.prototype.getODataEntitySet) {
            // Known entity types, used as a fallback when $metadata hasn't finished
            // loading yet at the point this legacy code path runs (V4 metadata loads
            // asynchronously, unlike V2, so getObject() can race the metadata request).
            var mKnownEntityTypes = {
                "zlh_c_my_courses_filter": "com.sap.gateway.srvd.zlh_personal_growth.v0001.zlh_c_my_courses_filterType"
            };

            ODataMetaModel.prototype.getODataEntitySet = function (sEntitySetName) {
                var oEntitySet;
                try {
                    oEntitySet = this.getObject("/" + sEntitySetName);
                } catch (e) {
                    oEntitySet = undefined;
                }
                var sEntityType = (oEntitySet && oEntitySet.$Type) || mKnownEntityTypes[sEntitySetName];
                return sEntityType ? { entityType: sEntityType } : undefined;
            };
        }

        return Component.extend("zlhbspmylearning.Component", {
            metadata: {
                manifest: "json"
            }
        });
    }
);
