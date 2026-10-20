@EndUserText.label: 'Colleague'
define abstract entity zlh_a_colleague
{
      @Consumption.valueHelpDefinition: [{
      entity       : {
        name       : 'ZLH_I_TEAM',
        element    : 'UserId'
      },
      additionalBinding: [
      { localElement: 'FullName', element: 'FullName', usage: #RESULT },
      { localElement: 'TeamLead', element: 'TeamLead', usage: #RESULT }
      ]
      }]
      @UI.lineItem : [{
        position   : 10,
        label      : 'Colleague'
      }]

      @UI.identification: [{
          position : 10,
          label    : 'Colleague'
      }]

  key Colleague    : xubname;

      @UI.lineItem : [{
       position    : 20,
       label       : 'Name'
      }]
      @UI.identification: [{
          position : 20,
          label    : 'Name'
      }]
      FullName     : ad_namtext;

      TeamLead     : xubname;

      _Association : association to parent zlh_a_suggest_for on $projection.TeamLead = _Association.TeamLead;
}
