@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My skills'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zlh_c_my_skills
  provider contract transactional_query
  as projection on zlh_r_my_skills
{
  key UserId,
  key SkillId,
      SkillName,
      Description,
      @EndUserText.label: 'Category Id'
      Category,
      Scale,
      @EndUserText.label: 'Want To Learn'
      WantToLearn,
      @EndUserText.label: 'Proposed For Learning'
      ProposedForLearning
//      approved,
//      ApprovedBy
}
