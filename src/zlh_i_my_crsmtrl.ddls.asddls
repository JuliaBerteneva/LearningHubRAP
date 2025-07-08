@AbapCatalog.sqlViewName: 'ZLHIMYCRSMTRL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Materials inside the course'
@Metadata.ignorePropagatedAnnotations: true
define view zlh_i_my_crsmtrl 
as select from zlh_i_user_material as user
{   
    key user.Materialid,
    user.CourseId,
    user.Type,
    user.Name,
    user.Duration,
    user.Content,
    user.Status,
    user.StatusText,
    user.Userid,
    user.LastChangedAt
} where user.Userid = $session.user
