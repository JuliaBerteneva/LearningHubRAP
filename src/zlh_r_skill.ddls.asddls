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
  association [1..1] to zlh_i_skill_category as _category on  $projection.Category = _category.CategoryId
{
  key SkillId,
      Name,
      Description,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZLH_I_Moderator_info', element: 'UserId' }, useForValidation: true }]
      @ObjectModel.text.association: '_category'
      Category,
      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      CreatedBy,
      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      CretedAt,
      @EndUserText.label: 'Cchanged By'
      @Semantics.user.createdBy: true
      LastChangedBy,
      @EndUserText.label: 'Changed At'
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      _category
}
