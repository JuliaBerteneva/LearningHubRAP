@EndUserText.label: 'Abstract status'
define abstract entity zlh_a_status
{   
    @EndUserText.label: 'New Status:'
    @Consumption.valueHelpDefinition: [{entity: {name: 'zlh_i_status_vh', element: 'Value' } }]
    key InStatus : zlh_status;
}
