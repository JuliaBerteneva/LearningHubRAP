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
  association [0..1] to zlh_user_skill as _MySkillData on  _MySkillData.skill_id = zlh_skills.skill_id
                                                       and _MySkillData.uname    = $session.user
  association [1..1] to zlh_i_skill_category as _category on  $projection.Category = _category.CategoryId                                                     
{
  key skill_id                           as SkillId,
      name                               as Name,
      description                        as Description,
      category                           as Category,
      created_by                         as CreatedBy,
      created_at                         as CreatedAt,
      last_changed_by                    as LastChangedBy,
      last_changed_at                    as LastChangedAt,
      cast(
      case when _MySkillData.skill_id is not null
       then 'X'
       else ' '
      end as xflag preserving type
      )                                  as AcquiredByMe,
      _MySkillData.proposed_for_learning as ProposedForLearning,
      _MySkillData.want_to_learn         as WantToLearn,
      _MySkillData.scale                 as Scale,
      _category
}
