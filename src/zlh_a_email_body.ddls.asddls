@EndUserText.label: 'Abstract Email Body'
define abstract entity zlh_a_email_body
{   
    @EndUserText.label: 'Email Body'
    @UI.multiLineText: true
    body : abap.string(1000);    
}
