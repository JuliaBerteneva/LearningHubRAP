@AbapCatalog.sqlViewName: 'ZLHIUSRMTRL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User-Material connection'
@Metadata.ignorePropagatedAnnotations: true
define view zlh_i_user_material 
as select from zlh_user_mtrl as user
join zlh_i_material as material on material.MaterialId = user.materialid
left outer join ZLH_I_STATUS_VH as status on status.Value = user.status
{
    key user.userid as Userid,
    key material.MaterialId as Materialid,
    user.status as Status,
    status.Description as StatusText,
    material.CourseId,
    material.Type,
    material.Name,
    material.Duration,
    material.Content,
    user.last_changed_at as LastChangedAt
}
