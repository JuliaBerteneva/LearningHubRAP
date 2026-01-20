*&---------------------------------------------------------------------*
*& Report zlh_test
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlh_test.

DATA create TYPE TABLE FOR CREATE zlh_c_skill_category.
create = VALUE #( ( %cid       = 'create_category'
                    %is_draft  = if_abap_behv=>mk-off
                    CategoryId = '1234'
                     ) ).

*MODIFY ENTITIES OF zlh_r_skill_category
*  ENTITY category
*  CREATE fields ( CategoryKey ) with create
*    create by \_text
*    fields ( Name )
*    with VALUE #( (  %cid_ref =  'create_category'  %target = VALUE #( ( %cid         = 'create_category_text'
*
*                                          %is_draft    = if_abap_behv=>mk-off
*
*                                          Name  = 'Test from Report' ) ) ) )
*    REPORTED DATA(reported)
*    FAILED   DATA(lt_failed).


MODIFY ENTITIES OF zlh_c_skill_category
  ENTITY category
  CREATE fields ( CategoryKey ) with create
    create by \_text
    fields ( Name )
    with VALUE #( (  %cid_ref =  'create_category'  %target = VALUE #( ( %cid         = 'create_category_text'

                                          %is_draft    = if_abap_behv=>mk-off
                                          Language = 'E'
                                          Name  = 'Test from Report3' ) ) ) )
    REPORTED DATA(reported)
    FAILED   DATA(lt_failed).

COMMIT ENTITIES.
