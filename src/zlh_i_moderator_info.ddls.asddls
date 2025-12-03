@AbapCatalog.sqlViewName: 'ZLHIMODINFO'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Personal information about Moderator'
@Metadata.ignorePropagatedAnnotations: true
define view ZLH_I_Moderator_info as select from zlh_i_user
{
    @ObjectModel.text.element: [ 'FullName' ]
    key UserId,
    EmailAddress,
    @Semantics.text: true
    FullName,
    FirstName,
    LastName
} 
