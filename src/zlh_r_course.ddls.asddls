@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cousre Business object'
@Metadata.ignorePropagatedAnnotations: false
define root view entity zlh_r_course
  as select from zlh_i_course
  composition [1..*] of zlh_r_material as _materials
{
  key CourseId,
      CourseKey,
      Name,
      Moderator,
      Duration,
      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @EndUserText.label: 'Changed At'
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @EndUserText.label: 'Changed By'
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @EndUserText.label: 'Changed At'
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      _materials
}
