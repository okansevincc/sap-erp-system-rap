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
    %cid        = 'HEADER_ID'
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

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_PO_HDR
    ENTITY Purchase CREATE FIELDS ( VendorUuid  Waers )
    WITH VALUE #( (
    %cid = 'POHDR'
    VendorUuid = ms_base_bp-bp_uuid
    Waers = ms_base_po_hdr-waers
    ) )
    CREATE BY \_PurchaseItems FIELDS ( MatUuid Quantity UnitUom UnitPrice Waers )
    WITH VALUE #( (
    %cid_ref = 'POHDR'
    %target = VALUE #( FOR ls_po_itm IN mt_base_po_itm (
    %cid      = |ITEM_{ ls_po_itm-item_pos }|
    MatUuid = ls_po_itm-mat_uuid
    Quantity = ls_po_itm-quantity
    UnitPrice = ls_po_itm-unit_price
    UnitUom = ls_po_itm-unit_uom
    Waers = ls_po_itm-waers
    ) )
     ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Create İşlemi Yapılması Gerekiyordu Ama Hata Verdi!' ).

  ENDMETHOD.

  METHOD test_det_item_currency.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_mapped TYPE RESPONSE FOR MAPPED zfab_r_po_hdr.

    DATA(lt_po_itm) = mt_base_po_itm.

    LOOP AT lt_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).
      CLEAR <ls_po_itm>-waers.
    ENDLOOP.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase CREATE FIELDS ( VendorUuid Waers )
      WITH VALUE #( (
        %cid       = 'POHDR'
        VendorUuid = ms_base_po_hdr-vendor_uuid
        Waers      = ms_base_po_hdr-waers
      ) )
      CREATE BY \_PurchaseItems FIELDS ( MatUuid Quantity UnitUom UnitPrice )
      WITH VALUE #( (
        %cid_ref = 'POHDR'
        %target  = VALUE #( FOR ls_po_itm_data IN lt_po_itm (
          %cid      = |ITEM_{ ls_po_itm_data-item_pos }|
          MatUuid   = ls_po_itm_data-mat_uuid
          Quantity  = ls_po_itm_data-quantity
          UnitUom   = ls_po_itm_data-unit_uom
          UnitPrice = ls_po_itm_data-unit_price
        ) )
      ) )
      FAILED lt_failed
      MAPPED lt_mapped.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Create Etmeliydi Fakat Hata Verdi!' ).

    READ ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase FIELDS ( waers )
      WITH VALUE #( ( %key-PoUuid = lt_mapped-purchase[ 1 ]-PoUuid ) )
      RESULT DATA(lt_po_hdr).

    READ ENTITIES OF zfab_r_po_hdr
      ENTITY PurchaseItems FIELDS ( Waers )
      WITH VALUE #( FOR ls_item_po IN lt_mapped-purchaseitems ( %key-PoItmUuid = ls_item_po-PoItmUuid ) )
      RESULT DATA(lt_result_po_itm).

    LOOP AT lt_result_po_itm ASSIGNING FIELD-SYMBOL(<ls_result_itm>).
      cl_abap_unit_assert=>assert_equals(
        act = <ls_result_itm>-Waers
        exp = lt_po_hdr[ 1 ]-Waers
        msg = 'Para Birimi Header İle Eşleşmedi!' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD test_header_total_calc.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_mapped TYPE RESPONSE FOR MAPPED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
    ENTITY Purchase
    CREATE FIELDS ( VendorUuid Waers )
    WITH VALUE #( (
    %cid        = 'HEADER_ID'
    VendorUuid = ms_base_po_hdr-vendor_uuid
    Waers = ms_base_po_hdr-waers
     ) )
    CREATE BY \_PurchaseItems
    FIELDS ( MatUuid Quantity UnitPrice UnitUom Waers )
    WITH VALUE #( (
    %cid_ref = 'HEADER_ID'
    %target = VALUE #( FOR ls_po_itm IN mt_base_po_itm (
    %cid      = |ITEM_{ ls_po_itm-item_pos }|
    MatUuid = ls_po_itm-mat_uuid
    Quantity = ls_po_itm-quantity
    UnitUom = ls_po_itm-unit_uom
    UnitPrice = ls_po_itm-unit_price
    Waers = ls_po_itm-waers
     ) )
      ) ) FAILED lt_failed
          MAPPED lt_mapped.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Başarı İle Create Edilmesi Gerekiyordu Fakat Hata Verdi!' ).

    DATA(lv_po_hdr_uuid) = lt_mapped-purchase[ 1 ]-PoUuid.

    READ ENTITIES OF zfab_r_po_hdr ENTITY Purchase FIELDS ( TotalAmount ) WITH VALUE #( ( %key-PoUuid = lv_po_hdr_uuid ) ) RESULT DATA(lt_po_hdr)
    ENTITY PurchaseItems FIELDS ( TotalPrice ) WITH VALUE #( FOR ls_po_itm_result IN lt_mapped-PurchaseItems ( %key-PoItmUuid = ls_po_itm_result-PoItmUuid ) ) RESULT DATA(lt_po_itm).

    cl_abap_unit_assert=>assert_not_initial( act = lt_po_hdr msg = 'Yeni yaratılan kayıt okunamadı!' ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_po_itm msg = 'Yeni yaratılan kayıt okunamadı!' ).

    SORT lt_po_itm BY PoItmUuid ASCENDING.

    cl_abap_unit_assert=>assert_equals( act = lt_po_hdr[ 1 ]-TotalAmount exp = '83500.00' msg = 'Toplam Fiyat Olması Gereken Fiyatla Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_po_itm[ 1 ]-TotalPrice exp = '15000.00' msg = '1. İtemin Toplam Fiyatı Olması Gereken Fiyatla Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_po_itm[ 2 ]-TotalPrice exp = '42750.00' msg = '2. İtemin Toplam Fiyatı Olması Gereken Fiyatla Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_po_itm[ 3 ]-TotalPrice exp = '25750.00' msg = '3. İtemin Toplam Fiyatı Olması Gereken Fiyatla Eşleşmedi!' ).

  ENDMETHOD.

  METHOD test_initial_status_open.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_mapped TYPE RESPONSE FOR MAPPED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
    ENTITY Purchase
    CREATE FIELDS ( VendorUuid TotalAmount Waers )
    WITH VALUE #( (
    %cid        = 'HEADER_ID'
    VendorUuid = ms_base_po_hdr-vendor_uuid
    TotalAmount = ms_base_po_hdr-total_amount
    Waers = ms_base_po_hdr-waers
     ) )
    CREATE BY \_PurchaseItems
    FIELDS ( MatUuid Quantity UnitPrice UnitUom Waers )
    WITH VALUE #( (
    %cid_ref = 'HEADER_ID'
    %target = VALUE #( FOR ls_po_itm IN mt_base_po_itm (
    %cid      = |ITEM_{ ls_po_itm-item_pos }|
    MatUuid = ls_po_itm-mat_uuid
    Quantity = ls_po_itm-quantity
    UnitUom = ls_po_itm-unit_uom
    UnitPrice = ls_po_itm-unit_price
    Waers = ls_po_itm-waers
     ) )
      ) ) FAILED lt_failed
          MAPPED lt_mapped.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Başarı İle Create Edilmesi Gerekiyordu Fakat Hata Verdi!' ).

    DATA(lv_new_po_uuid) = lt_mapped-purchase[ 1 ]-PoUuid.

    READ ENTITIES OF zfab_r_po_hdr ENTITY Purchase FIELDS ( Status ) WITH VALUE #( ( %key-PoUuid = lv_new_po_uuid ) ) RESULT DATA(lt_po_hdr).

    cl_abap_unit_assert=>assert_not_initial( act = lt_po_hdr msg = 'Yeni yaratılan kayıt okunamadı!' ).

    cl_abap_unit_assert=>assert_equals( act = lt_po_hdr[ 1 ]-Status exp = 'O' msg = 'Create İşlemi Yapıldığında Otomatik Statüyü Open ( O ) Yapmalıydı Fakat Yapmadı!' ).

  ENDMETHOD.

  METHOD test_item_position_calc.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_mapped TYPE RESPONSE FOR MAPPED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
    ENTITY Purchase CREATE FIELDS ( Waers VendorUuid )
    WITH VALUE #( (
    %cid = 'PO_HDR'
    Waers = ms_base_po_hdr-waers
    VendorUuid = ms_base_po_hdr-vendor_uuid
    ) )
    CREATE BY \_PurchaseItems
    FIELDS ( MatUuid Quantity UnitPrice UnitUom Waers )
    WITH VALUE #( (
    %cid_ref = 'PO_HDR'
    %target = VALUE #( FOR ls_itm IN mt_base_po_itm INDEX INTO lv_index (
    %cid      = |ITEM_{ lv_index }|
    MatUuid = ls_itm-mat_uuid
    Quantity = ls_itm-quantity
    UnitPrice = ls_itm-unit_price
    UnitUom = ls_itm-unit_uom
    Waers = ls_itm-waers
     ) )
     ) ) FAILED lt_failed
         MAPPED lt_mapped.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Kayıt Yapılmalıydı Fakat Hata Verdi!' ).

    DATA(lt_result_po_itm) = lt_mapped-purchaseitems.

    READ ENTITIES OF zfab_r_po_hdr ENTITY PurchaseItems FIELDS ( ItemPos ) WITH VALUE #( FOR ls_item IN lt_result_po_itm ( %key-PoItmUuid = ls_item-PoItmUuid ) ) RESULT DATA(lt_result_pos).

    SORT lt_result_pos BY ItemPos ASCENDING.

    cl_abap_unit_assert=>assert_equals( act = lt_result_pos[ 1 ]-ItemPos exp = '00010' msg = '1. İtemin Pozisyonu 10 Olmalıydı Fakat Olmadı!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result_pos[ 2 ]-ItemPos exp = '00020' msg = '2. İtemin Pozisyonu 10 Olmalıydı Fakat Olmadı!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result_pos[ 3 ]-ItemPos exp = '00030' msg = '3. İtemin Pozisyonu 10 Olmalıydı Fakat Olmadı!' ).

  ENDMETHOD.

  METHOD validate_active_req_item.

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = VALUE #(  ) iv_msgno = '407' ).

  ENDMETHOD.

  METHOD validate_hdr_supplier_init.

    DATA(ls_po_hdr) = ms_base_po_hdr.
    CLEAR ls_po_hdr-vendor_uuid.

    execute_create_test( is_po_hdr_data = ls_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '401' ).

  ENDMETHOD.

  METHOD validate_hdr_waers_init.

    DATA(ls_po_hdr) = ms_base_po_hdr.
    CLEAR ls_po_hdr-waers.

    execute_create_test( is_po_hdr_data = ls_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '402' ).

  ENDMETHOD.

  METHOD validate_itm_material_init.

    LOOP AT mt_base_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).

      CLEAR <ls_po_itm>-mat_uuid.

    ENDLOOP.

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '403' ).

  ENDMETHOD.

  METHOD validate_itm_price_invalid.

    LOOP AT mt_base_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).

      <ls_po_itm>-unit_price = -100.

    ENDLOOP.

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '403' ).

  ENDMETHOD.

  METHOD validate_itm_qty_invalid.

    LOOP AT mt_base_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).

      <ls_po_itm>-quantity = -100.

    ENDLOOP.

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '403' ).

  ENDMETHOD.

  METHOD validate_itm_uom_init.

    LOOP AT mt_base_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).

      CLEAR <ls_po_itm>-unit_uom.

    ENDLOOP.

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '404' ).

  ENDMETHOD.

  METHOD validate_material_exists.

    LOOP AT mt_base_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).

      TRY.
          <ls_po_itm>-mat_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error.
          cl_abap_unit_assert=>fail( 'Mock verisi icin Material UUID uretilemedi!' ).
      ENDTRY.

    ENDLOOP.

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '405' ).

  ENDMETHOD.

  METHOD validate_supplier_exists.

    DATA(ls_po_hdr) = ms_base_po_hdr.

    TRY.
        ls_po_hdr-vendor_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi icin Supplier UUID uretilemedi!' ).
    ENDTRY.

    execute_create_test( is_po_hdr_data = ls_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '406' ).

  ENDMETHOD.

  METHOD validate_supplier_role.

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    UPDATE FIELDS ( BpRole )
    WITH VALUE #( ( %key-BpUuid = ms_base_bp-bp_uuid
    BpRole = 'C'
    ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-_businesspartner msg = 'Supplier Rolü Değiştirilirken Hata Meydana Geldi!' ).

    execute_create_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = mt_base_po_itm iv_msgno = '406' ).

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

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_MAT' )
                                                                                                      ( i_for_entity = 'ZFAB_R_BP' )
                                                                                                      ( i_for_entity = 'ZFAB_R_PO_ITM' )
                                                                                                      ( i_for_entity = 'ZFAB_R_PO_HDR' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD teardown.

    CLEAR: ms_base_bp,
           mt_base_po_itm,
           ms_base_mat,
           ms_base_po_hdr.
    go_mock_environment->clear_doubles(  ).

  ENDMETHOD.

  METHOD setup.

    go_mock_environment->clear_doubles(  ).

    DATA: lt_base_bp     TYPE STANDARD TABLE OF zfab_t_bp,
          lt_base_mat    TYPE STANDARD TABLE OF zfab_t_mat,
          lt_base_po_hdr TYPE STANDARD TABLE OF zfab_t_po_hdr.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'S' ).
    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).
    ms_base_po_hdr = zcl_fab_mock_factory=>get_valid_po_header( iv_vendor_uuid = ms_base_bp-bp_uuid ).
    mt_base_po_itm = zcl_fab_mock_factory=>get_valid_po_items( po_header_uuid = ms_base_po_hdr-po_uuid iv_mat_uuid = ms_base_mat-mat_uuid ).

    APPEND ms_base_bp TO lt_base_bp.
    APPEND ms_base_mat TO lt_base_mat.
    APPEND ms_base_po_hdr TO lt_base_po_hdr.

    go_mock_environment->insert_test_data( i_data = lt_base_bp ).
    go_mock_environment->insert_test_data( i_data = lt_base_mat ).
    go_mock_environment->insert_test_data( i_data = lt_base_po_hdr ).
    go_mock_environment->insert_test_data( i_data = mt_base_po_itm ).


  ENDMETHOD.

  METHOD execute_update_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
    ENTITY Purchase UPDATE FIELDS ( Waers VendorUuid )
    WITH VALUE #( (
    %key-PoUuid = is_po_hdr_data-po_uuid
    Waers = is_po_hdr_data-waers
    VendorUuid = is_po_hdr_data-vendor_uuid
     ) )
    ENTITY PurchaseItems UPDATE FIELDS ( Quantity UnitPrice )
    WITH VALUE #( FOR ls_item IN it_po_itm_data (
    %key-PoItmUuid = ls_item-po_itm_uuid
    Quantity = ls_item-quantity
    UnitPrice = ls_item-unit_price
     ) ) FAILED lt_failed
         REPORTED lt_reported.

    cl_abap_unit_assert=>assert_true(
        act = xsdbool( lt_failed-purchase IS NOT INITIAL OR lt_failed-purchaseitems IS NOT INITIAL )
        msg = 'Update islemi engellenmeliydi ama basari ile Update edildi!' ).

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
      msg = |Update islemi istenilen { iv_msgno } nolu hatadan dolayi patlamadi!| ).

  ENDMETHOD.

METHOD test_update_happy_path.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr.

    DATA(ls_po_hdr) = ms_base_po_hdr.
    DATA(lt_po_itm) = mt_base_po_itm.

    ls_po_hdr-waers = 'USD'.

    LOOP AT lt_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).
      <ls_po_itm>-quantity   = 250.
      <ls_po_itm>-unit_price = '35.00'.
    ENDLOOP.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase UPDATE FIELDS ( Waers )
      WITH VALUE #( (
        %key-PoUuid = ls_po_hdr-po_uuid
        Waers       = ls_po_hdr-waers
      ) )
      ENTITY PurchaseItems UPDATE FIELDS ( Quantity UnitPrice )
      WITH VALUE #( FOR ls_item IN lt_po_itm (
        %key-PoItmUuid = ls_item-po_itm_uuid
        Quantity       = ls_item-quantity
        UnitPrice      = ls_item-unit_price
      ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Test Başarı İle Geçmeliydi Fakat Hata Verdi!' ).

    READ ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase FIELDS ( Waers )
      WITH VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) ) RESULT DATA(lt_read_hdr)
      ENTITY PurchaseItems FIELDS ( Quantity UnitPrice )
      WITH VALUE #( FOR ls_item IN lt_po_itm ( %key-PoItmUuid = ls_item-po_itm_uuid ) ) RESULT DATA(lt_read_itm).

    cl_abap_unit_assert=>assert_equals( act = lt_read_hdr[ 1 ]-Waers exp = 'USD' msg = 'Para birimi güncellenemedi!' ).

    LOOP AT lt_read_itm INTO DATA(ls_read_itm).
      cl_abap_unit_assert=>assert_equals( act = ls_read_itm-Quantity  exp = 250       msg = 'Miktar güncellenemedi!' ).
      cl_abap_unit_assert=>assert_equals( act = ls_read_itm-UnitPrice exp = '35.00'   msg = 'Fiyat güncellenemedi!' ).
    ENDLOOP.

  ENDMETHOD.

METHOD update_recalculate_total.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr.
    DATA(lt_po_itm) = mt_base_po_itm.
    DATA(ls_po_hdr) = ms_base_po_hdr.


    lt_po_itm[ 1 ]-quantity   = 10.
    lt_po_itm[ 1 ]-unit_price = '150.00'.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY PurchaseItems UPDATE FIELDS ( Quantity UnitPrice )
      WITH VALUE #( (
        %key-PoItmUuid = lt_po_itm[ 1 ]-po_itm_uuid
        Quantity       = lt_po_itm[ 1 ]-quantity
        UnitPrice      = lt_po_itm[ 1 ]-unit_price
      ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Update islemi hata verdi!' ).

    READ ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase FIELDS ( TotalAmount )
      WITH VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) ) RESULT DATA(lt_read_hdr)
      ENTITY Purchase BY \_PurchaseItems FIELDS ( TotalPrice )
      WITH VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) ) RESULT DATA(lt_read_itm).

    DATA: lv_expected_total TYPE p DECIMALS 2 VALUE 0.
    LOOP AT lt_read_itm INTO DATA(ls_itm).
      lv_expected_total = lv_expected_total + ls_itm-TotalPrice.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lt_read_hdr[ 1 ]-TotalAmount
      exp = lv_expected_total
      msg = 'Header TotalAmount kalemlerin toplami ile eslesmiyor!' ).

  ENDMETHOD.

METHOD validate_completed_po.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase UPDATE FIELDS ( Status )
      WITH VALUE #( ( %key-PoUuid = ms_base_po_hdr-po_uuid Status = 'C' ) )
      FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Statü COMPLETED yapılamadı!' ).

    DATA(lt_po_itm) = mt_base_po_itm.
    lt_po_itm[ 1 ]-quantity = 500.

    execute_update_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = lt_po_itm iv_msgno       = '407' ).

  ENDMETHOD.

METHOD validate_quantity_invalid.

    DATA(lt_po_itm) = mt_base_po_itm.

    LOOP AT lt_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).
      <ls_po_itm>-quantity = -5.
    ENDLOOP.

    execute_update_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = lt_po_itm iv_msgno       = '403' ).

  ENDMETHOD.


  METHOD validate_unitprice_invalid.

    DATA(lt_po_itm) = mt_base_po_itm.

    LOOP AT lt_po_itm ASSIGNING FIELD-SYMBOL(<ls_po_itm>).
      <ls_po_itm>-unit_price = -100.
    ENDLOOP.

    execute_update_test( is_po_hdr_data = ms_base_po_hdr it_po_itm_data = lt_po_itm iv_msgno       = '403' ).

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

go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_MAT' )
                                                                                                      ( i_for_entity = 'ZFAB_R_BP' )
                                                                                                      ( i_for_entity = 'ZFAB_R_PO_ITM' )
                                                                                                      ( i_for_entity = 'ZFAB_R_PO_HDR' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    go_mock_environment->clear_doubles(  ).

    DATA: lt_base_bp     TYPE STANDARD TABLE OF zfab_t_bp,
          lt_base_mat    TYPE STANDARD TABLE OF zfab_t_mat,
          lt_base_po_hdr TYPE STANDARD TABLE OF zfab_t_po_hdr.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'S' ).
    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).
    ms_base_po_hdr = zcl_fab_mock_factory=>get_valid_po_header( iv_vendor_uuid = ms_base_bp-bp_uuid ).
    mt_base_po_itm = zcl_fab_mock_factory=>get_valid_po_items( po_header_uuid = ms_base_po_hdr-po_uuid iv_mat_uuid = ms_base_mat-mat_uuid ).

    APPEND ms_base_bp TO lt_base_bp.
    APPEND ms_base_mat TO lt_base_mat.
    APPEND ms_base_po_hdr TO lt_base_po_hdr.

    go_mock_environment->insert_test_data( i_data = lt_base_bp ).
    go_mock_environment->insert_test_data( i_data = lt_base_mat ).
    go_mock_environment->insert_test_data( i_data = lt_base_po_hdr ).
    go_mock_environment->insert_test_data( i_data = mt_base_po_itm ).

  ENDMETHOD.

  METHOD teardown.

    clear: ms_base_bp,
           ms_base_mat,
           ms_base_po_hdr,
           mt_base_po_itm.

    go_mock_environment->clear_doubles(  ).

  ENDMETHOD.

METHOD test_delete_happy_path.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr.

    DATA(ls_po_hdr) = ms_base_po_hdr.
    DATA(lt_po_itm) = mt_base_po_itm.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase DELETE FROM VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) )
      FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-purchase msg = 'Silme İşlemi Hata Vermemeliydi Fakat Verdi!' ).

    READ ENTITIES OF zfab_r_po_hdr
      ENTITY PurchaseItems ALL FIELDS
      WITH VALUE #( FOR ls_item IN lt_po_itm ( %key-PoItmUuid = ls_item-po_itm_uuid ) )
      RESULT DATA(lt_item_result).

    cl_abap_unit_assert=>assert_initial(
      act = lt_item_result
      msg = 'Başlık (Header) silindi ama ona bağlı kalemler (Items) arka planda silinmemiş!' ).

  ENDMETHOD.


  METHOD test_recalculate_total.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_po_hdr.

    DATA(ls_po_hdr) = ms_base_po_hdr.
    DATA(lt_po_itm) = mt_base_po_itm.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY PurchaseItems DELETE FROM VALUE #( ( %key-PoItmUuid = lt_po_itm[ 1 ]-po_itm_uuid ) )
      FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-purchaseitems msg = 'Kalem Silme İşlemi Hata Vermemeliydi!' ).

    READ ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase FIELDS ( TotalAmount )
      WITH VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) ) RESULT DATA(lt_read_hdr)
      ENTITY Purchase BY \_PurchaseItems FIELDS ( TotalPrice )
      WITH VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) ) RESULT DATA(lt_read_itm).

    DATA: lv_expected_total TYPE p DECIMALS 2 VALUE 0.
    LOOP AT lt_read_itm INTO DATA(ls_itm).
      lv_expected_total = lv_expected_total + ls_itm-TotalPrice.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lt_read_hdr[ 1 ]-TotalAmount
      exp = lv_expected_total
      msg = 'Bir kalem silindiğinde Başlık (Header) Tablosunun Total Amountu doğru hesaplanmadı!' ).

  ENDMETHOD.


  METHOD validate_delete_complete.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_po_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_po_hdr.

    DATA(ls_po_hdr) = ms_base_po_hdr.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase UPDATE FIELDS ( Status )
      WITH VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid Status = 'C' ) )
      FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-purchase msg = 'Statü C (Completed) yapılırken hata alındı, sahne hazırlanamadı!' ).

    CLEAR lt_failed.

    MODIFY ENTITIES OF zfab_r_po_hdr
      ENTITY Purchase DELETE FROM VALUE #( ( %key-PoUuid = ls_po_hdr-po_uuid ) )
      FAILED lt_failed
      REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial( act = lt_failed-purchase msg = 'Statüsü Tamamlandı (C) olan sipariş silinmemeliydi ama sistem silmeye izin verdi!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-purchase INTO DATA(ls_reported).
      IF ls_reported-%msg IS BOUND AND ls_reported-%msg IS INSTANCE OF if_t100_message.
        DATA(lo_msg) = CAST if_t100_message( ls_reported-%msg ).

        IF lo_msg->t100key-msgid = 'ZFAB_MC_MINIERP' AND
           lo_msg->t100key-msgno = '417'.

          lv_correct_error_found = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_correct_error_found
      msg = 'Silme işlemi engellendi ancak beklenen hata mesajı fırlatılmadı!' ).

  ENDMETHOD.

ENDCLASS.
