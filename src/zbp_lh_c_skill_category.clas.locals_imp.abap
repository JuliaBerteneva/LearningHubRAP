CLASS lhc_category DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE category.

    METHODS augment_update FOR MODIFY
      IMPORTING entities FOR UPDATE category.

ENDCLASS.

CLASS lhc_category IMPLEMENTATION.

  METHOD augment_create.

*  MODIFY AUGMENTING ENTITIES OF /DMO/I_Supplement
*      ENTITY SupplementText
*        UPDATE FROM supplementtext_update
*        RELATING TO entities_update BY relates_update
*      ENTITY Supplement
*        CREATE BY \_SupplementText
*        FROM suppltext_for_existing_suppl
*        RELATING TO entities_update BY relates_cba.

  ENDMETHOD.

  METHOD augment_update.
  ENDMETHOD.

ENDCLASS.
