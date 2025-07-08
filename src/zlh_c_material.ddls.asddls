@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material projection'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity zlh_c_material 
as projection on zlh_r_material
{
    key CourseId,
    key MaterialId,
    MaterialKey,
    Type,
    Name,
    Duration,
    Content,
    LastChangedAt,
    /* Associations */
    _course : redirected to parent zlh_c_course
}
