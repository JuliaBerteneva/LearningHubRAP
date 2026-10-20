CLASS lcl_excel_helper DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF lts_raw_excel_line,
             category_name TYPE string,
             skill_name    TYPE string,
             level         TYPE string,
             description   TYPE string,
           END OF lts_raw_excel_line,
           ltt_raw_excel_line TYPE STANDARD TABLE OF lts_raw_excel_line WITH EMPTY KEY.

    TYPES: BEGIN OF lts_excel_line,
             category_name TYPE zlh_skill_categ_name,
             skill_name    TYPE zlh_skill_name,
             level         TYPE zlh_skill_scale,
             description   TYPE zlh_skill_description,
           END OF lts_excel_line,
           ltt_excel_line TYPE STANDARD TABLE OF lts_excel_line WITH EMPTY KEY.

    CLASS-METHODS read_file
      IMPORTING iv_file_content TYPE xstring
      RETURNING VALUE(rt_rows)  TYPE ltt_raw_excel_line
      RAISING   cx_root.

    CLASS-METHODS parse_rows
      IMPORTING it_raw_rows    TYPE ltt_raw_excel_line
      RETURNING VALUE(rt_rows) TYPE ltt_excel_line
      RAISING   cx_root.
ENDCLASS.

CLASS lcl_excel_helper IMPLEMENTATION.
  METHOD read_file.
    DATA lt_raw_rows TYPE ltt_raw_excel_line.

    DATA(lo_document) =
      xco_cp_xlsx=>document->for_file_content(
        iv_file_content )->read_access( ).

    DATA(lo_worksheet) =
      lo_document->get_workbook( )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) =
      xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_row(
          xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
        )->get_pattern( ).

    lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_raw_rows )
      )->set_value_transformation(
        xco_cp_xlsx_read_access=>value_transformation->string_value
      )->execute( ).
    rt_rows = lt_raw_rows.
  ENDMETHOD.

  METHOD parse_rows.
    LOOP AT it_raw_rows INTO DATA(ls_raw_row).
      CONDENSE ls_raw_row-category_name.
      CONDENSE ls_raw_row-skill_name.
      CONDENSE ls_raw_row-level NO-GAPS.

      IF ls_raw_row-category_name IS INITIAL
          OR ls_raw_row-skill_name IS INITIAL
          OR ls_raw_row-level IS INITIAL
          OR ls_raw_row-level CN '0123456789.'.
        CONTINUE.
      ENDIF.

      TRY.
          APPEND VALUE #(
            category_name = ls_raw_row-category_name
            skill_name    = ls_raw_row-skill_name
            level         = CONV zlh_skill_scale( ls_raw_row-level )
            description   = ls_raw_row-description )
            TO rt_rows.
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_Skills DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      ty_reported       TYPE RESPONSE FOR REPORTED EARLY zlh_r_my_skills,
      ty_failed         TYPE RESPONSE FOR FAILED   EARLY zlh_r_my_skills,

      tt_messages       TYPE STANDARD TABLE OF REF TO if_abap_behv_message WITH EMPTY KEY,
      tt_category_names TYPE STANDARD TABLE OF zlh_skill_categ_name        WITH EMPTY KEY,
      tt_skill_names    TYPE STANDARD TABLE OF zlh_skill_name              WITH EMPTY KEY,

      BEGIN OF ty_category,
        category_id TYPE zlh_skill_categt-category_id,
        name        TYPE zlh_skill_categt-name,
      END OF ty_category,
      tt_category TYPE SORTED TABLE OF ty_category WITH NON-UNIQUE KEY name,

      BEGIN OF ty_skill,
        skill_id TYPE zlh_skills-skill_id,
        name     TYPE zlh_skills-name,
      END OF ty_skill,
      tt_skill TYPE SORTED TABLE OF ty_skill WITH NON-UNIQUE KEY name,

      BEGIN OF ty_new_category,
        name TYPE zlh_skill_categ_name,
        category_key TYPE zlh_category_key,
        cid  TYPE string,
      END OF ty_new_category,
      tt_new_category TYPE SORTED TABLE OF ty_new_category
                      WITH UNIQUE KEY name
                      WITH UNIQUE SORTED KEY cid COMPONENTS cid
                      WITH UNIQUE SORTED KEY category_key COMPONENTS category_key,

      BEGIN OF ty_new_skill,
        name        TYPE zlh_skill_name,
        description TYPE zlh_skill_description,
        category_id TYPE zlh_skill_categt-category_id,
        cid         TYPE string,
      END OF ty_new_skill,
      tt_new_skill TYPE SORTED TABLE OF ty_new_skill
                   WITH UNIQUE KEY name
                   WITH UNIQUE SORTED KEY cid COMPONENTS cid,

      BEGIN OF ty_user_skill,
        skill_id    TYPE zlh_skills-skill_id,
        category_id TYPE zlh_skill_categt-category_id,
        level       TYPE zlh_skill_scale,
      END OF ty_user_skill,
      tt_user_skill TYPE SORTED TABLE OF ty_user_skill WITH UNIQUE KEY skill_id.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Skills RESULT result.

    METHODS UploadFromFile FOR MODIFY
      IMPORTING keys FOR ACTION Skills~UploadFromFile.

    METHODS resolve_categories
      IMPORTING it_rows       TYPE lcl_excel_helper=>ltt_excel_line
      EXPORTING et_categories TYPE tt_category
      CHANGING  cs_reported   TYPE ty_reported
                cs_failed     TYPE ty_failed.

    METHODS resolve_skills
      IMPORTING it_rows       TYPE lcl_excel_helper=>ltt_excel_line
                it_categories TYPE tt_category
      EXPORTING et_skills     TYPE tt_skill
      CHANGING  cs_reported   TYPE ty_reported
                cs_failed     TYPE ty_failed.

    METHODS assign_skills_to_user
      IMPORTING it_rows       TYPE lcl_excel_helper=>ltt_excel_line
                it_categories TYPE tt_category
                it_skills     TYPE tt_skill
      CHANGING  cs_reported   TYPE ty_reported
                cs_failed     TYPE ty_failed.

    " response helpers
    METHODS add_error
      IMPORTING iv_text     TYPE string
      CHANGING  cs_reported TYPE ty_reported
                cs_failed   TYPE ty_failed.

    METHODS forward_result
      IMPORTING it_messages TYPE tt_messages
                iv_failed   TYPE abap_bool
      CHANGING  cs_reported TYPE ty_reported
                cs_failed   TYPE ty_failed.


    METHODS formCategoryIdFromText IMPORTING iv_text                TYPE zlh_skill_categ_name
                                   RETURNING VALUE(rv_category_key) TYPE zlh_category_key.

ENDCLASS.

CLASS lhc_Skills IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD UploadFromFile.
    TRY.
        DATA(lt_raw_rows) = lcl_excel_helper=>read_file( keys[ 1 ]-%param-attachment ).
        DATA(lt_rows)     = lcl_excel_helper=>parse_rows( lt_raw_rows ).

        IF lt_rows IS INITIAL.
          add_error( EXPORTING iv_text     = |The Excel file was read, but no valid data rows were found after the header row.|
                     CHANGING  cs_reported = reported
                               cs_failed   = failed ).
          RETURN.
        ENDIF.

        resolve_categories( EXPORTING it_rows       = lt_rows
                           IMPORTING et_categories = DATA(lt_categories)
                           CHANGING  cs_reported   = reported
                                     cs_failed     = failed ).
        IF failed-skills IS NOT INITIAL.
          RETURN.
        ENDIF.

        resolve_skills( EXPORTING it_rows       = lt_rows
                                 it_categories = lt_categories
                       IMPORTING et_skills     = DATA(lt_skills)
                       CHANGING  cs_reported   = reported
                                 cs_failed     = failed ).
        IF failed-skills IS NOT INITIAL.
          RETURN.
        ENDIF.

        assign_skills_to_user( EXPORTING it_rows       = lt_rows
                                         it_categories = lt_categories
                                         it_skills     = lt_skills
                               CHANGING  cs_reported   = reported
                                         cs_failed     = failed ).
        IF failed-skills IS NOT INITIAL.
          RETURN.
        ENDIF.

        DATA(lv_skipped) = lines( lt_raw_rows ) - lines( lt_rows ).
        APPEND VALUE #(
          %msg = new_message_with_text(
            severity = COND #( WHEN lv_skipped > 0
                               THEN if_abap_behv_message=>severity-warning
                               ELSE if_abap_behv_message=>severity-success )
            text     = |Processed { lines( lt_rows ) } Excel row(s), skipped { lv_skipped } invalid row(s).| ) )
          TO reported-skills.

      CATCH cx_root INTO DATA(lx_error).
        add_error( EXPORTING iv_text     = |Upload failed: { lx_error->get_text( ) }|
                   CHANGING  cs_reported = reported
                             cs_failed   = failed ).
    ENDTRY.
  ENDMETHOD.

  METHOD formCategoryIdFromText.
    rv_category_key = replace( val  = to_upper( iv_text )
                      pcre = `[^A-Z0-9]+`
                      with = `_`
                      occ  = 0 ).
  ENDMETHOD.

  METHOD add_error.
    APPEND VALUE #(
      %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-error
        text     = iv_text ) )
      TO cs_reported-skills.
    APPEND VALUE #( %fail-cause = if_abap_behv=>cause-unspecific )
      TO cs_failed-skills.
  ENDMETHOD.

  METHOD assign_skills_to_user.
    DATA lt_user_skills TYPE tt_user_skill.
    DATA lt_create      TYPE TABLE FOR CREATE zlh_r_my_skills.
    DATA lt_update      TYPE TABLE FOR UPDATE zlh_r_my_skills.

    " one entry per skill
    LOOP AT it_rows ASSIGNING FIELD-SYMBOL(<ls_file_row>).
      INSERT VALUE #( skill_id    = it_skills[ name = <ls_file_row>-skill_name ]-skill_id
                      category_id = it_categories[ name = <ls_file_row>-category_name ]-category_id
                      level       = <ls_file_row>-level )
        INTO TABLE lt_user_skills.
    ENDLOOP.

    " what the user already has
    READ ENTITIES OF zlh_r_my_skills IN LOCAL MODE
      ENTITY Skills
        FIELDS ( SkillId UserId )
        WITH VALUE #( FOR <ls_user_skill> IN lt_user_skills
                      ( SkillId = <ls_user_skill>-skill_id
                        UserId  = sy-uname ) )
      RESULT DATA(lt_existing).

    " split into update  and create
    LOOP AT lt_user_skills ASSIGNING FIELD-SYMBOL(<ls_skill_row>).
      DATA(lv_index) = sy-tabix.

      ASSIGN lt_existing[ SkillId = <ls_skill_row>-skill_id ] TO FIELD-SYMBOL(<ls_existing>).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky     = <ls_existing>-%tky
                        Scale    = <ls_skill_row>-level
                        Category = <ls_skill_row>-category_id )
          TO lt_update.
      ELSE.
        APPEND VALUE #( %cid     = |user_skill_{ lv_index }|
                        Category = <ls_skill_row>-category_id
                        Scale    = <ls_skill_row>-level
                        SkillID  = <ls_skill_row>-skill_id
                        UserId   = sy-uname )
          TO lt_create.
      ENDIF.
    ENDLOOP.

    " save
    MODIFY ENTITIES OF zlh_r_my_skills IN LOCAL MODE
      ENTITY Skills
        CREATE FIELDS ( Category Scale SkillId UserId ) WITH lt_create
        UPDATE FIELDS ( Scale Category )                WITH lt_update
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported).

    forward_result(
      EXPORTING it_messages = VALUE #( FOR <ls_msg> IN ls_reported-skills
                                       WHERE ( %msg IS BOUND )
                                       ( <ls_msg>-%msg ) )
                iv_failed   = xsdbool( ls_failed-skills IS NOT INITIAL )
      CHANGING  cs_reported = cs_reported
                cs_failed   = cs_failed ).
  ENDMETHOD.

  METHOD resolve_categories.
    " what already exists
    DATA(lt_names) = VALUE tt_category_names(
      FOR GROUPS lv_name OF <ls_row> IN it_rows
      GROUP BY <ls_row>-category_name ( lv_name ) ).

    SELECT FROM zlh_skill_categt
      FIELDS category_id, name
      FOR ALL ENTRIES IN @lt_names
      WHERE name = @lt_names-table_line AND language = @sy-langu
      INTO TABLE @et_categories.

    " what is missing
    DATA lt_new TYPE tt_new_category.
    LOOP AT it_rows ASSIGNING FIELD-SYMBOL(<ls_file_row>).
      IF line_exists( et_categories[ name = <ls_file_row>-category_name ] )
          OR line_exists( lt_new[ name = <ls_file_row>-category_name ] ).
        CONTINUE.
      ENDIF.

      " two different names must not produce the same key
      DATA(lv_key) = formcategoryidfromtext( <ls_file_row>-category_name ).
      ASSIGN lt_new[ KEY category_key category_key = lv_key ] TO FIELD-SYMBOL(<ls_clash>).
      IF sy-subrc = 0.
        add_error( EXPORTING iv_text     = |Categories '{ <ls_clash>-name }' and '{ <ls_file_row>-category_name }' | &&
                                           |would get the same key '{ lv_key }'. Please rename one of them.|
                   CHANGING  cs_reported = cs_reported
                             cs_failed   = cs_failed ).
        RETURN.
      ENDIF.

      INSERT VALUE #( name         = <ls_file_row>-category_name
                      category_key = lv_key
                      cid          = |category_{ lines( lt_new ) + 1 }| )
        INTO TABLE lt_new.
    ENDLOOP.
    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    " create them
    MODIFY ENTITIES OF zlh_r_skill_category
      ENTITY Category
        CREATE FIELDS ( CategoryKey )
          WITH VALUE #( FOR <ls_new> IN lt_new
                        ( %cid        = <ls_new>-cid
                          CategoryKey = <ls_new>-category_key ) )
        CREATE BY \_text FIELDS ( CategoryKey Name )
          WITH VALUE #( FOR <ls_new> IN lt_new
                        ( %cid_ref = <ls_new>-cid
                          %target  = VALUE #( ( %cid     = |{ <ls_new>-cid }_text|
                                                Language = sy-langu
                                                Name     = <ls_new>-name ) ) ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported)
      MAPPED   DATA(ls_mapped).

    " hand messages / failure over to the action response
    forward_result(
      EXPORTING it_messages = VALUE #( FOR <ls_msg> IN ls_reported-category
                                       WHERE ( %msg IS BOUND )
                                       ( <ls_msg>-%msg ) )
                iv_failed   = xsdbool( ls_failed-category IS NOT INITIAL )
      CHANGING  cs_reported = cs_reported
                cs_failed   = cs_failed ).

    " mapped contains only successful creations -> add them straight in
    INSERT LINES OF VALUE tt_category(
        FOR <ls_mapped> IN ls_mapped-category
        ( category_id = <ls_mapped>-CategoryId
          name        = lt_new[ KEY cid cid = <ls_mapped>-%cid ]-name ) )
      INTO TABLE et_categories.
  ENDMETHOD.

  METHOD resolve_skills.
    " what already exists
    DATA(lt_names) = VALUE tt_skill_names(
      FOR GROUPS lv_name OF <ls_row> IN it_rows
      GROUP BY <ls_row>-skill_name ( lv_name ) ).

    SELECT FROM zlh_skills
      FIELDS skill_id, name
      FOR ALL ENTRIES IN @lt_names
      WHERE name = @lt_names-table_line
      INTO TABLE @et_skills.

    " what is missing
    DATA lt_new TYPE tt_new_skill.
    LOOP AT it_rows ASSIGNING FIELD-SYMBOL(<ls_file_row>).
      IF NOT line_exists( et_skills[ name = <ls_file_row>-skill_name ] ).
        INSERT VALUE #( name        = <ls_file_row>-skill_name
                        description = <ls_file_row>-description
                        category_id = it_categories[ name = <ls_file_row>-category_name ]-category_id
                        cid         = |skill_{ lines( lt_new ) + 1 }| )
          INTO TABLE lt_new.
      ENDIF.
    ENDLOOP.
    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    " create them
    MODIFY ENTITIES OF zlh_r_skill
      ENTITY Skill
        CREATE FIELDS ( Name Description Category )
          WITH VALUE #( FOR <ls_new> IN lt_new
                        ( %cid        = <ls_new>-cid
                          Name        = <ls_new>-name
                          Description = <ls_new>-description
                          Category    = <ls_new>-category_id ) )
      FAILED   DATA(ls_failed)
      REPORTED DATA(ls_reported)
      MAPPED   DATA(ls_mapped).

    " hand messages / failure over to the action response
    forward_result(
      EXPORTING it_messages = VALUE #( FOR <ls_msg> IN ls_reported-skill
                                       WHERE ( %msg IS BOUND )
                                       ( <ls_msg>-%msg ) )
                iv_failed   = xsdbool( ls_failed-skill IS NOT INITIAL )
      CHANGING  cs_reported = cs_reported
                cs_failed   = cs_failed ).

    " add successfully created skills
    INSERT LINES OF VALUE tt_skill(
        FOR <ls_mapped> IN ls_mapped-skill
        ( skill_id = <ls_mapped>-SkillId
          name     = lt_new[ KEY cid cid = <ls_mapped>-%cid ]-name ) )
      INTO TABLE et_skills.
  ENDMETHOD.

  METHOD forward_result.
    cs_reported-skills = VALUE #( BASE cs_reported-skills
                                  FOR <lo_msg> IN it_messages
                                  ( %msg = <lo_msg> ) ).
    IF iv_failed = abap_true.
      APPEND VALUE #( %fail-cause = if_abap_behv=>cause-unspecific )
        TO cs_failed-skills.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
