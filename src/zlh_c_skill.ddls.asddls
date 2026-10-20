@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skills Consumption'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true

define root view entity zlh_c_skill
  provider contract transactional_query
  as projection on zlh_r_skill
{
  key SkillId,
      Name,
      @Semantics.text: true
      Description,
      @ObjectModel.text.element: [ 'Description' ]
      Category,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @EndUserText.label: 'Acquired By Me'
      AcquiredByMe,
      @EndUserText.label: 'Proposed for Learning'
      ProposedForLearning,
      Scale,
      @EndUserText.label: 'Want to Learn'
      WantToLearn,

      @EndUserText.label: 'Category Name'
      CategoryName
      /* Associations */
      //    _category
}
