CLASS ltcl_my_courses DEFINITION DEFERRED FOR TESTING.
CLASS lhc_course DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_my_courses.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR course RESULT result.
    METHODS get_instance_authorizationsm FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR material RESULT result.

    METHODS changestatus FOR MODIFY
      IMPORTING keys FOR ACTION course~changestatus.

    METHODS chagestatusmaterial FOR MODIFY
      IMPORTING keys FOR ACTION material~changestatusmaterial.

    METHODS markasfinished FOR MODIFY
      IMPORTING keys FOR ACTION material~markasfinished.

    METHODS checkmaterailstatus FOR VALIDATE ON SAVE IMPORTING keys FOR course~checkmaterialstatus.

    METHODS calculatepercentage FOR DETERMINE ON SAVE
      IMPORTING keys FOR material~calculatepercentage.

    METHODS recalcpercentage FOR MODIFY
      IMPORTING keys FOR ACTION course~recalcpercentage RESULT result.

    METHODS finishcourse FOR MODIFY
      IMPORTING keys FOR ACTION course~finishcourse RESULT result.

    METHODS get_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR material RESULT result.
    METHODS deleteme FOR MODIFY
      IMPORTING keys FOR ACTION course~deleteme.

ENDCLASS.

CLASS lhc_course IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.
  METHOD get_instance_authorizationsm.
  ENDMETHOD.

  METHOD changestatus.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY course
        FIELDS (  courseid status enddate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      <course>-status = keys[ KEY id  %key = <course>-%key ]-%param-instatus.
      IF <course>-status = zcl_cc_zlh_status=>gc_finished.
        <course>-enddate = sy-datum.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY course
        UPDATE FIELDS ( status enddate )
        WITH CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD chagestatusmaterial.
    DATA: lt_course_update TYPE TABLE OF zlh_r_my_courses,
          ls_course_update TYPE zlh_r_my_courses.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE

        ENTITY material
        FIELDS ( courseid materialid status enddate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(materials)

        ENTITY material BY \_course
        FIELDS ( courseid percentage status enddate )
        WITH CORRESPONDING #( keys )
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
         FAILED DATA(course_failed)
         REPORTED DATA(course_reported).
    ENDIF.

  ENDMETHOD.

  METHOD markasfinished.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY material
        FIELDS (  courseid materialid status enddate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(materials)
        ENTITY material BY \_course
        FIELDS ( courseid percentage )
        WITH CORRESPONDING #( keys )
        RESULT DATA(courses).

    LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
      <material>-status = zcl_cc_zlh_status=>gc_finished.
      <material>-enddate = sy-datum.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY material
        UPDATE FIELDS ( status enddate )
        WITH CORRESPONDING #( materials ).

    "if all materials are already finished, course will be also automatically finished
    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY course
        EXECUTE finishcourse
        FROM CORRESPONDING #( courses ).

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
        DATA(material) = materials[ KEY id  %tky = <material_link>-target-%tky ].
        IF material-status <> zcl_cc_zlh_status=>gc_cancelled
            AND material-status <> zcl_cc_zlh_status=>gc_finished.
          lv_course_not_finished = abap_true.
        ENDIF.
        IF <course>-status = zcl_cc_zlh_status=>gc_finished AND
            material-status <> zcl_cc_zlh_status=>gc_finished.
          <course>-status = zcl_cc_zlh_status=>gc_inprocess.
        ENDIF.
      ENDLOOP.
      IF lv_course_not_finished IS INITIAL.
        "change the status of whole course
        <course>-status = zcl_cc_zlh_status=>gc_finished.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY course
        UPDATE FIELDS ( status )
        WITH CORRESPONDING #( courses )
        FAILED failed
        REPORTED reported.

    result = VALUE #( FOR course IN courses ( %tky = course-%tky ) ).
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
      IF <course>-status = zcl_cc_zlh_status=>gc_finished.
        LOOP AT material_link ASSIGNING FIELD-SYMBOL(<link>) USING KEY id WHERE  source-%tky = <course>-%tky.
          DATA(material) = materials[ KEY id  %tky = <link>-target-%tky ].
          IF material-status <> zcl_cc_zlh_status=>gc_finished.
            INSERT VALUE #(  %tky = <course>-%tky ) INTO TABLE failed-course.

            INSERT VALUE #( %tky            = <course>-%tky
                            %state_area     = 'CHECK_MATERIAL'
                            %msg            = me->new_message( id       = 'ZUL_EXPERIMENTS'
                                                               number   = '004'
                                                               v1       = material-name
                                                               severity = ms-error )
                            %element-status = if_abap_behv=>mk-on
                          ) INTO TABLE reported-course.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatepercentage.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
          ENTITY material BY \_course
          FIELDS ( courseid )
          WITH CORRESPONDING #( keys )
          LINK DATA(links)
          RESULT DATA(courses).
    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY course
        EXECUTE recalcpercentage
        FROM CORRESPONDING #( courses ).

  ENDMETHOD.

  METHOD recalcpercentage.
    DATA: overall_course_duration TYPE i,
          finished_duration       TYPE i.
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
        DATA(material) = materials[ KEY id  %tky = <material_link>-target-%tky ].
        IF material-status <> zcl_cc_zlh_status=>gc_cancelled.
          overall_course_duration = overall_course_duration + material-duration.

          IF material-status = zcl_cc_zlh_status=>gc_finished.
            finished_duration = finished_duration + material-duration.
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

    result = VALUE #( FOR course IN courses ( %tky = course-%tky ) ).
  ENDMETHOD.

  METHOD get_features.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
      ENTITY material
         FIELDS ( materialid status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(materials)
       FAILED failed.


    result = VALUE #( FOR material IN materials
                      ( %tky                             = material-%tky
                        %features-%action-markasfinished = COND #( WHEN material-status = zcl_cc_zlh_status=>gc_finished
                      THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                    ) ).
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

ENDCLASS.
