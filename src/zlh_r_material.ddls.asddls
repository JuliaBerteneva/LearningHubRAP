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
{
    key CourseId,
    key MaterialId,
    MaterialKey,
    @Consumption.valueHelpDefinition: [{entity: {name: 'zlh_i_type_vh', element: 'Description' }, useForValidation: true }]
    Type,
    Name,
    Duration,
    Content,
    @Semantics.systemDateTime.lastChangedAt: true
    LastChangedAt,
    _course
}
