@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skill Category'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_i_skill_category
  as select from zlh_skill_categ
  association [1..1] to ZLH_I_SKILL_CATEGORY_TEXT as _text on $projection.CategoryId = _text.CategoryId
                                                           and _text.Language = $session.system_language
{
  key category_id as CategoryId,
      category_key as CategoryKey,
      _text.Name,
      created_by as CreatedBy,
      created_at as CretedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,
      _text
}
