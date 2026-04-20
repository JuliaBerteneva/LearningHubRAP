@EndUserText.label: 'Uploading Skills File'
@VDM.usage.type: [ #ACTION_PARAMETER_STRUCTURE ]
define abstract entity zlh_a_skills_file
{
  @UI.hidden : true
  file_name  : abap.string;
  @Semantics.mimeType: true
  @UI.hidden : true
  mime_type : abap.string;
  @Semantics.largeObject:
               {
      mimeType: 'mime_type',
      fileName: 'file_name',
      contentDispositionPreference: #ATTACHMENT
  }
  @UI.fieldGroup: [{ position: 10 }]
  attachment : abap.rawstring(0);
}
