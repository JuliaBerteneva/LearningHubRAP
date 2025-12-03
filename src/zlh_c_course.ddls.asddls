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
    @ObjectModel.text.element: [ 'SkillCategoryDescription' ]
    SkillCategory,
    @Semantics.text: true
    _skillCategory.Description as SkillCategoryDescription,
    @ObjectModel.text.element: [ 'TypeDescription' ]
    Type,
    @Semantics.text: true
    _courseType.Description as TypeDescription,
    @ObjectModel.text.element: [ 'ModeratorName' ]
    Moderator,
    @Semantics.text: true
    _moderator.FullName as ModeratorName,
    Duration,
    Released,
    LocalCreatedAt,
    @ObjectModel.text.element: [ 'CreatedByName' ]
    LocalCreatedBy,
    @Semantics.text: true
    _createdBy.FullName as CreatedByName,
    LocalLastChangedAt,
    @ObjectModel.text.element: [ 'ChangedByName' ]
    LocalLastChangedBy,
    @Semantics.text: true
    _changedBy.FullName as ChangedByName,
    LastChangedAt,
    /* Associations */
    _moderator,
    _createdBy,
    _changedBy,
    _courseType,
    _materials : redirected to composition child zlh_c_material
}
