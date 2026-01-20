@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skill Category'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zlh_c_skill_category
  provider contract transactional_query
  as projection on zlh_r_skill_category
{
      @ObjectModel.text.element: [ 'Name' ]
  key CategoryId,
      CategoryKey,
      @Semantics.text: true
      _text.Name : localized,
      CreatedBy,
      CretedAt,
      LastChangedBy,
      LastChangedAt,
      _text : redirected to composition child ZLH_c_SKILL_CATEGORY_TEXT
}
