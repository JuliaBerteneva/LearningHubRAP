CLASS lsc_zlh_r_skill_category DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zlh_r_skill_category IMPLEMENTATION.

  METHOD save_modified.
    DATA category_text TYPE TABLE OF zlh_skill_categt.

*    IF create-category IS NOT INITIAL.
*
*      READ ENTITIES OF zlh_r_skill_category IN LOCAL MODE
*          ENTITY category
*          FIELDS ( categoryid name )
*          WITH CORRESPONDING #( create-category )
*      RESULT DATA(categories).
*
*      category_text = value #( for category in categories ( category_id = category-categoryid
*                                                            name = category-name
*                                                            language = sy-langu ) ).
*
*      MODIFY zlh_skill_categt FROM TABLE category_text.
*    ENDIF.
*
*    IF update-category IS NOT INITIAL.
*
*      READ ENTITIES OF zlh_r_skill_category IN LOCAL MODE
*          ENTITY category
*          FIELDS ( categoryid name )
*          WITH CORRESPONDING #( update-category )
*      RESULT categories.
*
*      category_text = value #( for category in categories ( category_id = category-categoryid
*                                                            name = category-name
*                                                            language = sy-langu ) ).
*
*      MODIFY zlh_skill_categt FROM TABLE category_text.
*    ENDIF.
*
*    IF delete-category IS NOT INITIAL.
*
*      READ ENTITIES OF zlh_r_skill_category IN LOCAL MODE
*          ENTITY category
*          FIELDS ( categoryid name )
*          WITH CORRESPONDING #( update-category )
*      RESULT categories.
*
*      category_text = value #( for category in categories ( category_id = category-categoryid
*                                                            name = category-name
*                                                            language = sy-langu ) ).
*
*      MODIFY zlh_skill_categt FROM TABLE category_text.
*    ENDIF.
*
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zlh_r_skill_category DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR category RESULT result.

ENDCLASS.

CLASS lhc_zlh_r_skill_category IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
