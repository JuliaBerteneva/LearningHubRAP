@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Business object node'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zlh_r_material as select from zlh_i_material
association to parent zlh_r_course as _course on $projection.CourseId = _course.CourseId
association to zlh_i_type_vh as _materialType on _materialType.Value = $projection.Type
{
    key CourseId,
    key MaterialId,
    MaterialKey,
    @Consumption.valueHelpDefinition: [{entity: {name: 'zlh_i_type_vh', element: 'Value' }, useForValidation: true }]
    @ObjectModel.text.association: '_materialType'
    Type,
    Name,
    Duration,
    Content,
    @Semantics.systemDateTime.lastChangedAt: true
    LastChangedAt,
    _course,
    _materialType
}
