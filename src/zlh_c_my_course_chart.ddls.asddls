@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chart consumption'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_c_my_course_chart
  as select from zlh_i_my_courses
  association to ZLH_I_STATUS_VH as _status on _status.Value = $projection.Status
{
  key CourseId,
      @ObjectModel.text.association: '_status'
      Status,
      @DefaultAggregation: #SUM
      1 as TotalAmount,
      _status
}
