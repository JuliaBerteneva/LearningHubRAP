@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Skills'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_i_my_skills 
    as select from zlh_i_user_skill
{
    key UserId,
    key SkillId,
    SkillName,
    Description,
    Category,
    Scale,
    want_to_learn,
    proposed_for_learning,
    Approver,
    ApprovedBy,
    coalesce( _category.Name, _category.CategoryKey ) as CategoryName,
    _category
} where UserId = $session.user

