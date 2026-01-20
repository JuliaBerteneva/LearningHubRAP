@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User-Skill connection'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_i_user_skill
  as select from zlh_user_skill as _main
    join         zlh_skills     as _description on  _description.skill_id = _main.skill_id
{
  key _main.uname as UserId,
  key _main.skill_id as SkillId,
      _description.name as SkillName,
      _description.description as Description,
      _description.category as Category
}
