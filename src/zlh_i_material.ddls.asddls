@AbapCatalog.sqlViewName: 'ZLHIMATERIAL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material basic data'
@Metadata.ignorePropagatedAnnotations: true
define view zlh_i_material as select from zlh_material
{
    key course_id as CourseId,
    key material_id as MaterialId,
    material_key as MaterialKey,
    type as Type,
    name as Name,
    duration as Duration,
    content as Content,
    @EndUserText.label: 'Last Changed At'
    last_changed_at as LastChangedAt
}
