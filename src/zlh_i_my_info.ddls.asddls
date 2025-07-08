@AbapCatalog.sqlViewName: 'ZLHIMYINFO'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Personal information about Me'
@Metadata.ignorePropagatedAnnotations: true
define view zlh_i_my_info as select from zlh_i_user
{
    key UserId,
    EmailAddress,
    FullName,
    FirstName,
    LastName
} where UserId = $session.user
