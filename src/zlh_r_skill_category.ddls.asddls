@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skill Category'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zlh_r_skill_category
  as select from zlh_i_skill_category
  composition [1..*] of ZLH_R_SKILL_CATEGORY_TEXT  as _text
{
      @ObjectModel.text.association: '_text'
  key CategoryId,
      CategoryKey,
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
      _text
}
