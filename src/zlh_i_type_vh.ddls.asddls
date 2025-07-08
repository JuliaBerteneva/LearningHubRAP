@AbapCatalog.sqlViewName: 'ZLHITYPEVH'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Type Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view zlh_i_type_vh as select from dd07l as l
    inner join dd07t as t on t.domname = l.domname and
                             t.as4local = l.as4local and
                             t.valpos = l.valpos and
                             t.as4vers = l.as4vers
{
  key l.domvalue_l as Value,
  @Semantics.text: true
  t.ddtext as Description
}
where l.domname = 'ZLH_MATERIAL_TYPE'
  and t.ddlanguage = $session.system_language
