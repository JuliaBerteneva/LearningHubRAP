CLASS zcl_lh_virtual DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_lh_virtual IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
*    INSERT `VIRTTEST` INTO TABLE et_requested_orig_elements.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zLH_c_status_vh_proj WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).
      <ls_original_data>-VirtTest = abap_true.
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #(  lt_original_data ).
  ENDMETHOD.
ENDCLASS.
