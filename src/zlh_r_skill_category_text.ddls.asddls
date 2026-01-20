@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skill Category'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZLH_R_SKILL_CATEGORY_TEXT
  as select from ZLH_I_SKILL_CATEGORY_TEXT as _text
  association to parent zlh_r_skill_category as _category on $projection.CategoryId = _category.CategoryId 
{
      @ObjectModel.text.element : ['Name']
  key CategoryId,
      @Semantics.language: true
  key Language,
      CategoryKey,
      @Semantics.text: true
      Name,
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
