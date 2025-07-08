@AbapCatalog.sqlViewName: 'ZLHICOURSE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Course basic data'
@Metadata.ignorePropagatedAnnotations: true
define view zlh_i_course as select from zlh_course
{
    key course_id as CourseId,
    course_key as CourseKey,
    name as Name,
    @EndUserText.label: 'Moderator'
    moderator as Moderator,
    duration as Duration,
    @EndUserText.label: 'Created At'
    local_created_at as LocalCreatedAt,
    @EndUserText.label: 'Created By'
    local_created_by as LocalCreatedBy,
    @EndUserText.label: 'Changed At'
    local_last_changed_at as LocalLastChangedAt,
    @EndUserText.label: 'Changed By'
    local_last_changed_by as LocalLastChangedBy,
    @EndUserText.label: 'Changed At'
    last_changed_at as LastChangedAt
}
