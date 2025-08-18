"! @testing BDEF:zlh_r_course
CLASS ltcl_course DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: lo_environment TYPE REF TO if_cds_test_environment.
    CLASS-DATA: lo_environment_data_base TYPE REF TO if_osql_test_environment.

    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      setup,
      teardown,
      calcDuration FOR TESTING,
      assignMeToCourse FOR TESTING,
      recalcDuration FOR TESTING,
      get_features_global FOR TESTING.

    DATA: lo_handler       TYPE REF TO lhc_Course,
          lt_course_mock   TYPE TABLE OF zlh_i_course,
          lt_material_mock TYPE TABLE OF zlh_i_material.
ENDCLASS.


CLASS ltcl_course IMPLEMENTATION.

  METHOD calcDuration.
    lt_course_mock = VALUE #( ( CourseId = '1'
                                CourseKey = 'Test'
                                Name = 'Test course'
                                Moderator = 'ULOPINA' ) ).
    lo_environment->insert_test_data( lt_course_mock ).

    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Duration = 10 )
                                ( CourseId = '1'
                                  MaterialId = '21'
                                  Name = 'Material21'
                                  Duration = 20 ) ).
    lo_environment->insert_test_data( lt_material_mock ).

    lo_handler->calcDuration( EXPORTING keys = CORRESPONDING #( lt_material_mock ) ).

    READ ENTITIES OF zlh_r_course
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_result).

    cl_abap_unit_assert=>assert_equals( msg = 'Course duration is not correct' exp = 30 act = lt_result[ 1 ]-Duration ).
  ENDMETHOD.

  METHOD assignMeToCourse.
    lt_course_mock = VALUE #( ( CourseId = '1'
                                  CourseKey = 'Test'
                                  Name = 'Test course'
                                  Moderator = 'ULOPINA' ) ).
    lo_environment->insert_test_data( lt_course_mock ).
    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Duration = 10 )
                                ( CourseId = '1'
                                  MaterialId = '21'
                                  Name = 'Material21'
                                  Duration = 20 ) ).
    lo_environment->insert_test_data( lt_material_mock ).
    lo_handler->assignmetocourse( EXPORTING keys = CORRESPONDING #( lt_course_mock ) ).
    DATA(ls_course)  = lt_course_mock[ 1 ].
    SELECT * FROM zlh_user_course INTO TABLE @DATA(lt_user_course)
    WHERE CourseId = @ls_course-CourseId.
    SELECT * FROM zlh_user_mtrl INTO TABLE @DATA(lt_user_material)
    WHERE CourseId = @ls_course-CourseId.

    cl_abap_unit_assert=>assert_not_initial( msg = 'Course is not created in connection table' act = lt_user_course ).
    cl_abap_unit_assert=>assert_not_initial( msg = 'Material is not created in connection table' act = lt_user_material ).
    LOOP AT lt_user_course ASSIGNING FIELD-SYMBOL(<ls_user_course>).
      cl_abap_unit_assert=>assert_not_initial( msg = 'User is empty in connection for course' act = <ls_user_course>-userid ).
      cl_abap_unit_assert=>assert_equals( msg = 'Course is assigned to the wrong user' exp = 'ULOPINA' act = <ls_user_course>-userid ).
    ENDLOOP.
    LOOP AT lt_user_material ASSIGNING FIELD-SYMBOL(<ls_user_material>).
      cl_abap_unit_assert=>assert_not_initial( msg = 'User is empty in connection for material' act = <ls_user_material>-userid ).
      cl_abap_unit_assert=>assert_equals( msg = 'Material is assigned to the wrong user' exp = 'ULOPINA' act = <ls_user_material>-userid ).
    ENDLOOP.

  ENDMETHOD.

  METHOD class_setup.
    lo_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'zlh_r_course' )
                                                                                                 ( i_for_entity = 'zlh_r_material')
                                                                                                ) ).
    lo_environment_data_base = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zlh_course_d' )
                                                                                              ( 'zlh_material_d' )
                                                                                              ( 'zlh_user_course' )
                                                                                              ( 'zlh_user_mtrl' ) ) ).
  ENDMETHOD.

  METHOD recalcDuration.
    lt_course_mock = VALUE #( ( CourseId = '1'
                              CourseKey = 'Test'
                              Name = 'Test course'
                              Moderator = 'ULOPINA' ) ).
    lo_environment->insert_test_data( lt_course_mock ).

    lt_material_mock = VALUE #( ( CourseId = '1'
                                  MaterialId = '1'
                                  Name = 'Material1'
                                  Duration = 10 )
                                ( CourseId = '1'
                                  MaterialId = '21'
                                  Name = 'Material21'
                                  Duration = 20 ) ).
    lo_environment->insert_test_data( lt_material_mock ).

    lo_handler->recalcDuration( EXPORTING keys = CORRESPONDING #( lt_course_mock ) ).

    READ ENTITIES OF zlh_r_course
        ENTITY Course
        ALL FIELDS WITH CORRESPONDING #( lt_course_mock )
        RESULT DATA(lt_result).

    cl_abap_unit_assert=>assert_equals( msg = 'Course duration is not correct' exp = 30 act = lt_result[ 1 ]-Duration ).
  ENDMETHOD.

  METHOD get_features_global.
*    DATA request  TYPE STRUCTURE FOR GLOBAL FEATURES RESULT zlh_r_course.
    " Define a role with DISPLAY authorizations for authorization object S_DEVELOP.
    DATA(role_may_delete)  = VALUE cl_aunit_auth_check_types_def=>role_auth_objects(
                                                             ( object = 'ZLH_COURSE'
                                                               authorizations = VALUE #(
                                                                  ( VALUE #( ( fieldname   = 'ACTVT'
                                                                     fieldvalues  = VALUE #( ( lower_value = '06' ) )  ) )  ) )
                                                               ) ).

    DATA(usrrl_may_delete)  = VALUE cl_aunit_auth_check_types_def=>user_role_authorizations( ( role_authorizations = role_may_delete ) ).

    " Create an auth object set containing display authorizations.
    DATA(auth_objset_with_del_auth) = cl_aunit_authority_check=>create_auth_object_set( usrrl_may_delete ).
    " Set up environment - Get an instance of the test controller and set the user configurations.
    DATA(auth_controller) = cl_aunit_authority_check=>get_controller( ).

    " Set up environment - Configure users with the intended authorizations via the auth_objset for the test session.
    auth_controller->restrict_authorizations_to( auth_objset_with_del_auth ).
*    lo_handler->get_features_global( requested_features = data(request) ).
  ENDMETHOD.

  METHOD class_teardown.
    lo_environment->destroy(  ).
    lo_environment_data_base->destroy(  ).
  ENDMETHOD.

  METHOD setup.
    CREATE OBJECT lo_handler FOR TESTING.
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    ROLLBACK WORK.
    lo_environment->clear_doubles(  ).
    lo_environment_data_base->clear_doubles(  ).
  ENDMETHOD.

ENDCLASS.
