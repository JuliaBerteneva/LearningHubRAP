@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View for Team Members'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_i_team
  as select from    zlh_i_user_relationship as Rel
    left outer join zlh_i_user              as _User on _User.UserId = Rel.ChildUser
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 1.0
      @ObjectModel.text.element: [ 'FullName' ]
      @UI.textArrangement: #TEXT_FIRST
  key Rel.ChildUser  as UserId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      _User.FullName as FullName
}
where
      Rel.ParentUser     = $session.user
  and Rel.RelationshipId = 'LEADER_TO'
