@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Materials BO'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_r_my_course_materials as select from zlh_i_my_crsmtrl
association to parent zlh_r_my_courses as _course on _course.CourseId = $projection.CourseId and 
                                                     _course.Userid = $projection.Userid
{
    key Materialid,
    key Userid,
    CourseId,
    Name,
    Duration,
    @Consumption.valueHelpDefinition: [{ entity : { name : 'zlh_i_status_vh', element : 'Description' } } ]
    Status,
    StatusText,
    Content,
    LastChangedAt,
    _course
}
