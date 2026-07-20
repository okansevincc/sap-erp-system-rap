CLASS ltcl_po_create_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: tt_po_itm TYPE STANDARD TABLE OF zfab_t_po_itm.

    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA: ms_base_bp     TYPE zfab_t_bp,
          ms_base_mat    TYPE zfab_t_mat,
          ms_base_po_hdr TYPE zfab_t_po_hdr,
          mt_base_po_itm TYPE tt_po_itm.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_create_test IMPORTING is_po_hdr_data TYPE zfab_t_po_hdr
                                    it_po_itm_data TYPE tt_po_itm
                                    iv_msgno       TYPE symsgno,
      validate_hdr_supplier_init FOR TESTING,
      validate_hdr_waers_init    FOR TESTING,
      validate_itm_material_init FOR TESTING,
      validate_itm_qty_invalid   FOR TESTING,
      validate_itm_price_invalid FOR TESTING,
      validate_itm_uom_init      FOR TESTING,
      validate_supplier_exists   FOR TESTING,
      validate_supplier_role     FOR TESTING,
      validate_material_exists   FOR TESTING,
      test_initial_status_open   FOR TESTING,
      test_item_position_calc    FOR TESTING,
      test_header_total_calc     FOR TESTING,
      test_det_item_currency     FOR TESTING,
      validate_active_req_item   FOR TESTING,
      test_create_happy_path     FOR TESTING.

ENDCLASS.

CLASS ltcl_po_create_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_MAT' )
                                                                                                      ( i_for_entity = 'ZFAB_R_BP' )
                                                                                                      ( i_for_entity = 'ZFAB_R_PO_HDR' )
                                                                                                      ( i_for_entity = 'ZFAB_R_PO_ITM' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    go_mock_environment->clear_doubles(  ).

    DATA: lt_mock_bp  TYPE STANDARD TABLE OF zfab_t_bp,
          lt_mock_mat TYPE STANDARD TABLE OF zfab_t_mat.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'S' ).
    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).

    APPEND ms_base_bp TO lt_mock_bp.
    APPEND ms_base_mat TO lt_mock_mat.

    go_mock_environment->insert_test_data( i_data = lt_mock_bp ).
    go_mock_environment->insert_test_data( i_data = lt_mock_mat ).

    ms_base_po_hdr = zcl_fab_mock_factory=>get_valid_po_header( iv_vendor_uuid = ms_base_bp-bp_uuid ).
    mt_base_po_itm = zcl_fab_mock_factory=>get_valid_po_items( po_header_uuid = ms_base_po_hdr-po_uuid iv_mat_uuid = ms_base_mat-mat_uuid ).

  ENDMETHOD.

  METHOD teardown.

    CLEAR: ms_base_bp,
           ms_base_mat,
           ms_base_po_hdr,
           mt_base_po_itm.
    go_mock_environment->clear_doubles(  ).

  ENDMETHOD.

  METHOD execute_create_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
    ENTITY Purchase CREATE FIELDS ( VendorUuid Status TotalAmount Waers )
    WITH VALUE #( (
    VendorUuid = is_po_hdr_data-vendor_uuid
    Status = is_po_hdr_data-status
    TotalAmount = is_po_hdr_data-total_amount
    Waers = is_po_hdr_data-waers
    ) )
    CREATE BY \_PurchaseItems
    FIELDS ( MatUuid Quantity UnitUom UnitPrice Waers )
    WITH VALUE #( (
    %cid_ref = 'HEADER_ID'
    %target = VALUE #( FOR ls_po_itm IN it_po_itm_data (
    %cid      = |ITEM_{ ls_po_itm-item_pos }|
    MatUuid = ls_po_itm-mat_uuid
    Quantity = ls_po_itm-quantity
    UnitUom = ls_po_itm-unit_uom
    UnitPrice = ls_po_itm-unit_price
    Waers = ls_po_itm-waers
     ) )
      ) ) FAILED lt_failed
          REPORTED lt_reported.

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lt_failed-purchase IS NOT INITIAL OR lt_failed-purchaseitems IS NOT INITIAL )
      msg = 'Create islemi engellenmeliydi ama basari ile create edildi!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-purchase INTO DATA(ls_rep_hdr).
      IF ls_rep_hdr-%msg IS BOUND AND ls_rep_hdr-%msg IS INSTANCE OF if_t100_message.
        DATA(lo_msg_hdr) = CAST if_t100_message( ls_rep_hdr-%msg ).
        IF lo_msg_hdr->t100key-msgid = 'ZFAB_MC_MINIERP' AND
           lo_msg_hdr->t100key-msgno = iv_msgno.

          lv_correct_error_found = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_correct_error_found = abap_false.
      LOOP AT lt_reported-purchaseitems INTO DATA(ls_rep_itm).
        IF ls_rep_itm-%msg IS BOUND AND ls_rep_itm-%msg IS INSTANCE OF if_t100_message.
          DATA(lo_msg_itm) = CAST if_t100_message( ls_rep_itm-%msg ).
          IF lo_msg_itm->t100key-msgid = 'ZFAB_MC_MINIERP' AND
             lo_msg_itm->t100key-msgno = iv_msgno.

            lv_correct_error_found = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    cl_abap_unit_assert=>assert_true(
      act = lv_correct_error_found
      msg = |Yaratma islemi istenilen { iv_msgno } nolu hatadan dolayi patlamadi!| ).

  ENDMETHOD.

  METHOD test_create_happy_path.

  ENDMETHOD.

  METHOD test_det_item_currency.

  ENDMETHOD.

  METHOD test_header_total_calc.

  ENDMETHOD.

  METHOD test_initial_status_open.

  ENDMETHOD.

  METHOD test_item_position_calc.

  ENDMETHOD.

  METHOD validate_active_req_item.

  ENDMETHOD.

  METHOD validate_hdr_supplier_init.

  ENDMETHOD.

  METHOD validate_hdr_waers_init.

  ENDMETHOD.

  METHOD validate_itm_material_init.

  ENDMETHOD.

  METHOD validate_itm_price_invalid.

  ENDMETHOD.

  METHOD validate_itm_qty_invalid.

  ENDMETHOD.

  METHOD validate_itm_uom_init.

  ENDMETHOD.

  METHOD validate_material_exists.

  ENDMETHOD.

  METHOD validate_supplier_exists.

  ENDMETHOD.

  METHOD validate_supplier_role.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_po_update_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: tt_po_itm TYPE STANDARD TABLE OF zfab_t_po_itm.

    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA: ms_base_bp     TYPE zfab_t_bp,
          ms_base_mat    TYPE zfab_t_mat,
          ms_base_po_hdr TYPE zfab_t_po_hdr,
          mt_base_po_itm TYPE tt_po_itm.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_update_test IMPORTING is_po_hdr_data TYPE zfab_t_po_hdr
                                    it_po_itm_data TYPE tt_po_itm
                                    iv_msgno       TYPE symsgno,
      validate_quantity_invalid  FOR TESTING,
      validate_unitprice_invalid FOR TESTING,
      update_recalculate_total   FOR TESTING,
      validate_completed_po      FOR TESTING,
      test_update_happy_path     FOR TESTING.
ENDCLASS.

CLASS ltcl_po_update_test IMPLEMENTATION.

  METHOD class_setup.

  ENDMETHOD.

  METHOD class_teardown.

  ENDMETHOD.

  METHOD execute_update_test.

  ENDMETHOD.

  METHOD setup.

  ENDMETHOD.

  METHOD teardown.

  ENDMETHOD.

  METHOD test_update_happy_path.

  ENDMETHOD.

  METHOD update_recalculate_total.

  ENDMETHOD.

  METHOD validate_completed_po.

  ENDMETHOD.

  METHOD validate_quantity_invalid.

  ENDMETHOD.

  METHOD validate_unitprice_invalid.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_po_delete_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: tt_po_itm TYPE STANDARD TABLE OF zfab_t_po_itm.

    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA: ms_base_bp     TYPE zfab_t_bp,
          ms_base_mat    TYPE zfab_t_mat,
          ms_base_po_hdr TYPE zfab_t_po_hdr,
          mt_base_po_itm TYPE tt_po_itm.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      validate_delete_complete   FOR TESTING,
      test_recalculate_total     FOR TESTING,
      test_delete_happy_path     FOR TESTING.

ENDCLASS.

CLASS ltcl_po_delete_test IMPLEMENTATION.

  METHOD class_setup.

  ENDMETHOD.

  METHOD class_teardown.

  ENDMETHOD.

  METHOD setup.

  ENDMETHOD.

  METHOD teardown.

  ENDMETHOD.

  METHOD test_delete_happy_path.

  ENDMETHOD.

  METHOD test_recalculate_total.

  ENDMETHOD.

  METHOD validate_delete_complete.

  ENDMETHOD.

ENDCLASS.
