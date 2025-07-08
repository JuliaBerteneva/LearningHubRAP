@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Course projection'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity zlh_c_course
provider contract transactional_query
as projection on zlh_r_course
{
    key CourseId,
    CourseKey,
    Name,
    Moderator,
    Duration,
    LocalCreatedAt,
    LocalCreatedBy,
    LocalLastChangedAt,
    LocalLastChangedBy,
    LastChangedAt,
    /* Associations */
    _materials : redirected to composition child zlh_c_material
}
