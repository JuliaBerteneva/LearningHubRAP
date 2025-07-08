@AbapCatalog.sqlViewName: 'ZLHIUSER'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User information'
@Metadata.ignorePropagatedAnnotations: true
define view zlh_i_user 
    as select from usr21 as user
    left outer join adr6 as address on address.persnumber = user.persnumber and address.addrnumber = user.addrnumber
    left outer join adrp on adrp.persnumber = user.persnumber
{
    user.bname as UserId,
    address.smtp_addr as EmailAddress,
    adrp.name_text as FullName,
    adrp.name_first as FirstName,
    adrp.name_last as LastName
}
