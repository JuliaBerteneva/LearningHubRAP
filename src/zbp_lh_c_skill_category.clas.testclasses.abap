*"* use this source file for your ABAP unit test classes

"! Shared test isolation base for AUGMENT() tests of BDEF
"! ZLH_C_SKILL_CATEGORY. Owns the SQL test double environment and
"! all reusable GIVEN/WHEN/THEN helpers.
"!
"! setup/teardown live here only - child test classes never redeclare
"! them, they inherit both automatically (project AUT convention).
"! clear_doubles() runs in teardown, not setup, so doubles stay
"! reachable for inspection until the next test starts.
"!
"! Test data is created as DRAFT instances via EML, not seeded into
"! the active tables: the managed runtime reads active instances via
"! the CDS view stack, which the ABAP SQL test double does not
"! redirect (an EDIT on a seeded row fails with NOT_FOUND).
CLASS ltc_test_base DEFINITION ABSTRACT
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PROTECTED SECTION.
    CONSTANTS:
      gc_language    TYPE sylangu VALUE 'E',
      gc_language_de TYPE sylangu VALUE 'D'.

    TYPES tt_update   TYPE TABLE FOR UPDATE zlh_c_skill_category.
    TYPES tt_text     TYPE TABLE FOR READ RESULT zlh_c_skill_category\_text.
    TYPES ts_failed   TYPE RESPONSE FOR FAILED EARLY zlh_c_skill_category.
    TYPES ts_reported TYPE RESPONSE FOR REPORTED EARLY zlh_c_skill_category.

    CLASS-DATA go_sql_env TYPE REF TO if_osql_test_environment.

    DATA ms_failed   TYPE ts_failed.
    DATA ms_reported TYPE ts_reported.

    "given
    METHODS given_new_category
      RETURNING VALUE(rv_category_id) TYPE sysuuid_x16.
    METHODS given_text
      IMPORTING iv_category_id TYPE sysuuid_x16
                iv_language    TYPE sylangu DEFAULT gc_language
                iv_name        TYPE zlh_skill_categ_name.
    METHODS given_name_already_set
      IMPORTING iv_category_id TYPE sysuuid_x16
                iv_name        TYPE zlh_skill_categ_name.
    METHODS given_logon_language
      IMPORTING iv_language TYPE sylangu.

    "when
    METHODS when_updated
      IMPORTING it_updates TYPE tt_update.
    METHODS when_name_updated
      IMPORTING iv_category_id TYPE sysuuid_x16
                iv_name        TYPE zlh_skill_categ_name.
    METHODS when_key_updated
      IMPORTING iv_category_id TYPE sysuuid_x16.

    "then
    METHODS then_no_failures.
    METHODS then_text_is
      IMPORTING iv_category_id TYPE sysuuid_x16
                iv_language    TYPE sylangu DEFAULT gc_language
                iv_name        TYPE zlh_skill_categ_name.
    METHODS then_text_count_is
      IMPORTING iv_category_id TYPE sysuuid_x16
                iv_count       TYPE i.
    METHODS then_no_text
      IMPORTING iv_category_id TYPE sysuuid_x16.

    METHODS read_draft_texts
      IMPORTING iv_category_id  TYPE sysuuid_x16
      RETURNING VALUE(rt_texts) TYPE tt_text.
    METHODS describe_failure
      IMPORTING is_failed      TYPE ts_failed
                is_reported    TYPE ts_reported
      RETURNING VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS class_setup RAISING cx_static_check.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.
ENDCLASS.


CLASS ltc_test_base IMPLEMENTATION.

  METHOD class_setup.
    "active and draft tables of the BO - nothing may reach real data
    go_sql_env = cl_osql_test_environment=>create( i_dependency_list = VALUE #(
                   ( 'ZLH_SKILL_CATEG' )
                   ( 'ZLH_SKILL_CATEGT' )
                   ( 'ZLH_SKILL_CTEGD' )
                   ( 'ZLH_SKILL_CTEGTD' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    go_sql_env->destroy( ).
  ENDMETHOD.

  METHOD setup.
    CLEAR: ms_failed, ms_reported.
    "texts are created/updated in the logon language (sy-langu)
    SET LOCALE LANGUAGE gc_language.
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
    go_sql_env->clear_doubles( ).
    SET LOCALE LANGUAGE space.
  ENDMETHOD.


  METHOD given_new_category.
    DATA ls_failed   TYPE ts_failed.
    DATA ls_reported TYPE ts_reported.

    MODIFY ENTITIES OF zlh_c_skill_category
      ENTITY Category
        CREATE FIELDS ( CategoryKey )
        WITH VALUE #( ( %cid        = 'CATEGORY'
                        %is_draft   = if_abap_behv=>mk-on
                        CategoryKey = 'TEST' ) )
      MAPPED DATA(ls_mapped)
      FAILED ls_failed
      REPORTED ls_reported.

    cl_abap_unit_assert=>assert_initial( act  = ls_failed
                                         msg  = |GIVEN: could not create draft category: | &&
                                                describe_failure( is_failed = ls_failed is_reported = ls_reported )
                                         quit = if_aunit_constants=>quit-test ).
    rv_category_id = ls_mapped-category[ 1 ]-CategoryId.
  ENDMETHOD.

  METHOD given_text.
    DATA ls_failed   TYPE ts_failed.
    DATA ls_reported TYPE ts_reported.

    MODIFY ENTITIES OF zlh_c_skill_category
      ENTITY Category
        CREATE BY \_text
        FIELDS ( Language Name )
        WITH VALUE #( ( %is_draft  = if_abap_behv=>mk-on
                        CategoryId = iv_category_id
                        %target    = VALUE #( ( %cid      = 'TEXT'
                                                %is_draft = if_abap_behv=>mk-on
                                                Language  = iv_language
                                                Name      = iv_name ) ) ) )
      FAILED ls_failed
      REPORTED ls_reported.

    cl_abap_unit_assert=>assert_initial( act  = ls_failed
                                         msg  = |GIVEN: could not create text of { iv_category_id }: | &&
                                                describe_failure( is_failed = ls_failed is_reported = ls_reported )
                                         quit = if_aunit_constants=>quit-test ).
  ENDMETHOD.

  METHOD given_name_already_set.
    when_name_updated( iv_category_id = iv_category_id iv_name = iv_name ).
    cl_abap_unit_assert=>assert_initial( act  = ms_failed
                                         msg  = |GIVEN: could not set name of { iv_category_id }: | &&
                                                describe_failure( is_failed = ms_failed is_reported = ms_reported )
                                         quit = if_aunit_constants=>quit-test ).
    CLEAR: ms_failed, ms_reported.
  ENDMETHOD.

  METHOD given_logon_language.
    SET LOCALE LANGUAGE iv_language.
    cl_abap_unit_assert=>assert_equals( exp  = iv_language
                                        act  = sy-langu
                                        msg  = |GIVEN: logon language { iv_language } not set|
                                        quit = if_aunit_constants=>quit-test ).
  ENDMETHOD.

  METHOD when_updated.
    MODIFY ENTITIES OF zlh_c_skill_category
      ENTITY Category
        UPDATE FROM it_updates
      FAILED ms_failed
      REPORTED ms_reported.
  ENDMETHOD.

  METHOD when_name_updated.
    when_updated( VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                             CategoryId    = iv_category_id
                             Name          = iv_name
                             %control-Name = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD when_key_updated.
    when_updated( VALUE #( ( %is_draft            = if_abap_behv=>mk-on
                             CategoryId           = iv_category_id
                             CategoryKey          = 'KEY'
                             %control-CategoryKey = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD then_no_failures.
    cl_abap_unit_assert=>assert_initial( act  = ms_failed
                                         msg  = |Update of the category failed: | &&
                                                describe_failure( is_failed = ms_failed is_reported = ms_reported )
                                         quit = if_aunit_constants=>quit-test ).
  ENDMETHOD.

  METHOD then_text_is.
    DATA(lt_texts) = read_draft_texts( iv_category_id ).

    ASSIGN lt_texts[ Language = iv_language ] TO FIELD-SYMBOL(<ls_text>).
    cl_abap_unit_assert=>assert_subrc( exp  = 0
                                       act  = sy-subrc
                                       msg  = |No { iv_language } text for { iv_category_id }|
                                       quit = if_aunit_constants=>quit-test ).
    cl_abap_unit_assert=>assert_equals( exp = iv_name
                                        act = <ls_text>-Name
                                        msg = |{ iv_language } text name of { iv_category_id } is wrong| ).
  ENDMETHOD.

  METHOD then_text_count_is.
    cl_abap_unit_assert=>assert_equals( exp = iv_count
                                        act = lines( read_draft_texts( iv_category_id ) )
                                        msg = |Wrong number of texts for { iv_category_id }| ).
  ENDMETHOD.

  METHOD then_no_text.
    cl_abap_unit_assert=>assert_initial( act = read_draft_texts( iv_category_id )
                                         msg = |No text expected for { iv_category_id }| ).
  ENDMETHOD.

  METHOD read_draft_texts.
    READ ENTITIES OF zlh_c_skill_category
      ENTITY Category BY \_text
        ALL FIELDS WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on CategoryId = iv_category_id ) )
      RESULT rt_texts.
  ENDMETHOD.

  METHOD describe_failure.
    "fail causes + message texts, so a failing GIVEN/THEN says why
    LOOP AT is_failed-category ASSIGNING FIELD-SYMBOL(<ls_failed_cat>).
      rv_text = |{ rv_text }[Category cause { <ls_failed_cat>-%fail-cause }]|.
    ENDLOOP.
    LOOP AT is_failed-text ASSIGNING FIELD-SYMBOL(<ls_failed_txt>).
      rv_text = |{ rv_text }[Text cause { <ls_failed_txt>-%fail-cause }]|.
    ENDLOOP.
    LOOP AT is_reported-category ASSIGNING FIELD-SYMBOL(<ls_reported_cat>) WHERE %msg IS BOUND.
      rv_text = |{ rv_text } { <ls_reported_cat>-%msg->if_message~get_text( ) }|.
    ENDLOOP.
    LOOP AT is_reported-text ASSIGNING FIELD-SYMBOL(<ls_reported_txt>) WHERE %msg IS BOUND.
      rv_text = |{ rv_text } { <ls_reported_txt>-%msg->if_message~get_text( ) }|.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


"! Scenarios for LHC_CATEGORY->AUGMENT (the update(augment) handler
"! of BDEF ZLH_C_SKILL_CATEGORY). setup/teardown are inherited from
"! LTC_TEST_BASE and are intentionally not redeclared here.
"! @testing BDEF:ZLH_C_SKILL_CATEGORY
CLASS ltc_augment DEFINITION FINAL
  INHERITING FROM ltc_test_base
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS augment_creates_text   FOR TESTING RAISING cx_static_check.
    METHODS augment_updates_text   FOR TESTING RAISING cx_static_check.
    METHODS augment_no_name_no_chg FOR TESTING RAISING cx_static_check.
    "! Regression: the MODIFY AUGMENTING ENTITIES calls used to sit
    "! INSIDE the LOOP over entities_update, so for a multi-record
    "! update the rows of earlier iterations were re-submitted.
    METHODS augment_multi_new_txt  FOR TESTING RAISING cx_static_check.
    METHODS augment_multi_upd_txt  FOR TESTING RAISING cx_static_check.
    METHODS augment_mixed_control  FOR TESTING RAISING cx_static_check.
    "! Regression: texts used to be read from the active table only,
    "! so a second name change in the same draft re-created the text.
    METHODS augment_repeat_upd_txt FOR TESTING RAISING cx_static_check.
    "! Regression: texts used to be read in 'E' but written in sy-langu.
    METHODS augment_other_lang_txt FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_augment IMPLEMENTATION.

  METHOD augment_creates_text.
    DATA(lv_category) = given_new_category( ).

    when_name_updated( iv_category_id = lv_category iv_name = 'Programming' ).

    then_no_failures( ).
    then_text_count_is( iv_category_id = lv_category iv_count = 1 ).
    then_text_is( iv_category_id = lv_category iv_name = 'Programming' ).
  ENDMETHOD.

  METHOD augment_updates_text.
    DATA(lv_category) = given_new_category( ).
    given_text( iv_category_id = lv_category iv_name = 'Old name' ).

    when_name_updated( iv_category_id = lv_category iv_name = 'New name' ).

    then_no_failures( ).
    then_text_count_is( iv_category_id = lv_category iv_count = 1 ).
    then_text_is( iv_category_id = lv_category iv_name = 'New name' ).
  ENDMETHOD.

  METHOD augment_no_name_no_chg.
    DATA(lv_category) = given_new_category( ).

    when_key_updated( lv_category ).

    then_no_failures( ).
    then_no_text( lv_category ).
  ENDMETHOD.

  METHOD augment_multi_new_txt.
    DATA(lv_category_1) = given_new_category( ).
    DATA(lv_category_2) = given_new_category( ).

    when_updated( VALUE #( %is_draft     = if_abap_behv=>mk-on
                           %control-Name = if_abap_behv=>mk-on
                           ( CategoryId = lv_category_1 Name = 'First' )
                           ( CategoryId = lv_category_2 Name = 'Second' ) ) ).

    then_no_failures( ).
    then_text_is( iv_category_id = lv_category_1 iv_name = 'First' ).
    then_text_is( iv_category_id = lv_category_2 iv_name = 'Second' ).
  ENDMETHOD.

  METHOD augment_multi_upd_txt.
    DATA(lv_category_1) = given_new_category( ).
    given_text( iv_category_id = lv_category_1 iv_name = 'Old name' ).
    DATA(lv_category_2) = given_new_category( ).

    when_updated( VALUE #( %is_draft     = if_abap_behv=>mk-on
                           %control-Name = if_abap_behv=>mk-on
                           ( CategoryId = lv_category_1 Name = 'Changed' )
                           ( CategoryId = lv_category_2 Name = 'Created' ) ) ).

    then_no_failures( ).
    then_text_is( iv_category_id = lv_category_1 iv_name = 'Changed' ).
    then_text_is( iv_category_id = lv_category_2 iv_name = 'Created' ).
  ENDMETHOD.

  METHOD augment_mixed_control.
    DATA(lv_category_1) = given_new_category( ).
    DATA(lv_category_2) = given_new_category( ).

    "record without %control-Name first, so relating indexes are shifted
    when_updated( VALUE #( %is_draft = if_abap_behv=>mk-on
                           ( CategoryId           = lv_category_1
                             CategoryKey          = 'KEY'
                             %control-CategoryKey = if_abap_behv=>mk-on )
                           ( CategoryId           = lv_category_2
                             Name                 = 'Named'
                             %control-Name        = if_abap_behv=>mk-on ) ) ).

    then_no_failures( ).
    then_no_text( lv_category_1 ).
    then_text_is( iv_category_id = lv_category_2 iv_name = 'Named' ).
  ENDMETHOD.

  METHOD augment_repeat_upd_txt.
    DATA(lv_category) = given_new_category( ).
    given_name_already_set( iv_category_id = lv_category iv_name = 'First' ).

    when_name_updated( iv_category_id = lv_category iv_name = 'Second' ).

    then_no_failures( ).
    then_text_count_is( iv_category_id = lv_category iv_count = 1 ).
    then_text_is( iv_category_id = lv_category iv_name = 'Second' ).
  ENDMETHOD.

  METHOD augment_other_lang_txt.
    DATA(lv_category) = given_new_category( ).
    given_text( iv_category_id = lv_category iv_name = 'English name' ).
    given_logon_language( gc_language_de ).

    when_name_updated( iv_category_id = lv_category iv_name = 'Deutscher Name' ).

    then_no_failures( ).
    then_text_is( iv_category_id = lv_category iv_language = gc_language_de iv_name = 'Deutscher Name' ).
    then_text_is( iv_category_id = lv_category iv_language = gc_language    iv_name = 'English name' ).
  ENDMETHOD.

ENDCLASS.
