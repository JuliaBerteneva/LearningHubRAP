@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Courses Projection'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity zlh_c_my_courses 
provider contract transactional_query
    as projection on zlh_r_my_courses
{
    key CourseId,
    key Userid,
    Name,
    Duration,
    Status,
    StatusText,
    Percentage,
    Percent,
    LastChangedAt,
    /* Associations */
    _materials : redirected to composition child zlh_c_my_course_materials,
    _user
}
