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
{
    key CourseId,
    Status,
    StatusText,
    @DefaultAggregation: #SUM
    1 as TotalAmount
}
