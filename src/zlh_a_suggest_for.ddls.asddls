@EndUserText.label: 'Abstract suggest for'
define root abstract entity zlh_a_suggest_for
{   
      @UI.hidden  : true
  key TeamLead    : xubname;
      @UI.facet: [{
        id            : 'Colleagues',
        type          : #LINEITEM_REFERENCE,
        label         : 'Colleagues',
        targetElement : '_Colleagues',
        position      : 10
    }]
      _Colleagues : composition [1..*] of zlh_a_colleague;

}
