@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Skill Transactional'
@Metadata.ignorePropagatedAnnotations: true

define root view entity zlh_r_user_skill as select from zlh_i_user_skill
{
    key UserId,
    key SkillId,
    SkillName,
    Description,
    Category,
    Scale,
    want_to_learn as WantToLearn,
    proposed_for_learning as ProposedForLearning,
    Approver,
    ApprovedBy,
    /* Associations */
    _category
}
