@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skill Category'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZLH_I_SKILL_CATEGORY_TEXT
  as select from zlh_skill_categt
{
  key category_id as CategoryId,
  key language    as Language,
      category_key as CategoryKey,
      name        as Name,
      created_by as CreatedBy,
      created_at as CretedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt
}
