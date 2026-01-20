@AbapCatalog.sqlViewName: 'ZLHIUSRCRS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User-Course connection'
@Metadata.ignorePropagatedAnnotations: false
define view  zlh_i_user_course 
as select from zlh_user_course as user
join zlh_i_course as course on course.CourseId = user.courseid
left outer join ZLH_I_STATUS_VH as status on status.Value = user.status
{
    key user.userid as Userid,
    key course.CourseId,
    course.Name,
    course.Type,
    course.SkillCategory,
    course.Moderator,
    course.Duration,
    user.status as Status,
    status.Description as StatusText,
    @Semantics.quantity.unitOfMeasure: 'Percent'
    user.percentage as Percentage,
    @Semantics.unitOfMeasure: true
    cast ( '%' as abap.unit( 3 ) ) as Percent,
    user.start_date as StartDate,
    user.end_date as EndDate,
    user.last_changed_at as LastChangedAt
}
