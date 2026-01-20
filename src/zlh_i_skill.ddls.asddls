@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skills'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_i_skill
  as select from zlh_skills
{
  key skill_id    as SkillId,
      name        as Name,
      description as Description,
      category    as Category,
      created_by as CreatedBy,
      created_at as CretedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt
}
