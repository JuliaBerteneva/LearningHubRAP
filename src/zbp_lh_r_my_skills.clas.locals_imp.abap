CLASS lhc_Skills DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Skills RESULT result.

    METHODS UploadFromFile FOR MODIFY
      IMPORTING keys FOR ACTION Skills~UploadFromFile.

ENDCLASS.

CLASS lhc_Skills IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD UploadFromFile.

  ENDMETHOD.

ENDCLASS.
