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
  as select from    zlh_user_skill   as _main
    join            zlh_skills       as _description on _description.skill_id = _main.skill_id
    left outer join zlh_skill_apprvr as _approver    on _approver.skill_id = _main.skill_id
{
  key _main.uname              as UserId,
  key _main.skill_id           as SkillId,
      _description.name        as SkillName,
      _description.description as Description,
      _description.category    as Category,
      _main.scale              as Scale,
      _main.want_to_learn,
      _main.proposed_for_learning,
      case when _approver.approver is not null then 'X'
        else ' ' end           as Approver,
      _approver.approver       as ApprovedBy
}
