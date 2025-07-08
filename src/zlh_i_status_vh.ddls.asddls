@AbapCatalog.sqlViewName: 'ZLHISTATUSVH'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view ZLH_I_STATUS_VH as select from dd07l as l
    inner join dd07t as t on t.domname = l.domname and
                             t.as4local = l.as4local and
                             t.valpos = l.valpos and
                             t.as4vers = l.as4vers
{
  key l.domvalue_l as Value,
  @Semantics.text: true
  t.ddtext as Description
}
where l.domname = 'ZLH_STATUS'
  and t.ddlanguage = $session.system_language
