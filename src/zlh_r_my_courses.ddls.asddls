@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Courses BO'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zlh_r_my_courses 
as select from zlh_i_my_courses as course
association to zlh_i_my_info as _user on _user.UserId = $projection.Userid
composition [1..*] of zlh_r_my_course_materials as _materials
{   
    key CourseId,
    key Userid,
    Moderator,
    Name,
    Duration,
    @Consumption.valueHelpDefinition: [{ entity : { name : 'zlh_i_status_vh', element : 'Description' } } ]
    Status,
    StatusText,
    Percentage,
    Percent,
    LastChangedAt,
    _user,
    _materials
}
