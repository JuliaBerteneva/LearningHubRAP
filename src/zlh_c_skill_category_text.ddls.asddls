@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skill Category'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZLH_c_SKILL_CATEGORY_TEXT
  as projection on ZLH_R_SKILL_CATEGORY_TEXT
{
      @ObjectModel.text.element : ['Name']
  key CategoryId,
      @Semantics.language: true
  key Language,
      CategoryKey,
      @Semantics.text: true
      Name,
      CreatedBy,
      CretedAt,
      LastChangedBy,
      LastChangedAt,
      _category : redirected to parent zlh_c_skill_category
}
