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
      checkMaterailStatus FOR TESTING,
      recalcPercentage FOR TESTING,
      calculatePercentage FOR TESTING.

    DATA lo_handler       TYPE REF TO lhc_course.
    DATA lt_course_mock   TYPE TABLE OF zlh_i_my_courses.
    DATA lt_material_mock TYPE TABLE OF zlh_i_my_crsmtrl.

ENDCLASS.


CLASS ltcl_my_courses IMPLEMENTATION.

  METHOD change_status.

    lt_course_mock = VALUE #( ( CourseID = '1'
                                Status = zcl_cc_zlh_status=>gc_finished
                                Percentage = 100
                                Name = 'Test Project'
                                Moderator = 'ULOPINA'
                                Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lo_handler->changestatus( keys = VALUE #( FOR course IN lt_course_mock ( %key = CORRESPONDING #( course )
                                                                             %param = VALUE #( InStatus = zcl_cc_zlh_status=>gc_inprocess ) ) )  ).

    READ ENTITIES OF zlh_r_my_courses
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_result).

    cl_abap_unit_assert=>assert_equals( msg = 'Status is wrong' exp = zcl_cc_zlh_status=>gc_inprocess act = lt_result[ 1 ]-Status ).
  ENDMETHOD.

  METHOD chageStatusMaterial.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess
                                  Percentage = 100
                                  Name = 'Test Project'
                                  Moderator = 'ULOPINA'
                                  Duration = 40 )

                               ( CourseID = '2'
                                  Status = zcl_cc_zlh_status=>gc_finished
                                  Percentage = 100
                                  Name = 'Test Project2'
                                  Moderator = 'ULOPINA'
                                  Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess )
                                ( CourseId = '2'
                                  MaterialId = '21'
                                  Name = 'Material21'
                                  Status = zcl_cc_zlh_status=>gc_finished ) ).
    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->chagestatusmaterial( keys = VALUE #( FOR material IN lt_material_mock ( %key = CORRESPONDING #( material )
                                                                                        %param = COND #( WHEN material-Status = zcl_cc_zlh_status=>gc_inprocess
                                                                                                         THEN VALUE #( InStatus = zcl_cc_zlh_status=>gc_finished )
                                                                                                         ELSE VALUE #( InStatus = zcl_cc_zlh_status=>gc_inprocess )
                                                                                                       )
                                                                                      )
                                                   )
                                    ).
    READ ENTITIES OF zlh_r_my_courses
        ENTITY Material
        ALL FIELDS WITH CORRESPONDING #( lt_material_mock )
        RESULT DATA(lt_result).
    cl_abap_unit_assert=>assert_equals( msg = 'Material status is not FINISHED' exp = zcl_cc_zlh_status=>gc_finished act = lt_result[ 1 ]-Status ).
    cl_abap_unit_assert=>assert_equals( msg = 'Material status is not IN PROCESS' exp = zcl_cc_zlh_status=>gc_inprocess act = lt_result[ 2 ]-Status ).

    READ ENTITIES OF zlh_r_my_courses
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_course_res).

    cl_abap_unit_assert=>assert_equals( msg = 'Course status is not changed' exp = zcl_cc_zlh_status=>gc_inprocess act = lt_course_res[ 2 ]-Status ).
  ENDMETHOD.

  METHOD markasFinished.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                    Status = zcl_cc_zlh_status=>gc_inprocess
                                    Percentage = 100
                                    Name = 'Test Project'
                                    Moderator = 'ULOPINA'
                                    Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess ) ).
    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->markasfinished( keys = VALUE #( FOR material IN lt_material_mock ( %key = CORRESPONDING #( material ) ) )  ).
    READ ENTITIES OF zlh_r_my_courses
        ENTITY Material
        ALL FIELDS WITH CORRESPONDING #( lt_material_mock )
        RESULT DATA(lt_result).
    cl_abap_unit_assert=>assert_equals( msg = 'Status is wrong' exp = zcl_cc_zlh_status=>gc_finished act = lt_result[ 1 ]-Status ).
  ENDMETHOD.

  METHOD checkMaterailStatus.
    DATA: reported TYPE RESPONSE FOR REPORTED LATE zlh_r_my_courses.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                      Status = zcl_cc_zlh_status=>gc_inprocess
                                      Percentage = 100
                                      Name = 'Test Project'
                                      Moderator = 'ULOPINA'
                                      Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess )
                                ( CourseId = '1'
                                  MaterialId = '2'
                                  Name = 'Material2'
                                  Status = zcl_cc_zlh_status=>gc_finished ) ).

    lo_environment->insert_test_data( lt_material_mock ).

    lo_handler->changestatus( keys = VALUE #( FOR course IN lt_course_mock ( %key = CORRESPONDING #( course )
                                                                                       %param = VALUE #( InStatus = zcl_cc_zlh_status=>gc_finished ) ) )
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

  METHOD recalcPercentage.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess
                                  Percentage = 100
                                  Name = 'Test Project'
                                  Moderator = 'ULOPINA'
                                  Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess
                                  Duration = 40 )
                                ( CourseId = '1'
                                  MaterialId = '2'
                                  Name = 'Material2'
                                  Status = zcl_cc_zlh_status=>gc_finished
                                  Duration = 40 ) ).

    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->recalcpercentage( keys = VALUE #( FOR course IN lt_course_mock ( %key = CORRESPONDING #( course ) ) ) ).

    READ ENTITIES OF zlh_r_my_courses
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_result).

    cl_abap_unit_assert=>assert_equals( msg = 'Percentage calculated incorrectly' exp = 50 act = lt_result[ 1 ]-Percentage ).

  ENDMETHOD.

  METHOD calculatePercentage.
    lt_course_mock = VALUE #( ( CourseID = '1'
                                      Status = zcl_cc_zlh_status=>gc_inprocess
                                      Percentage = 100
                                      Name = 'Test Project'
                                      Moderator = 'ULOPINA'
                                      Duration = 40 ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_inprocess
                                  Duration = 40 )
                                ( CourseId = '1'
                                  MaterialId = '2'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_cancelled
                                  Duration = 40 )
                                ( CourseId = '1'
                                  MaterialId = '3'
                                  Name = 'Material2'
                                  Status = zcl_cc_zlh_status=>gc_finished
                                  Duration = 40 )
                                ( CourseId = '1'
                                  MaterialId = '4'
                                  Name = 'Material1'
                                  Status = zcl_cc_zlh_status=>gc_notstarted
                                  Duration = 40 ) ).

    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->calculatepercentage( keys = CORRESPONDING #( lt_material_mock ) ).
    READ ENTITIES OF zlh_r_my_courses
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_result).

    cl_abap_unit_assert=>assert_equals( msg = 'Percentage calculated incorrectly' exp = '33.33' act = lt_result[ 1 ]-Percentage ).

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
