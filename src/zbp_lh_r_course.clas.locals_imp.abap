CLASS lsc_zlh_r_course DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zlh_r_course IMPLEMENTATION.

  METHOD save_modified.
    DATA: lo_container TYPE REF TO if_swf_ifs_parameter_container.
    DATA: ls_course       TYPE zlh_course,
          lt_input_course TYPE TABLE FOR CHANGE zlh_r_course\\course,
          ls_input_course LIKE LINE OF lt_input_course.
    IF create-course IS NOT INITIAL.

      ls_input_course = create-course[ 1 ].
    ENDIF.
    IF update-course IS NOT INITIAL.

      ls_input_course = update-course[ 1 ].
    ENDIF.
    IF ls_input_course IS NOT INITIAL.
      TRY.
          lo_container = cl_swf_evt_event=>get_event_container( im_objcateg = cl_swf_evt_event=>mc_objcateg_cl
                                                                im_objtype  = 'ZCL_LH_CWF'
                                                                im_event    = 'RAISE_APPROVAL' ).
          ls_course-course_id = ls_input_course-courseId.
          ls_course-course_key = ls_input_course-CourseKey.
          lo_container->set( name  = 'IS_COURSE'
                             value = ls_course ).
          lo_container->set( name  = 'Course_Link'
                             value = |https://us4.leverx.local:44302/sap/bc/ui2/flp?sap-client=100&sap-language=EN#LEARNING_HUB-manage&/zlh_c_course(CourseId=guid'{ ls_input_course-courseId }',IsActiveEntity=true)| ).


          DATA(lo_event) = cl_swf_evt_event=>get_instance( im_objcateg        = cl_swf_evt_event=>mc_objcateg_cl
                                                           im_objtype         = 'ZCL_LH_CWF'
                                                           im_event           = 'RAISE_APPROVAL'
                                                           im_objkey          = CONV char16( ls_course-course_id )
                                                           im_event_container = lo_container ).
          lo_event->raise( ).
          DATA(lv_event_id) = lo_event->get_event_id(  ).
        CATCH cx_root.
          "handle exception
      ENDTRY.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_course DEFINITION DEFERRED FOR TESTING.
CLASS lhc_course DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_course.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR course RESULT result.

    METHODS get_features_global FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR course RESULT result.

    METHODS calcduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR material~calcduration.

    METHODS assignmetocourse FOR MODIFY
      IMPORTING keys FOR ACTION course~assignmetocourse.

    METHODS recalcduration FOR MODIFY
      IMPORTING keys FOR ACTION course~recalcduration.

    METHODS get_features_material FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR material RESULT result.

    METHODS get_features_course FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR course RESULT result.

    METHODS checkduration FOR VALIDATE ON SAVE
      IMPORTING keys FOR material~checkduration.
    METHODS releasecourse FOR MODIFY
      IMPORTING keys FOR ACTION course~releasecourse.
    METHODS checkmaterailsempty FOR VALIDATE ON SAVE
      IMPORTING keys FOR course~checkmaterailsempty.
    METHODS refreshmaterials FOR DETERMINE ON MODIFY
      IMPORTING keys FOR course~refreshmaterials.
ENDCLASS.

CLASS lhc_course IMPLEMENTATION.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'ZLH_COURSE' ID 'ACTVT' FIELD '06'.
    IF sy-subrc IS NOT INITIAL.
      result-%delete = if_abap_behv=>auth-unauthorized.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'ZLH_COURSE' ID 'ACTVT' FIELD '01'.
    IF sy-subrc IS NOT INITIAL.
      result-%create = if_abap_behv=>auth-unauthorized.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'ZLH_COURSE' ID 'ACTVT' FIELD '02'.
    IF sy-subrc IS NOT INITIAL.
      result-%update = if_abap_behv=>auth-unauthorized.
    ENDIF.
  ENDMETHOD.

  METHOD get_features_global.

  ENDMETHOD.

  METHOD calcduration.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
          ENTITY material BY \_course
          FIELDS ( courseid )
          WITH CORRESPONDING #( keys )
          LINK DATA(links)
          RESULT DATA(courses).
    MODIFY ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY course
        EXECUTE recalcduration
        FROM CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD recalcduration.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY course
        FIELDS ( courseid duration )
        WITH CORRESPONDING #( keys )
        RESULT DATA(courses)
         FAILED failed.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY course BY \_materials
        FIELDS ( courseid materialid duration )
        WITH CORRESPONDING #( courses )
       LINK DATA(material_links)
       RESULT DATA(materials).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      CLEAR <course>-duration.
      LOOP AT material_links ASSIGNING FIELD-SYMBOL(<link>).
        DATA(material) = materials[ KEY draft %tky = <link>-target-%tky ].
        <course>-duration = <course>-duration + material-duration.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course
        UPDATE FIELDS ( duration )
        WITH CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD assignmetocourse.
    DATA: course_connections   TYPE TABLE OF zlh_user_course,
          material_connections TYPE TABLE OF zlh_user_mtrl.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course
      FIELDS ( courseid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(courses)
         FAILED failed.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course BY \_materials
      FIELDS ( courseid materialid )
      WITH CORRESPONDING #( courses )
     LINK DATA(material_links)
     RESULT DATA(materials).
    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      INSERT VALUE #( userid     = sy-uname
                      courseid   = <course>-courseid
                      status     = zcl_cc_zlh_status=>gc_inprocess
                      start_date = sy-datum ) INTO TABLE course_connections.
      LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
        INSERT VALUE #( userid     = sy-uname
                        materialid = <material>-materialid
                        courseid   = <course>-courseid
                        status     = zcl_cc_zlh_status=>gc_notstarted
                        start_date = sy-datum ) INTO TABLE material_connections.
      ENDLOOP.
    ENDLOOP.
    IF course_connections IS NOT INITIAL.
      MODIFY zlh_user_course FROM TABLE course_connections.
    ENDIF.
    IF material_connections IS NOT INITIAL.
      MODIFY zlh_user_mtrl FROM TABLE material_connections.
    ENDIF.
  ENDMETHOD.

  METHOD get_features_material.

    DATA: temp         TYPE STRUCTURE FOR READ LINK zlh_r_course\\course\_materials,
          materials_id LIKE TABLE OF temp-target.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY course
           FIELDS ( courseid released )
           WITH CORRESPONDING #( keys )
         RESULT DATA(courses)
         FAILED failed.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course BY \_materials
      FIELDS ( courseid materialid )
      WITH CORRESPONDING #( courses )
     LINK DATA(material_links)
     RESULT DATA(materials).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      IF keys[ courseid = <course>-courseid ]-%is_draft = if_abap_behv=>mk-on.
        LOOP AT material_links ASSIGNING FIELD-SYMBOL(<link>) WHERE target-courseid = <course>-courseid.
          INSERT CORRESPONDING #( <link>-target ) INTO TABLE materials_id.
        ENDLOOP.
        result = VALUE #( BASE result FOR material IN materials_id
                          ( %tky             = material-%tky
                            %features-%field = VALUE #( name    = COND #( WHEN <course>-released = abap_true
                                                                          THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
                                                        type    = COND #( WHEN <course>-released = abap_true
                                                                          THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
                                                        content = COND #( WHEN <course>-released = abap_true
                                                                          THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted ) )
                        ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_features_course.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY course
           FIELDS ( courseid released )
           WITH CORRESPONDING #( keys )
         RESULT DATA(courses)
         FAILED failed.

    IF courses IS NOT INITIAL.
      SELECT courseid FROM zlh_user_course INTO TABLE @DATA(assigned_courses) WHERE userid = @sy-uname.
    ENDIF.


    result = VALUE #( FOR course IN courses
                      ( %tky      = course-%tky
                        %features = VALUE #( %assoc-_materials = COND #( WHEN course-released  = abap_true
                                           THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                             %field            = VALUE #(     coursekey        = COND #( WHEN course-released = abap_true
                                                                                                         THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
                                                                              name             = COND #( WHEN course-released = abap_true
                                                                                                         THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted ) )
                                             %action           = VALUE #(     assignmetocourse = COND #( WHEN line_exists( assigned_courses[ courseid = course-courseid ] )
                                                                                                         THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                                                              releasecourse    = COND #( WHEN course-released = abap_true
                                                                                                         THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) )
                    )
                    ) ).
  ENDMETHOD.

  METHOD checkduration.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
          ENTITY course
             FIELDS ( courseid released )
             WITH CORRESPONDING #( keys )
           RESULT DATA(courses).

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course BY \_materials
      FIELDS ( courseid materialid duration )
      WITH CORRESPONDING #( courses )
     LINK DATA(material_links)
     RESULT DATA(materials).

    LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
      INSERT VALUE #( %tky        = <material>-%tky
                      %state_area = 'CHECK_DURATION'
                    ) INTO TABLE reported-material.
      IF <material>-duration > 100.                       "#EC CI_MAGIC
        INSERT VALUE #( %tky        = <material>-%tky
                        %fail-cause = if_abap_behv=>cause-not_found ) INTO TABLE failed-material.
        INSERT VALUE #( %tky              = <material>-%tky
                        %state_area       = 'CHECK_DURATION'
                        %msg              = me->new_message( id        = 'ZUL_LEARNING_HUB'
                                                             number    = '000'
                                                             severity  = ms-error )
                        %element-duration = if_abap_behv=>mk-on
                        %path-course      = VALUE #(         %is_draft = <material>-%is_draft
                                                             courseid  = <material>-courseid )
                      ) INTO TABLE reported-material.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD releasecourse.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course
      FIELDS ( courseid released )
      WITH CORRESPONDING #( keys )
      RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      <course>-released = abap_true.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course
        UPDATE FIELDS ( released )
        WITH CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD checkmaterailsempty.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
            ENTITY course
               FIELDS ( courseid )
               WITH CORRESPONDING #( keys )
             RESULT DATA(courses).

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course BY \_materials
      FIELDS ( courseid materialid duration )
      WITH CORRESPONDING #( courses )
     LINK DATA(material_links)
     RESULT DATA(materials).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      INSERT VALUE #( %tky        = <course>-%tky
                      %state_area = 'CHECK_MATERIAL_EXISTS'
                    ) INTO TABLE reported-course.
      IF materials IS INITIAL.
        INSERT VALUE #( %tky        = <course>-%tky
                        %fail-cause = if_abap_behv=>cause-not_found ) INTO TABLE failed-course.
        INSERT VALUE #( %tky        = <course>-%tky
                        %state_area = 'CHECK_MATERIAL_EXISTS'
                        %msg        = me->new_message( id       = 'ZUL_LEARNING_HUB'
                                                       number   = '002'
                                                       severity = ms-error )
                      ) INTO TABLE reported-course.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD refreshmaterials.
    DATA: temp         TYPE STRUCTURE FOR READ LINK zlh_r_course\\course\_materials,
          materials_id LIKE TABLE OF temp-target.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
              ENTITY course
                 FIELDS ( courseid type skillcategory )
                 WITH CORRESPONDING #( keys )
               RESULT DATA(courses).

    IF courses IS NOT INITIAL.
      SELECT course_id , type, skill_category
          FROM zlh_course
          FOR ALL ENTRIES IN @courses
          WHERE course_id = @courses-courseid
          INTO TABLE @DATA(lt_db).
    ENDIF.

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY course BY \_materials
      FIELDS ( courseid materialid duration )
      WITH CORRESPONDING #( courses )
     LINK DATA(material_links)
     RESULT DATA(materials).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      IF keys[ KEY entity courseid = <course>-courseid ]-%is_draft = if_abap_behv=>mk-on.

        IF line_exists( lt_db[ course_id = <course>-courseid ] )
            AND ( <course>-type <> lt_db[ course_id = <course>-courseid ]-type AND lt_db[ course_id = <course>-courseid ]-type IS NOT INITIAL
            OR <course>-skillcategory <> lt_db[ course_id = <course>-courseid ]-skill_category AND lt_db[ course_id = <course>-courseid ]-skill_category IS NOT INITIAL ) .

          LOOP AT material_links ASSIGNING FIELD-SYMBOL(<link>) WHERE target-courseid = <course>-courseid.
            INSERT CORRESPONDING #( <link>-target ) INTO TABLE materials_id.
          ENDLOOP.

        ENDIF.

      ENDIF.
    ENDLOOP.
    IF materials_id IS NOT INITIAL.
      MODIFY ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY material
          DELETE FROM CORRESPONDING #( materials_id ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
