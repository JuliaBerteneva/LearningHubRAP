@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Course Materials Projection'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity zlh_c_my_course_materials
  as projection on zlh_r_my_course_materials
{
  key Materialid,
  key Userid,
      CourseId,
      Name,
      Duration,
      Status,
      Content,
      StartDate,
      EndDate,
      LastChangedAt,
      /* Associations */
      _course : redirected to parent zlh_c_my_courses
}
