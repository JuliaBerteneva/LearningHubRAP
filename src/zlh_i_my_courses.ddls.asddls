@AbapCatalog.sqlViewName: 'ZLHIMYCRSS'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Courses List'
@Metadata.ignorePropagatedAnnotations: false
define view zlh_i_my_courses 
as select from zlh_i_user_course as user
{   
    key user.CourseId,
    user.Status,
    user.StatusText,
    Percentage,
    Percent,
    user.Userid,
    user.Name,
    user.Type,
    user.SkillCategory,
    user.Moderator,
    user.Duration,
    user.StartDate,
    user.EndDate,
    user.LastChangedAt
} where user.Userid = $session.user
