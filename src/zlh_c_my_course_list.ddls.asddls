@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'List for Overview page'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_c_my_course_list
  as select from zlh_i_my_courses
  association to ZLH_I_STATUS_VH as _status on _status.Value = $projection.Status
{
  key CourseId,
      @ObjectModel.text.association: '_status'
      Status,
      Percentage,
      Percent,
      Name,
      case Status
        when 'NOTSTARTED' then 0
        when 'IN PROCESS' then 2
        when 'CANCELLED' then 1
        when 'FINISHED' then 3
        else 0 end as Criticality,
      _status
}
