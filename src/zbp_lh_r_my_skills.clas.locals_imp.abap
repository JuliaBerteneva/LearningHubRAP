CLASS lhc_Skills DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Skills RESULT result.

    METHODS UploadFromFile FOR MODIFY
      IMPORTING keys FOR ACTION Skills~UploadFromFile.

    METHODS formCategoryIdFromText IMPORTING iv_text                TYPE zlh_skill_categ_name
                                   RETURNING VALUE(rv_category_key) TYPE zlh_category_key.

    TYPES: BEGIN OF lts_file_line,
             category_name TYPE zlh_skill_categ_name,
             skill_name    TYPE zlh_skill_name,
             level         TYPE zlh_skill_scale,
             Description   TYPE zlh_skill_description,
           END OF lts_file_line,
           ltt_file_line TYPE STANDARD TABLE OF lts_file_line.


ENDCLASS.

CLASS lhc_Skills IMPLEMENTATION.

  METHOD get_instance_authorizations.
    "filled to get rid of dump as %delete is requested during create entity inside action even in case of LOCAL MODE
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*      APPEND VALUE #(
*        %tky    = <key>-%tky
*        %update = if_abap_behv=>auth-allowed
*        %delete = if_abap_behv=>auth-allowed
*      ) TO result.
*    ENDLOOP.
  ENDMETHOD.

  METHOD UploadFromFile.
    DATA: ls_file_line TYPE lts_file_line.

    DATA: lt_category_create   TYPE TABLE FOR CREATE zlh_r_skill_category,
          ls_category_create   LIKE LINE OF lt_category_create,
          lt_skill_create      TYPE TABLE FOR CREATE zlh_r_skill,
          ls_skill_create      LIKE LINE OF lt_skill_create,
          ls_category_failed   TYPE RESPONSE FOR FAILED zlh_r_skill_category,
          ls_category_reported TYPE RESPONSE FOR REPORTED zlh_r_skill_category,
          ls_category_mapped   TYPE RESPONSE FOR MAPPED zlh_r_skill_category,
          ls_skill_failed      TYPE RESPONSE FOR FAILED zlh_r_skill,
          ls_skill_reported    TYPE RESPONSE FOR REPORTED zlh_r_skill,
          ls_skill_mapped      TYPE RESPONSE FOR MAPPED zlh_r_skill,
          ls_my_skill_failed   TYPE RESPONSE FOR FAILED zlh_r_my_skills,
          ls_my_skill_reported TYPE RESPONSE FOR REPORTED zlh_r_my_skills,
          ls_my_skill_mapped   TYPE RESPONSE FOR MAPPED zlh_r_my_skills.

    DATA(ls_param)   = keys[ 1 ]-%param.
    DATA(lv_xstring) = ls_param-attachment.

    TRY.
        DATA(lo_excel) = NEW cl_fdt_xl_spreadsheet(
          document_name = ls_param-file_name
          xdocument     = lv_xstring
        ).

        lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
          IMPORTING
            worksheet_names = DATA(lt_sheets)
        ).

        IF lt_sheets IS INITIAL.
          RETURN.
        ENDIF.

        DATA(lo_data) = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
            lt_sheets[ 1 ]
        ).

        FIELD-SYMBOLS: <lt_sheet> TYPE ANY TABLE.
        ASSIGN lo_data->* TO <lt_sheet>.

        DATA(lv_row) = 0.
        LOOP AT <lt_sheet> ASSIGNING FIELD-SYMBOL(<row>).
          lv_row += 1.
          IF lv_row = 1. CONTINUE. ENDIF. "skip the title

          ASSIGN COMPONENT 1 OF STRUCTURE <row> TO FIELD-SYMBOL(<category_name>).
          ls_file_line-category_name = <category_name>.
          ASSIGN COMPONENT 2 OF STRUCTURE <row> TO FIELD-SYMBOL(<skill_name>).
          ls_file_line-skill_name = <skill_name>.
          ASSIGN COMPONENT 3 OF STRUCTURE <row> TO FIELD-SYMBOL(<level>).
          ls_file_line-level = <level>.
          ASSIGN COMPONENT 4 OF STRUCTURE <row> TO FIELD-SYMBOL(<skill_description>).
          ls_file_line-description = <Skill_description>.

          "try to find already existing category
          SELECT SINGLE category_id FROM  zlh_skill_categt WHERE name = @ls_file_line-category_name INTO @DATA(lv_category_id).
          IF sy-subrc IS NOT INITIAL. "if there is no such category, no such skill also.
            ls_category_create-CategoryKey = formCategoryIdFromText( ls_file_line-category_name ).
            MODIFY ENTITIES OF zlh_r_skill_category
                ENTITY Category
                CREATE FIELDS ( CategoryKey )
                    WITH VALUE #( ( %cid     = 'cid1' CategoryKey = ls_category_create-CategoryKey ) )

                CREATE BY \_text FIELDS ( CategoryKey Name )
                  WITH VALUE #(   ( %cid_ref = 'cid1'
                                    %target  = VALUE #(
                                                   ( %cid     = 'cid_text1'
                                                     Language = sy-langu
                                                     Name     = ls_file_line-category_name )
                                                   )
                                ) )

                FAILED ls_category_failed
                REPORTED ls_category_reported
                MAPPED ls_category_mapped.
            IF ls_category_mapped-category IS NOT INITIAL.
              lv_category_id = ls_category_mapped-category[ 1 ]-CategoryId.
            ENDIF.
*            IF ls_category_failed-category IS INITIAL.
*              MODIFY ENTITIES OF zlh_r_skill_category
*                  ENTITY Category
*                  CREATE BY \_text FIELDS ( CategoryKey Name )
*                  WITH VALUE #( ( %cid_ref = 'cid1'
*                                  %target  = VALUE #(
*                                                   ( %cid     = 'cid_text1'
*                                                     Language = sy-langu
*                                                     Name     = ls_file_line-category_name )
*                                                   )
*                                ) ).
*            ENDIF.

          ENDIF.

          SELECT SINGLE skill_id FROM zlh_skills WHERE name = @ls_file_line-skill_name INTO @DATA(lv_skill_id).
          IF sy-subrc IS NOT INITIAL.
            MODIFY ENTITIES OF zlh_r_skill
                ENTITY zlh_r_skill
                CREATE FIELDS ( Name Description Category )
                WITH VALUE #( ( %cid = 'cid1' Name = ls_file_line-skill_name Description = ls_file_line-description Category = lv_category_id ) )
                FAILED ls_skill_failed
                REPORTED ls_skill_reported
                MAPPED ls_skill_mapped.
            IF ls_skill_mapped-zlh_r_skill IS NOT INITIAL.
              lv_skill_id = ls_skill_mapped-zlh_r_skill[ 1 ]-SkillId.
            ENDIF.
          ENDIF.

          IF ls_file_line-level IS NOT INITIAL.
            READ ENTITIES OF zlh_r_my_skills IN LOCAL MODE
              ENTITY Skills
              FIELDS ( SkillId UserID )
              WITH VALUE #( ( SkillId = lv_skill_id UserId = sy-uname ) )
              RESULT DATA(lt_result).

            IF lt_result IS INITIAL.
              MODIFY ENTITIES OF zlh_r_my_skills IN LOCAL MODE
                  ENTITY Skills
                  CREATE FIELDS ( Category Scale SkillId UserId )
                  WITH VALUE #( ( %cid = 'cid1' Category = lv_category_id Scale = ls_file_line-level SkillID = lv_skill_id UserId = sy-uname ) )
                  FAILED ls_my_skill_failed
                  REPORTED ls_my_skill_reported
                  MAPPED ls_my_skill_mapped.
            ELSE.

              MODIFY ENTITIES OF zlh_r_my_skills IN LOCAL MODE
                  ENTITY Skills
                  UPDATE FIELDS ( Scale Category )
                  WITH VALUE #( ( Scale = ls_file_line-level Category = lv_category_id ) )
                  FAILED ls_my_skill_failed
                  REPORTED ls_my_skill_reported
                  MAPPED ls_my_skill_mapped.
            ENDIF.
          ENDIF.

        ENDLOOP.

      CATCH cx_fdt_excel_core INTO DATA(lx_error).
        DATA(lv_msg) = lx_error->get_text( ).
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD formCategoryIdFromText.
  ENDMETHOD.

ENDCLASS.
