CLASS lcl_email_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_user_email
      IMPORTING iv_user         TYPE xubname
      RETURNING VALUE(rv_email) TYPE ad_smtpadr.

    CLASS-METHODS send_email
      IMPORTING iv_from    TYPE ad_smtpadr
                iv_to      TYPE ad_smtpadr
                iv_subject TYPE so_obj_des
                iv_body    TYPE string.
ENDCLASS.

CLASS lcl_email_helper IMPLEMENTATION.
  METHOD get_user_email.
    rv_email = ''.

    IF iv_user IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE adr6~smtp_addr
      FROM usr21 AS u
             LEFT JOIN
               adr6 AS adr6 ON adr6~persnumber = u~persnumber
      WHERE u~bname = @iv_user
      INTO @rv_email.
  ENDMETHOD.

  METHOD send_email.
    DATA lo_send_request TYPE REF TO cl_bcs.
    DATA lo_document     TYPE REF TO cl_document_bcs.
    DATA lo_recipient    TYPE REF TO if_recipient_bcs.
    DATA lo_sender       TYPE REF TO if_sender_bcs.
    DATA lt_text         TYPE TABLE OF soli.

    APPEND VALUE soli( line = iv_body ) TO lt_text.
    TRY.
        lo_send_request = cl_bcs=>create_persistent( ).

        lo_sender = cl_cam_address_bcs=>create_internet_address( iv_from ).
        lo_send_request->set_sender( i_sender = lo_sender ).

        lo_recipient = cl_cam_address_bcs=>create_internet_address( iv_to ).
        lo_send_request->add_recipient( i_recipient = lo_recipient
                                        i_express   = abap_true ).

        lo_document = cl_document_bcs=>create_document( i_type    = 'RAW'
                                                        i_text    = lt_text
                                                        i_subject = iv_subject ).

        lo_send_request->set_document( i_document = lo_document ).

        lo_send_request->send( i_with_error_screen = abap_false ).
      CATCH cx_bcs INTO DATA(lx_bcs). " TODO: variable is assigned but never used (ABAP cleaner)
        " Handle the exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_my_courses DEFINITION DEFERRED FOR TESTING.

CLASS lhc_course DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_my_courses.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR course RESULT result.

    METHODS get_instance_authorizationsm FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR material RESULT result.

    METHODS changestatus FOR MODIFY
      IMPORTING keys FOR ACTION course~changestatus RESULT result.

    METHODS chagestatusmaterial FOR MODIFY
      IMPORTING keys FOR ACTION material~changestatusmaterial RESULT result.

    METHODS markasfinished FOR MODIFY
      IMPORTING keys FOR ACTION material~markasfinished RESULT result.

    METHODS checkmaterailstatus FOR VALIDATE ON SAVE IMPORTING keys FOR course~checkmaterialstatus.

    METHODS calculatepercentage FOR DETERMINE ON SAVE
      IMPORTING keys FOR material~calculatepercentage.

    METHODS recalcpercentage FOR MODIFY
      IMPORTING keys FOR ACTION course~recalcpercentage RESULT result.

    METHODS finishcourse FOR MODIFY
      IMPORTING keys FOR ACTION course~finishcourse RESULT result.

    METHODS submitrating FOR MODIFY
      IMPORTING keys FOR ACTION course~submitrating RESULT result.

    METHODS get_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR material RESULT result.

    METHODS get_course_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR course RESULT result.

    METHODS deleteme FOR MODIFY
      IMPORTING keys FOR ACTION course~deleteme.

    METHODS sendemailtomoderator FOR MODIFY
      IMPORTING keys FOR ACTION course~sendemailtomoderator RESULT result.

ENDCLASS.


CLASS lhc_course IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizationsm.
  ENDMETHOD.

  METHOD get_course_features.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( status rating )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    result = VALUE #( FOR course IN courses
                      ( %tky                           = course-%tky

                        %features-%action-submitrating = COND #(
                          WHEN course-status  = zcl_cc_zlh_status=>gc_finished
                           AND course-rating IS INITIAL
                          THEN if_abap_behv=>fc-o-enabled
                          ELSE if_abap_behv=>fc-o-disabled )

                        %features-%action-sendEmailToModerator = COND #(
                          WHEN course-%is_draft  = if_abap_behv=>mk-on
                          THEN if_abap_behv=>fc-o-disabled
                          ELSE if_abap_behv=>fc-o-enabled )

                        %action-Edit = COND #( WHEN course-Status = zcl_cc_zlh_status=>gc_finished
                          THEN if_abap_behv=>fc-o-disabled
                          ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD changestatus.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( courseid status enddate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      <course>-status = keys[ KEY id
                              %key = <course>-%key
                              %is_draft  = <course>-%is_draft ]-%param-instatus.
      IF <course>-status = zcl_cc_zlh_status=>gc_finished.
        <course>-enddate = sy-datum.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY course
           UPDATE FIELDS ( status enddate )
           WITH CORRESPONDING #( courses ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_bapi_head        TYPE bapimathead.
    DATA ls_bapi_desc        TYPE bapi_makt.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_bapi_clientdata  TYPE bapi_mara.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_bapi_clientdatax TYPE bapi_marax.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lt_bapi_desc        TYPE TABLE OF bapi_makt.

    ls_bapi_head = VALUE #( material   = '0001'
                            matl_type  = 'DIEN'
                            basic_view = abap_true
                            ind_sector = 'C' ).

    ls_bapi_clientdata = VALUE #( base_uom   = 'MG'
                                  matl_group = '01' ).
    ls_bapi_clientdatax = VALUE #( base_uom   = abap_true
                                   matl_group = abap_true ).

    ls_bapi_desc-langu     = sy-langu.
    ls_bapi_desc-langu_iso = 'EN'.
    ls_bapi_desc-matl_desc = 'Text'.
    APPEND ls_bapi_desc TO lt_bapi_desc.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
       ENTITY course
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(updated_courses).

    result = VALUE #( FOR c IN updated_courses
                      ( %tky   = c-%tky
                        %param = c ) ).
  ENDMETHOD.

  METHOD chagestatusmaterial.
    DATA lt_course_update TYPE TABLE OF zlh_r_my_courses.
    DATA ls_course_update TYPE zlh_r_my_courses.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE

         ENTITY material
         FIELDS ( courseid materialid status enddate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(materials)

         ENTITY material BY \_course
         FIELDS ( courseid percentage status enddate )
         WITH CORRESPONDING #( keys )
         " TODO: variable is assigned but never used (ABAP cleaner)
         LINK DATA(course_link)
         RESULT DATA(courses).

    LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
      <material>-status = keys[ materialid = <material>-materialid ]-%param-instatus.
      IF <material>-status = zcl_cc_zlh_status=>gc_finished.
        <material>-enddate = sy-datum.
      ENDIF.
      DATA(course) = courses[ courseid = <material>-courseid ].
      IF course-status = zcl_cc_zlh_status=>gc_finished AND <material>-status <> zcl_cc_zlh_status=>gc_finished.
        course-status = zcl_cc_zlh_status=>gc_inprocess.
        CLEAR course-enddate.
        ls_course_update = CORRESPONDING #( course ).
        INSERT ls_course_update INTO TABLE lt_course_update.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY material
           UPDATE FIELDS ( status enddate )
           WITH CORRESPONDING #( materials )
           FAILED failed
           REPORTED reported.

    IF lt_course_update IS NOT INITIAL.
      MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
             ENTITY course
             UPDATE FIELDS ( status enddate )
             WITH CORRESPONDING #( lt_course_update )
             " TODO: variable is assigned but never used (ABAP cleaner)
             FAILED DATA(course_failed)
             " TODO: variable is assigned but never used (ABAP cleaner)
             REPORTED DATA(course_reported).
    ENDIF.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
     ENTITY material
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(updated_materials).

    result = VALUE #( FOR m IN updated_materials
                      ( %tky = m-%tky %param = m ) ).
  ENDMETHOD.

  METHOD markasfinished.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY material
         FIELDS ( courseid materialid status enddate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(materials)
         ENTITY material BY \_course
         FIELDS ( courseid percentage )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
      <material>-status  = zcl_cc_zlh_status=>gc_finished.
      <material>-enddate = sy-datum.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY material
           UPDATE FIELDS ( status enddate )
           WITH CORRESPONDING #( materials ).

    " if all materials are already finished, course will be also automatically finished
    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY course
           EXECUTE finishcourse
           FROM CORRESPONDING #( courses ).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
     ENTITY material
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(updated_materials).

    result = VALUE #( FOR m IN updated_materials
                      ( %tky = m-%tky %param = m ) ).
  ENDMETHOD.

  METHOD finishcourse.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( courseid percentage )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course BY \_materials
         FIELDS ( materialid status duration )
         WITH CORRESPONDING #( courses )
         RESULT DATA(materials)
         LINK DATA(material_link).

    DATA(lv_course_not_finished) = abap_false.

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      LOOP AT material_link ASSIGNING FIELD-SYMBOL(<material_link>) USING KEY id WHERE source-%tky = <course>-%tky.
        DATA(material) = materials[ KEY id
                                    %tky = <material_link>-target-%tky ].
        IF     material-status <> zcl_cc_zlh_status=>gc_cancelled
           AND material-status <> zcl_cc_zlh_status=>gc_finished.
          lv_course_not_finished = abap_true.
        ENDIF.
        IF     <course>-status  = zcl_cc_zlh_status=>gc_finished
           AND material-status <> zcl_cc_zlh_status=>gc_finished.
          <course>-status = zcl_cc_zlh_status=>gc_inprocess.
        ENDIF.
      ENDLOOP.
      IF lv_course_not_finished IS INITIAL.
        " change the status of whole course
        <course>-status = zcl_cc_zlh_status=>gc_finished.

      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY course
           UPDATE FIELDS ( status )
           WITH CORRESPONDING #( courses )
           FAILED failed
           REPORTED reported.

    result = VALUE #( FOR course IN courses
                      ( %tky = course-%tky ) ).
  ENDMETHOD.

  METHOD submitrating.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( courseid status rating )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      DATA(submitted_rating) = keys[ KEY id
                                     %key = <course>-%key
                                     %is_draft  = <course>-%is_draft ]-%param-rating.

      IF submitted_rating < 1 OR submitted_rating > 5.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text( severity = ms-error
                                                      text     = 'Rating must be between 1 and 5 stars.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      IF <course>-status <> zcl_cc_zlh_status=>gc_finished.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text(
                                   severity = ms-error
                                   text     = 'A rating can only be submitted after course completion.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      IF <course>-rating IS NOT INITIAL.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text( severity = ms-error
                                                      text     = 'This course has already been rated.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
             ENTITY course
             UPDATE FIELDS ( rating )
             WITH VALUE #( ( %tky = <course>-%tky rating = submitted_rating ) )
             FAILED failed
             REPORTED reported.

      SELECT SUM( rating ) AS total_rating,
             COUNT( * )    AS rating_count
        FROM zlh_user_course
        WHERE courseid  = @<course>-courseid
          AND rating   <> 0
        INTO ( @DATA(total_rating), @DATA(rating_count) ).

      DATA(average_rating) = CONV zlh_average_rating(
        ( CONV decfloat34( total_rating ) + CONV decfloat34( submitted_rating ) )
        / CONV decfloat34( rating_count + 1 ) ).

      MODIFY ENTITIES OF zlh_r_course
             ENTITY course
             EXECUTE updateAverageRating
             FROM VALUE #( ( %tky   = VALUE #( CourseId = <course>-courseid )
                             %param = VALUE #( Rating = average_rating ) ) )
             " TODO: variable is assigned but never used (ABAP cleaner)
             FAILED DATA(average_failed)
             " TODO: variable is assigned but never used (ABAP cleaner)
             REPORTED DATA(average_reported).
    ENDLOOP.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(updated_courses).

    result = VALUE #( FOR course IN updated_courses
                      ( %tky   = course-%tky
                        %param = course ) ).
  ENDMETHOD.

  METHOD checkmaterailstatus.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( courseid status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course BY \_materials
         FIELDS ( courseid materialid name status )
         WITH CORRESPONDING #( courses )
         RESULT DATA(materials)
         LINK DATA(material_link).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      IF <course>-status <> zcl_cc_zlh_status=>gc_finished.
        CONTINUE.
      ENDIF.

      LOOP AT material_link ASSIGNING FIELD-SYMBOL(<link>) USING KEY id WHERE source-%tky = <course>-%tky.
        DATA(material) = materials[ KEY id
                                    %tky = <link>-target-%tky ].
        IF material-status = zcl_cc_zlh_status=>gc_finished.
          CONTINUE.
        ENDIF.

        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.

        INSERT VALUE #( %tky            = <course>-%tky
                        %state_area     = 'CHECK_MATERIAL'
                        %msg            = new_message( id       = 'ZLH_PERSONAL_GROWTH'
                                                       number   = '006'
                                                       v1       = material-name
                                                       severity = ms-error )
                        %element-status = if_abap_behv=>mk-on )
               INTO TABLE reported-course.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatepercentage.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY material BY \_course
         FIELDS ( courseid )
         WITH CORRESPONDING #( keys )
         " TODO: variable is assigned but never used (ABAP cleaner)
         LINK DATA(links)
         RESULT DATA(courses).
    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY course
           EXECUTE recalcpercentage
           FROM CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD recalcpercentage.
    DATA overall_course_duration TYPE i.
    DATA finished_duration       TYPE i.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( courseid percentage )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course BY \_materials
         FIELDS ( materialid status duration )
         WITH CORRESPONDING #( courses )
         RESULT DATA(materials)
         LINK DATA(material_link).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      CLEAR overall_course_duration.
      LOOP AT material_link ASSIGNING FIELD-SYMBOL(<material_link>) USING KEY id WHERE source-%tky = <course>-%tky.
        DATA(material) = materials[ KEY id
                                    %tky = <material_link>-target-%tky ].
        IF material-status <> zcl_cc_zlh_status=>gc_cancelled.
          overall_course_duration += material-duration.

          IF material-status = zcl_cc_zlh_status=>gc_finished.
            finished_duration += material-duration.
          ENDIF.
        ENDIF.
      ENDLOOP.
      <course>-percentage = 100 / overall_course_duration * finished_duration.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY course
           UPDATE FIELDS ( percentage )
           WITH CORRESPONDING #( courses )
           FAILED failed
           REPORTED reported.

    result = VALUE #( FOR course IN courses
                      ( %tky = course-%tky ) ).
  ENDMETHOD.

  METHOD get_features.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY material
         FIELDS ( materialid status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(materials)
         FAILED failed.

    result = VALUE #( FOR material IN materials
                      ( %tky = material-%tky

                        %features-%action-markasfinished =
                          COND #( WHEN material-status = zcl_cc_zlh_status=>gc_finished
                                  THEN if_abap_behv=>fc-o-disabled
                                  ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD deleteme.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( courseid )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course BY \_materials
         FIELDS ( materialid )
         WITH CORRESPONDING #( courses )
         RESULT DATA(materials)
         " TODO: variable is assigned but never used (ABAP cleaner)
         LINK DATA(material_link).

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY material
           DELETE FROM CORRESPONDING #( materials )
           FAILED failed
           REPORTED reported.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
           ENTITY course
           DELETE FROM CORRESPONDING #( courses )
           FAILED failed
           REPORTED reported.
  ENDMETHOD.

  METHOD sendEmailToModerator.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY course
         FIELDS ( CourseId Moderator Name )
         WITH CORRESPONDING #( keys )
         RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      IF <course>-Moderator IS INITIAL.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text( severity = ms-error
                                                      text     = 'No moderator assigned to this course.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      DATA(lv_sender_email) = lcl_email_helper=>get_user_email( sy-uname ).
      IF lv_sender_email IS INITIAL.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text( severity = ms-error
                                                      text     = 'No email address found for the current user.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      DATA(lv_moderator_email) = lcl_email_helper=>get_user_email( <course>-Moderator ).
      IF lv_moderator_email IS INITIAL.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text( severity = ms-error
                                                      text     = 'No email address found for the moderator.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      DATA(lv_body) = keys[ KEY id
                            %key = <course>-%key
                            %is_draft  = <course>-%is_draft ]-%param-body.
      DATA(lv_subject) = CONV so_obj_des( |Help for the Course - { <course>-Name }| ).
      IF lv_body IS INITIAL.
        INSERT VALUE #( %tky = <course>-%tky ) INTO TABLE failed-course.
        INSERT VALUE #( %tky = <course>-%tky
                        %msg = new_message_with_text( severity = ms-error
                                                      text     = 'Message body cannot be empty.' ) )
               INTO TABLE reported-course.
        CONTINUE.
      ENDIF.

      lcl_email_helper=>send_email( iv_from = lv_sender_email
                                    iv_to   = lv_moderator_email
                                    iv_subject = lv_subject
                                    iv_body = lv_body ).
    ENDLOOP.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
    ENTITY course
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #(
      FOR course IN lt_result
      ( %tky = course-%tky )
    ).
  ENDMETHOD.

ENDCLASS.
