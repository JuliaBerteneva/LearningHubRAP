CLASS lhc_category DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment FOR MODIFY
      IMPORTING entities_update FOR UPDATE category.

    TYPES: BEGIN OF ts_category,
             category_id TYPE zlh_skill_categt-category_id,
             name        TYPE zlh_skill_categt-name,
           END OF ts_category,
           tt_category_id TYPE SORTED TABLE OF ts_category WITH UNIQUE KEY category_id.
ENDCLASS.

CLASS lhc_category IMPLEMENTATION.

  METHOD augment.
    DATA: relates_create TYPE abp_behv_relating_tab.
    DATA: relates_update TYPE abp_behv_relating_tab.
    DATA: category_text_cr      TYPE TABLE FOR CREATE zlh_r_skill_category\_text.
    DATA: category_text_up     TYPE TABLE FOR UPDATE zlh_r_skill_category_text.
    DATA: texts_db TYPE tt_category_id.

    FIELD-SYMBOLS: <ls_db> TYPE ts_category.

    SELECT category_id, name
        FROM zlh_skill_categt
        INTO TABLE @texts_db
        FOR ALL ENTRIES IN @entities_update
        WHERE category_id = @entities_update-CategoryId
          AND language = 'E'.

    LOOP AT entities_update ASSIGNING FIELD-SYMBOL(<entity_upd>)
    WHERE %control-Name = if_abap_behv=>mk-on.
      ASSIGN texts_db[ category_id = <entity_upd>-categoryid ] TO <ls_db>.
      IF sy-subrc IS NOT INITIAL. "creation of a new record
        APPEND sy-tabix TO relates_create.
        INSERT VALUE #( %is_draft       = <entity_upd>-%is_draft
                        %key-CategoryId = <entity_upd>-%key-CategoryId
                        %target         = VALUE #( ( %cid      = |CREATETEXTCID{ sy-tabix }|
                                                     %is_draft = <entity_upd>-%is_draft
                                                     Language  = sy-langu
                                                     Name      = <entity_upd>-Name
                                                     %control  = VALUE #(
                                                               language = if_abap_behv=>mk-on
                                                               Name     = if_abap_behv=>mk-on ) ) )
                      ) INTO TABLE category_text_cr.
      ELSE. "update existing
        IF <ls_db>-name <> <entity_upd>-Name AND NOT line_exists( category_text_up[ key entity CategoryId = <entity_upd>-%key-CategoryId ] ).
          APPEND sy-tabix TO relates_update.
          INSERT VALUE #( %is_draft       = <entity_upd>-%is_draft
                          %key-CategoryId = <entity_upd>-%key-CategoryId
                          Language        = sy-langu
                          Name            = <entity_upd>-Name
                          %control        = VALUE #(
                                              language = if_abap_behv=>mk-on
                                              Name     = if_abap_behv=>mk-on )
                        ) INTO TABLE category_text_up.
        ENDIF.

      ENDIF.
      IF category_text_cr IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF zlh_r_skill_category
          ENTITY Category
            CREATE BY \_text
            FROM category_text_cr
            RELATING TO entities_update BY relates_create.
      ENDIF.
      IF category_text_up IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF zlh_r_skill_category
          ENTITY Text
            UPDATE FIELDS ( Name )
            WITH CORRESPONDING #( category_text_up ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
