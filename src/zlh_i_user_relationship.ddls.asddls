@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Relationship'
@Metadata.ignorePropagatedAnnotations: true
define view entity zlh_i_user_relationship as select from zlh_user_rel 
    association [1..1] to zlh_relationship as _rel on $projection.RelationshipId = _rel.relationship_id
{
    key parent_user as ParentUser,
    key relationship_id as RelationshipId,
    key child_user as ChildUser,
    @Semantics.text: true
    _rel.description as RelationshipDescription,
    _rel
}
