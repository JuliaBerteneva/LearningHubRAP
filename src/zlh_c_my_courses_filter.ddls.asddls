@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Filter view for overview page'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_c_my_courses_filter 
as select from zlh_i_my_courses
association to ZLH_I_STATUS_VH as _status on _status.Value = $projection.Status
{   
    key CourseId,
    Percentage,
    Percent,
    Userid,
    Name,
    Type,
    Moderator,
    Duration,
    @Consumption.valueHelpDefinition: [{ entity : { name : 'zlh_i_status_vh', element : 'Description' } } ]
    @UI.selectionField: [{ position : 10 }]
    @ObjectModel.text.association: '_status'
    Status,
    _status
}
