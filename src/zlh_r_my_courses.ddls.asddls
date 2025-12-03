@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Courses BO'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zlh_r_my_courses
  as select from zlh_i_my_courses as course
  association to zlh_i_my_info                    as _user   on _user.UserId = $projection.Userid
  association to ZLH_I_STATUS_VH                  as _status on _status.Value = $projection.Status
  composition [1..*] of zlh_r_my_course_materials as _materials
{
  key CourseId,
  key Userid,
      Moderator,
      Name,
      Type,
      SkillCategory,
      Duration,
      @Consumption.valueHelpDefinition: [{ entity : { name : 'zlh_i_status_vh', element : 'Value' } } ]
      @ObjectModel.text.association: '_status'
      Status,
      Percentage,
      Percent,
      StartDate,
      EndDate,
      case Status
        when 'NOTSTARTED' then 0
        when 'IN PROCESS' then 2
        when 'CANCELLED' then 1
        when 'FINISHED' then 3
        else 0 end as Criticality,
      LastChangedAt,
      _user,
      _materials,
      _status
}
