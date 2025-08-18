CLASS ltcl_course DEFINITION DEFERRED FOR TESTING.
CLASS lhc_Course DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_course.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Course RESULT result.

    METHODS get_features_global FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR Course RESULT result.

    METHODS calcDuration FOR DETERMINE ON SAVE
      IMPORTING keys FOR Material~calcDuration.

    METHODS assignMeToCourse FOR MODIFY
      IMPORTING keys FOR ACTION Course~assignMeToCourse.

    METHODS recalcDuration FOR MODIFY
      IMPORTING keys FOR ACTION Course~recalcDuration.

ENDCLASS.

CLASS lhc_Course IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_features_global.
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

  METHOD calcDuration.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
          ENTITY Material BY \_course
          FIELDS ( CourseId )
          WITH CORRESPONDING #( keys )
          LINK DATA(links)
          RESULT DATA(courses).
    MODIFY ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY Course
        EXECUTE recalcDuration
        FROM CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD recalcDuration.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY Course
        FIELDS ( CourseId Duration )
        WITH CORRESPONDING #( keys )
        RESULT DATA(courses).

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
        ENTITY Course BY \_materials
        FIELDS ( CourseId MaterialId Duration )
        WITH CORRESPONDING #( courses )
       LINK DATA(material_links)
       RESULT DATA(materials).

    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      CLEAR <course>-duration.
      LOOP AT material_links ASSIGNING FIELD-SYMBOL(<link>).
        DATA(material) = materials[ KEY draft %tky = <link>-target-%tky ].
        <course>-duration = <course>-Duration + material-Duration.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY Course
        UPDATE FIELDS ( Duration )
        WITH CORRESPONDING #( courses ).
  ENDMETHOD.

  METHOD assignMeToCourse.
    DATA: course_connections   TYPE TABLE OF zlh_user_course,
          material_connections TYPE TABLE OF zlh_user_mtrl.
    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY Course
      FIELDS ( CourseId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(courses).

    READ ENTITIES OF zlh_r_course IN LOCAL MODE
      ENTITY Course BY \_materials
      FIELDS ( CourseId MaterialId )
      WITH CORRESPONDING #( courses )
     LINK DATA(material_links)
     RESULT DATA(materials).
    LOOP AT courses ASSIGNING FIELD-SYMBOL(<course>).
      APPEND VALUE #( userId = sy-uname
                      courseid = <course>-CourseId
                      status = zcl_cc_zlh_status=>gc_inprocess
                      start_date = sy-datum ) TO course_connections.
      LOOP AT materials ASSIGNING FIELD-SYMBOL(<material>).
        APPEND VALUE #( userId = sy-uname
                        materialId = <material>-MaterialId
                        courseId = <course>-CourseId
                        Status = zcl_cc_zlh_status=>gc_notstarted
                        start_date = sy-datum ) TO material_connections.
      ENDLOOP.
    ENDLOOP.
    IF course_connections IS NOT INITIAL.
      MODIFY zlh_user_course FROM TABLE course_connections.
    ENDIF.
    IF material_connections IS NOT INITIAL.
      MODIFY zlh_user_mtrl FROM TABLE material_connections.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
