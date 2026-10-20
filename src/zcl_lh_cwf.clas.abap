CLASS zcl_lh_cwf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES bi_object .
    INTERFACES bi_persistent .
    INTERFACES if_workflow .

    EVENTS raise_approval
      EXPORTING
        VALUE(is_course)    TYPE zlh_course
        VALUE(iv_submitter) TYPE bname
        VALUE(iv_moderator) TYPE bname .

    CLASS-METHODS ld_approve .
    CLASS-METHODS run_approval EXPORTING VALUE(is_course) TYPE zlh_course.
    CLASS-METHODS release_course CHANGING cs_course TYPE zlh_course .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_lh_cwf IMPLEMENTATION.


  METHOD ld_approve.
  ENDMETHOD.


  METHOD bi_object~default_attribute_value.

  ENDMETHOD.


  METHOD bi_object~execute_default_method.

  ENDMETHOD.


  METHOD bi_persistent~find_by_lpor.
    DATA(lv_key) = lpor-instid.
    result = NEW zcl_lh_cwf( ).
  ENDMETHOD.


  METHOD bi_persistent~lpor.
    result-catid  = 'CL'.
    result-objtype = 'ZCL_LH_CWF'.
    result-instid = 'B9C73FD9F3711FD190C478022B47D180'.
  ENDMETHOD.


  METHOD bi_persistent~refresh.

  ENDMETHOD.


  METHOD bi_object~release.

  ENDMETHOD.


  METHOD run_approval.
    TRY.
        cl_swf_evt_event=>raise( EXPORTING im_objcateg = cl_swf_evt_event=>mc_objcateg_cl
                                           im_objtype  = 'ZCL_LH_CWF'
                                           im_event    = 'RAISE_APPROVAL'
                                           im_objkey   = 'B9C73FD9F3711FD190C478022B47D180' ).
      CATCH cx_swf_evt_invalid_objtype cx_swf_evt_invalid_event.
        "handle exception
    ENDTRY.
    COMMIT WORK.
  ENDMETHOD.
  METHOD release_course.
    DATA: lt_courses TYPE TABLE OF zlh_course.
    APPEND cs_course TO lt_courses.
    READ ENTITIES OF zlh_r_course
      ENTITY course
      FIELDS ( courseid released )
      WITH CORRESPONDING #( lt_courses )
      RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      <course>-released = abap_true.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_course
      ENTITY course
        UPDATE FIELDS ( released )
        WITH CORRESPONDING #( courses ).

    COMMIT ENTITIES.
  ENDMETHOD.
ENDCLASS.
