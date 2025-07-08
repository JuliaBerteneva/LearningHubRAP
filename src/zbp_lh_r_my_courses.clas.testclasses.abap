"! @testing BDEF:zlh_r_my_courses
CLASS ltcl_my_courses DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: lo_environment TYPE REF TO if_cds_test_environment.

    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      setup,
      teardown,
      change_status FOR TESTING,
      chageStatusMaterial FOR TESTING,
      markasFinished FOR TESTING,
      checkMaterailStatus FOR TESTING.

    DATA: lo_handler       TYPE REF TO lhc_course,
          lt_course_mock   TYPE TABLE OF zlh_i_my_courses,
          lt_material_mock TYPE TABLE OF zlh_i_my_crsmtrl.
ENDCLASS.


CLASS ltcl_my_courses IMPLEMENTATION.

  METHOD change_status.

    lt_course_mock = VALUE #( ( CourseID = '1'
                                Status = 'FINISHED'
                                Percentage = 100
                                Name = 'Test Project'
                                Moderator = 'ULOPINA'
                                Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lo_handler->changestatus( EXPORTING keys = VALUE #( FOR course IN lt_course_mock ( %key = CORRESPONDING #( course )
                                                                                       %param = VALUE #( InStatus = 'IN PROCESS' ) ) )  ).

    READ ENTITIES OF zlh_r_my_courses
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_result).

    cl_abap_unit_assert=>assert_equals( msg = 'Status is wrong' exp = 'IN PROCESS' act = lt_result[ 1 ]-Status ).
  ENDMETHOD.

  METHOD chageStatusMaterial.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                  Status = 'IN PROCESS'
                                  Percentage = 100
                                  Name = 'Test Project'
                                  Moderator = 'ULOPINA'
                                  Duration = 40 )

                               ( CourseID = '2'
                                  Status = 'FINISHED'
                                  Percentage = 100
                                  Name = 'Test Project2'
                                  Moderator = 'ULOPINA'
                                  Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = 'IN PROCESS')
                                ( CourseId = '2'
                                  MaterialId = '21'
                                  Name = 'Material21'
                                  Status = 'FINISHED') ).
    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->chagestatusmaterial( EXPORTING keys = VALUE #( FOR material IN lt_material_mock ( %key = CORRESPONDING #( material )
                                                                                                  %param = COND #( WHEN material-Status = 'IN PROCESS'
                                                                                                                   THEN VALUE #( InStatus = 'FINISHED' )
                                                                                                                   ELSE VALUE #( InStatus = 'IN PROCESS' )
                                                                                                                 )
                                                                                                )
                                                              )
                                    ).
    READ ENTITIES OF zlh_r_my_courses
        ENTITY Material
        ALL FIELDS WITH CORRESPONDING #( lt_material_mock )
        RESULT DATA(lt_result).
    cl_abap_unit_assert=>assert_equals( msg = 'Material status is not FINISHED' exp = 'FINISHED' act = lt_result[ 1 ]-Status ).
    cl_abap_unit_assert=>assert_equals( msg = 'Material status is not IN PROCESS' exp = 'IN PROCESS' act = lt_result[ 2 ]-Status ).

    READ ENTITIES OF zlh_r_my_courses
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_course_res).

    cl_abap_unit_assert=>assert_equals( msg = 'Course status is not changed' exp = 'IN PROCESS' act = lt_course_res[ 2 ]-Status ).
  ENDMETHOD.

  METHOD markasFinished.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                    Status = 'IN PROCESS'
                                    Percentage = 100
                                    Name = 'Test Project'
                                    Moderator = 'ULOPINA'
                                    Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = 'IN PROCESS') ).
    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->markasfinished( EXPORTING keys = VALUE #( FOR material IN lt_material_mock ( %key = CORRESPONDING #( material ) ) )  ).
    READ ENTITIES OF zlh_r_my_courses
        ENTITY Material
        ALL FIELDS WITH CORRESPONDING #( lt_material_mock )
        RESULT DATA(lt_result).
    cl_abap_unit_assert=>assert_equals( msg = 'Status is wrong' exp = 'FINISHED' act = lt_result[ 1 ]-Status ).
  ENDMETHOD.

  METHOD checkMaterailStatus.
    DATA: reported TYPE RESPONSE FOR REPORTED LATE zlh_r_my_courses.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                      Status = 'IN PROCESS'
                                      Percentage = 100
                                      Name = 'Test Project'
                                      Moderator = 'ULOPINA'
                                      Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = 'IN PROCESS')
                                ( CourseId = '1'
                                  MaterialId = '2'
                                  Name = 'Material2'
                                  Status = 'FINISHED') ).

    lo_environment->insert_test_data( lt_material_mock ).

    lo_handler->changestatus( EXPORTING keys = VALUE #( FOR course IN lt_course_mock ( %key = CORRESPONDING #( course )
                                                                                       %param = VALUE #( InStatus = 'FINISHED' ) ) )
*                              CHANGING reported = reported
                              ).
    lo_handler->checkMaterailStatus( EXPORTING keys = VALUE #( FOR course IN lt_course_mock ( %key = CORRESPONDING #( course ) ) )
                                     CHANGING reported = reported ).
    "Status is changed as checks are not managed automatically,
    "so after filling reported table the process is not interrupted
    cl_abap_unit_assert=>assert_not_initial( msg = 'Message is missed' act = reported ).
  ENDMETHOD.

  METHOD class_setup.
    lo_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'zlh_r_my_courses' )
                                                                                                 ( i_for_entity = 'zlh_r_my_course_materials')
                                                                                                ) ).
  ENDMETHOD.

  METHOD class_teardown.
    lo_environment->destroy(  ).
  ENDMETHOD.

  METHOD setup.
    CREATE OBJECT lo_handler FOR TESTING.
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    ROLLBACK WORK.
    lo_environment->clear_doubles(  ).
  ENDMETHOD.

ENDCLASS.
