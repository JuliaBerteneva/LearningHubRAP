@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Skills'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zlh_r_my_skills as select from zlh_i_my_skills
{
    key UserId,
    key SkillId,
    SkillName,
    Description,
    @ObjectModel.text.element: ['CategoryName']
    Category,
    Scale,
    want_to_learn as WantToLearn,
    proposed_for_learning as ProposedForLearning,
    @Semantics.text: true
    CategoryName
//    approved,
//    approved_by as ApprovedBy
}
