CLASS lhc_category DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment FOR MODIFY
      IMPORTING entities_update FOR UPDATE category.
    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE category.
ENDCLASS.

CLASS lhc_category IMPLEMENTATION.

  METHOD augment.
    DATA: relates_create   TYPE abp_behv_relating_tab.
    DATA: relates_update   TYPE abp_behv_relating_tab.
    DATA: category_text_cr TYPE TABLE FOR CREATE zlh_r_skill_category\_text.
    DATA: category_text_up TYPE TABLE FOR UPDATE zlh_r_skill_category_text.

    IF entities_update IS INITIAL.
      RETURN.
    ENDIF.

    "read via EML, not SELECT: sees draft texts and texts already
    "created/changed in the current transaction
    READ ENTITIES OF zlh_r_skill_category
      ENTITY Category BY \_text
        FIELDS ( Name )
        WITH VALUE #( FOR entity IN entities_update WHERE ( %control-Name = if_abap_behv=>mk-on )
                      ( %is_draft  = entity-%is_draft
                        CategoryId = entity-CategoryId ) )
      RESULT DATA(texts_db).

    LOOP AT entities_update ASSIGNING FIELD-SYMBOL(<entity_upd>)
    WHERE %control-Name = if_abap_behv=>mk-on.
      "index into entities_update, needed for RELATING and %cid
      DATA(entity_index) = sy-tabix.

      ASSIGN texts_db[ %is_draft  = <entity_upd>-%is_draft
                       CategoryId = <entity_upd>-CategoryId
                       Language   = sy-langu ] TO FIELD-SYMBOL(<text_db>).
      IF sy-subrc <> 0. "no text in logon language yet - create it
        APPEND entity_index TO relates_create.
        INSERT VALUE #( %is_draft       = <entity_upd>-%is_draft
                        %key-CategoryId = <entity_upd>-%key-CategoryId
                        %target         = VALUE #( ( %cid      = |CREATETEXTCID{ entity_index }|
                                                     %is_draft = <entity_upd>-%is_draft
                                                     Language  = sy-langu
                                                     Name      = <entity_upd>-Name
                                                     %control  = VALUE #(
                                                               Language = if_abap_behv=>mk-on
                                                               Name     = if_abap_behv=>mk-on ) ) )
                      ) INTO TABLE category_text_cr.
      ELSEIF <text_db>-Name <> <entity_upd>-Name. "update existing
        APPEND entity_index TO relates_update.
        INSERT VALUE #( %is_draft       = <entity_upd>-%is_draft
                        %key-CategoryId = <entity_upd>-%key-CategoryId
                        %key-Language   = sy-langu
                        Name            = <entity_upd>-Name
                        %control-Name   = if_abap_behv=>mk-on
                      ) INTO TABLE category_text_up.
      ENDIF.
    ENDLOOP.

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
          UPDATE FROM category_text_up
          RELATING TO entities_update BY relates_update.
    ENDIF.
  ENDMETHOD.

  METHOD augment_create.
    DATA: relates_create   TYPE abp_behv_relating_tab.
    DATA: category_text_cr TYPE TABLE FOR CREATE zlh_r_skill_category\_text.

    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity_cr>)
    WHERE %control-Name  = if_abap_behv=>mk-on.
      DATA(entity_index) = sy-tabix.
      APPEND entity_index TO relates_create.
      INSERT VALUE #( %cid_ref = <entity_cr>-%cid
                      %is_draft = <entity_cr>-%is_draft
                      %target = VALUE #( ( %cid    = |CREATETEXTCID{ entity_index }|
                                           %is_draft = <entity_cr>-%is_draft
                                           Language  = sy-langu
                                           Name      = <entity_cr>-Name
                                           %control  = VALUE #( Language = if_abap_behv=>mk-on
                                                                Name     = if_abap_behv=>mk-on ) ) )
                    ) INTO TABLE category_text_cr.
    ENDLOOP.

    IF category_text_cr IS NOT INITIAL.
      MODIFY AUGMENTING ENTITIES OF zlh_r_skill_category
        ENTITY Category
          CREATE BY \_text
          FROM category_text_cr
          RELATING TO entities BY relates_create.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
