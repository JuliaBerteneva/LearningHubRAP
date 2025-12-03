@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cousre Business object'
@Metadata.ignorePropagatedAnnotations: false
define root view entity zlh_r_course
  as select from zlh_i_course
  association to ZLH_I_course_TYPE_VH  as _courseType on _courseType.Value = $projection.Type
  association to zlh_i_skill_category_vh  as _skillCategory on _skillCategory.Value = $projection.SkillCategory
association [1..1] to ZLH_I_Moderator_info as _moderator on _moderator.UserId = $projection.Moderator
  composition [1..*] of zlh_r_material as _materials
{
  key CourseId,
      CourseKey,
      Name,
      @Consumption.valueHelpDefinition: [{entity: {name: 'zlh_i_course_type_vh', element: 'Value' }, useForValidation: true }]
      @ObjectModel.text.association: '_courseType'
      Type,
      @Consumption.valueHelpDefinition: [{entity: {name: 'zlh_i_skill_category_vh', element: 'Value' }, useForValidation: true }]
      @ObjectModel.text.association: '_skillCategory'
      SkillCategory,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZLH_I_Moderator_info', element: 'UserId' }, useForValidation: true }]
      @ObjectModel.text.association: '_moderator'
      Moderator,
      Duration,
      Released,
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
      _materials,
      _moderator,
      _createdBy,
      _changedBy,
      _courseType,
      _skillCategory
}
