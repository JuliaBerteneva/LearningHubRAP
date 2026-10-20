@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skills'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zlh_r_skill
  as select from zlh_i_skill
{
  key SkillId,
      Name,
      Description,
//      @Consumption.valueHelpDefinition: [{entity: {name: 'ZLH_I_Moderator_info', element: 'UserId' }, useForValidation: true }]
      @ObjectModel.text.element: [ 'CategoryName' ]
      Category,
      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      CreatedBy,
      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @EndUserText.label: 'Changed By'
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @EndUserText.label: 'Changed At'
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      AcquiredByMe,
      ProposedForLearning,
      Scale,
      WantToLearn,
      coalesce( _category.Name, _category.CategoryKey ) as CategoryName,
      _category
}
