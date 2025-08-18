CLASS ltcl_my_courses DEFINITION DEFERRED FOR TESTING.
CLASS lhc_Course DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_my_courses.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Course RESULT result.

    METHODS get_instance_authorizationsM FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Material RESULT result.

    METHODS changeStatus FOR MODIFY
      IMPORTING keys FOR ACTION Course~changeStatus.

    METHODS chageStatusMaterial FOR MODIFY
      IMPORTING keys FOR ACTION Material~changeStatusMaterial.

    METHODS markasFinished FOR MODIFY
      IMPORTING keys FOR ACTION Material~markasFinished.

    METHODS checkMaterailStatus FOR VALIDATE ON SAVE IMPORTING keys FOR Course~checkMaterialStatus.

    METHODS calculatePercentage FOR DETERMINE ON SAVE
      IMPORTING keys FOR Material~calculatePercentage.

    METHODS recalcPercentage FOR MODIFY
      IMPORTING keys FOR ACTION Course~recalcPercentage RESULT result.

    METHODS finishCourse FOR MODIFY
      IMPORTING keys FOR ACTION Course~finishCourse RESULT result.

    METHODS get_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Material RESULT result.

ENDCLASS.

CLASS lhc_Course IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizationsM.
  ENDMETHOD.

  METHOD changeStatus.
    READ ENTITIES OF zlh_R_my_courses IN LOCAL MODE
        ENTITY Course
        FIELDS (  CourseId Status EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(courses).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      <course>-status = keys[ KEY id  %key = <course>-%key ]-%param-instatus.
      IF <course>-status = zcl_cc_zlh_status=>gc_finished.
        <course>-EndDate = sy-datum.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_R_my_courses IN LOCAL MODE
        ENTITY Course
        UPDATE FIELDS ( Status EndDate )
        WITH CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD chageStatusMaterial.
    DATA: lt_course_update TYPE TABLE OF zlh_r_my_courses,
          ls_course_update TYPE zlh_r_my_courses.
    READ ENTITIES OF zlh_R_my_courses IN LOCAL MODE

        ENTITY Material
        FIELDS ( CourseId MaterialId Status EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(materials)

        ENTITY Material BY \_course
        FIELDS ( CourseId Percentage Status EndDate )
        WITH CORRESPONDING #( keys )
        LINK DATA(course_link)
        RESULT DATA(courses).

    LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
      <material>-status = keys[ materialId = <material>-materialId ]-%param-instatus.
      IF <material>-status = zcl_cc_zlh_status=>gc_finished.
        <material>-EndDate = sy-datum.
      ENDIF.
      DATA(course) = courses[ CourseId = <material>-CourseId ].
      IF course-Status = zcl_cc_zlh_status=>gc_finished AND <material>-Status <> zcl_cc_zlh_status=>gc_finished.
        course-Status = zcl_cc_zlh_status=>gc_inprocess.
        CLEAR course-EndDate.
        ls_course_update = CORRESPONDING #( course ).
        APPEND ls_course_update TO lt_course_update.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY Material
        UPDATE FIELDS ( Status EndDate )
        WITH CORRESPONDING #( materials )
        FAILED failed
        REPORTED reported.

    IF lt_course_update IS NOT INITIAL.
      MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
         ENTITY Course
         UPDATE FIELDS ( Status EndDate )
         WITH CORRESPONDING #( lt_course_update )
         FAILED DATA(course_failed)
         REPORTED DATA(course_reported).
    ENDIF.

  ENDMETHOD.

  METHOD markAsFinished.
    READ ENTITIES OF zlh_R_my_courses IN LOCAL MODE
        ENTITY Material
        FIELDS (  CourseId MaterialId Status EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(materials)
        ENTITY Material BY \_course
        FIELDS ( CourseId Percentage )
        WITH CORRESPONDING #( keys )
        RESULT DATA(courses).

    LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
      <material>-status = zcl_cc_zlh_status=>gc_finished.
      <material>-EndDate = sy-datum.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_R_my_courses IN LOCAL MODE
        ENTITY Material
        UPDATE FIELDS ( Status EndDate )
        WITH CORRESPONDING #( materials ).

    "if all materials are already finished, course will be also automatically finished
    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY Course
        EXECUTE finishCourse
        FROM CORRESPONDING #( courses ).

  ENDMETHOD.

  METHOD finishCourse.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
      ENTITY Course
      FIELDS ( CourseId Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
      ENTITY Course BY \_materials
      FIELDS ( MaterialId Status Duration )
      WITH CORRESPONDING #( courses )
      RESULT DATA(materials)
      LINK DATA(material_link).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      LOOP AT material_link ASSIGNING FIELD-SYMBOL(<material_link>) USING KEY id WHERE source-%tky = <course>-%tky.
        DATA(material) = materials[ KEY id  %tky = <material_link>-target-%tky ].
        IF material-status <> zcl_cc_zlh_status=>gc_cancelled
            AND material-status <> zcl_cc_zlh_status=>gc_finished.
          DATA(lv_course_not_finished) = abap_true.
        ENDIF.
        IF <course>-Status = zcl_cc_zlh_status=>gc_finished AND
            material-status <> zcl_cc_zlh_status=>gc_finished.
          <course>-Status = zcl_cc_zlh_status=>gc_inprocess.
        ENDIF.
      ENDLOOP.
      IF lv_course_not_finished IS INITIAL.
        "change the status of whole course
        <course>-Status = zcl_cc_zlh_status=>gc_finished.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_R_my_courses IN LOCAL MODE
        ENTITY Course
        UPDATE FIELDS ( Status )
        WITH CORRESPONDING #( courses )
        FAILED failed
        REPORTED reported.

    result = VALUE #( FOR course IN courses ( %tky = course-%tky ) ).
  ENDMETHOD.

  METHOD checkMaterailStatus.

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
    ENTITY Course
    FIELDS ( CourseId Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
    ENTITY Course BY \_materials
    FIELDS ( CourseId MaterialId Name Status )
    WITH CORRESPONDING #( Courses )
    RESULT DATA(Materials)
    LINK DATA(material_link).

    LOOP AT Courses ASSIGNING FIELD-SYMBOL(<course>).
      IF <course>-status = zcl_cc_zlh_status=>gc_finished.
        LOOP AT material_link ASSIGNING FIELD-SYMBOL(<link>) USING KEY id WHERE  source-%tky = <course>-%tky.
          DATA(material) = materials[ KEY id  %tky = <link>-target-%tky ].
          IF material-status <> zcl_cc_zlh_status=>gc_finished.
            APPEND VALUE #(  %tky = <course>-%tky ) TO failed-course.

            APPEND VALUE #(  %tky                = <course>-%tky
                             %state_area         = 'CHECK_MATERIAL'
                             %msg                = me->new_message( id = 'ZUL_EXPERIMENTS'
                                                                    number = '004'
                                                                    v1 = material-Name
                                                                    severity = ms-error )
                             %element-Status = if_abap_behv=>mk-on
                          ) TO reported-course.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatePercentage.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
          ENTITY Material BY \_course
          FIELDS ( CourseId )
          WITH CORRESPONDING #( keys )
          LINK DATA(links)
          RESULT DATA(courses).
    MODIFY ENTITIES OF zlh_r_my_courses IN LOCAL MODE
        ENTITY Course
        EXECUTE recalcPercentage
        FROM CORRESPONDING #( courses ).

  ENDMETHOD.

  METHOD recalcPercentage.
    DATA: overall_course_duration TYPE i,
          finished_duration       TYPE i.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
      ENTITY Course
      FIELDS ( CourseId Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(courses).

    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
      ENTITY Course BY \_materials
      FIELDS ( MaterialId Status Duration )
      WITH CORRESPONDING #( courses )
      RESULT DATA(materials)
      LINK DATA(material_link).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      CLEAR overall_course_duration.
      LOOP AT material_link ASSIGNING FIELD-SYMBOL(<material_link>) USING KEY id WHERE source-%tky = <course>-%tky.
        DATA(material) = materials[ KEY id  %tky = <material_link>-target-%tky ].
        IF material-status <> zcl_cc_zlh_status=>gc_cancelled.
          overall_course_duration = overall_course_duration + material-Duration.

          IF material-status = zcl_cc_zlh_status=>gc_finished.
            finished_duration = finished_duration + material-duration.
          ENDIF.
        ENDIF.
      ENDLOOP.
      <course>-percentage = 100 / overall_course_duration * finished_duration.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_R_my_courses IN LOCAL MODE
        ENTITY Course
        UPDATE FIELDS ( Percentage )
        WITH CORRESPONDING #( courses )
        FAILED failed
        REPORTED reported.

    result = VALUE #( FOR course IN courses ( %tky = course-%tky ) ).
  ENDMETHOD.

  METHOD get_features.
    READ ENTITIES OF zlh_r_my_courses IN LOCAL MODE
      ENTITY Material
         FIELDS ( MaterialId Status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(materials)
       FAILED failed.


    result = VALUE #( FOR material IN materials
                       ( %tky                           = material-%tky
                         %features-%action-markAsFinished = COND #( WHEN material-status = zcl_cc_zlh_status=>gc_finished
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled  )
                      ) ).
  ENDMETHOD.

ENDCLASS.
