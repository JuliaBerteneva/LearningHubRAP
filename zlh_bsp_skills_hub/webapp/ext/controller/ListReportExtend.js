sap.ui.define([
    "./ListReportExtend.controller"
], function (ListReportExtend) {
    "use strict";

    // Some dev-preview tooling resolves controller extensions without the ".controller"
    // suffix, unlike the standard UI5 controller loader; this re-exports the same class
    // under both module names so it loads either way.
    return ListReportExtend;
});
