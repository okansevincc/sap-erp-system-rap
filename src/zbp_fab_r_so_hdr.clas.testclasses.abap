CLASS ltcl_so_create_test DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    TYPES: tt_so_itm TYPE STANDARD TABLE OF zfab_t_so_itm WITH DEFAULT KEY.

    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA: ms_base_so_hdr TYPE zfab_t_so_hdr,
          mt_base_so_itm TYPE tt_so_itm,
          ms_base_bp     TYPE zfab_t_bp,
          ms_base_mat    TYPE zfab_t_mat.



    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS: setup,
      teardown,
      execute_create_test IMPORTING is_so_hdr_data TYPE zfab_t_so_hdr
                                    it_so_itm_data TYPE tt_so_itm
                                    iv_msgno       TYPE symsgno,
      validate_hdr_customer_init FOR TESTING,
      validate_hdr_waers_init    FOR TESTING,
      validate_itm_material_init FOR TESTING,
      validate_itm_qty_invalid   FOR TESTING,
      validate_itm_price_invalid FOR TESTING,
      validate_itm_uom_init      FOR TESTING,
      validate_customer_exists   FOR TESTING,
      validate_customer_role     FOR TESTING,
      validate_material_exists   FOR TESTING,
      test_initial_status_open   FOR TESTING,
      test_item_position_calc    FOR TESTING,
      test_header_total_calc     FOR TESTING,
      succesful_test             FOR TESTING,
      test_det_item_currency     FOR TESTING,
      validate_active_req_item   FOR TESTING.

ENDCLASS.

CLASS ltcl_so_create_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_BP' )
                                                                                                    ( i_for_entity = 'ZFAB_R_MAT' )
                                                                                                    ( i_for_entity = 'ZFAB_R_SO_HDR' )
                                                                                                    ( i_for_entity = 'ZFAB_R_SO_ITM' ) ) ).


  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).
    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner(  ).

    ms_base_so_hdr = zcl_fab_mock_factory=>get_valid_so_header( iv_customer_uuid = ms_base_bp-bp_uuid ).

    DATA(ls_bp_data) = ms_base_bp.
    DATA lt_lock_db_bp TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ls_bp_data TO lt_lock_db_bp.
    go_mock_environment->insert_test_data( i_data = lt_lock_db_bp ).

    DATA(ls_mat_data) = ms_base_mat.
    DATA lt_lock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.
    APPEND ls_mat_data TO lt_lock_db_mat.
    go_mock_environment->insert_test_data( i_data = lt_lock_db_mat ).

  ENDMETHOD.

  METHOD teardown.

    CLEAR: ms_base_so_hdr,
           mt_base_so_itm,
           ms_base_bp,
           ms_base_mat.

    go_mock_environment->clear_doubles(  ).

  ENDMETHOD.

  METHOD execute_create_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_so_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
        CREATE FIELDS ( SoId CustomerUuid Status TotalAmount Waers )
        WITH VALUE #( (
          %cid         = 'Header_ID'
          SoId         = is_so_hdr_data-so_id
          CustomerUuid = is_so_hdr_data-customer_uuid
          Status       = is_so_hdr_data-status
          TotalAmount  = is_so_hdr_data-total_amount
          Waers        = is_so_hdr_data-waers
        ) )
      CREATE BY \_SalesItems FIELDS ( ItemPos MatUuid Quantity UnitUom UnitPrice Waers )
        WITH VALUE #( (
          %cid_ref = 'Header_ID'
          %target  = VALUE #( FOR ls_itm IN it_so_itm_data (
                        %cid      = |ITEM_{ ls_itm-item_pos }|
                        ItemPos   = ls_itm-item_pos
                        MatUuid   = ls_itm-mat_uuid
                        Quantity  = ls_itm-quantity
                        UnitUom   = ls_itm-unit_uom
                        UnitPrice = ls_itm-unit_price
                        Waers     = ls_itm-waers
                     ) )
        ) )
      FAILED lt_failed
      REPORTED lt_reported.

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lt_failed-sales IS NOT INITIAL OR lt_failed-salesitems IS NOT INITIAL )
      msg = 'Create islemi engellenmeliydi ama basari ile create edildi!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-sales INTO DATA(ls_rep_hdr).
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
      LOOP AT lt_reported-salesitems INTO DATA(ls_rep_itm).
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

  METHOD test_header_total_calc.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                     iv_mat_uuid    = ms_base_mat-mat_uuid
                     so_header_uuid = ms_base_so_hdr-so_uuid ).

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
        CREATE FIELDS ( SoId CustomerUuid Waers Status )
        WITH VALUE #( (
          %cid          = 'HEADER_CID'
          SoId          = ms_base_so_hdr-so_id
          CustomerUuid  = ms_base_so_hdr-customer_uuid
          Waers         = ms_base_so_hdr-waers
          Status        = ms_base_so_hdr-status
        ) )

      CREATE BY \_SalesItems FIELDS ( ItemPos MatUuid Quantity UnitUom UnitPrice Waers )
        WITH VALUE #( (
          %cid_ref = 'HEADER_CID'
          %target  = VALUE #( FOR ls_itm IN mt_base_so_itm (
                        %cid        = |ITEM_{ ls_itm-item_pos }|
                        ItemPos     = ls_itm-item_pos
                        MatUuid     = ls_itm-mat_uuid
                        Quantity    = ls_itm-quantity
                        UnitUom     = ls_itm-unit_uom
                        UnitPrice   = ls_itm-unit_price
                        Waers       = ls_itm-waers
                     ) )
        ) ) MAPPED DATA(lt_mapped)
            FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial(
    act = lt_failed
    msg = 'Sipariş yaratılamadı!' ).

    READ ENTITIES OF zfab_r_so_hdr ENTITY Sales ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) )
    RESULT DATA(lt_hdr_result)
    BY \_SalesItems
    ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) ) RESULT DATA(lt_itm_result).

    cl_abap_unit_assert=>assert_equals( act = lt_hdr_result[ 1 ]-TotalAmount exp = '15350.00' msg = 'Toplam Header Fiyatı Olması Gereken Değer İle Eşleşmedi!' ).

    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 1 ]-TotalPrice exp = '4500.00' msg = 'Toplam İtem Fiyatı Olması Gereken Değer İle Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 2 ]-TotalPrice exp = '6275.00' msg = 'Toplam İtem Fiyatı Olması Gereken Değer İle Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 3 ]-TotalPrice exp = '4575.00' msg = 'Toplam İtem Fiyatı Olması Gereken Değer İle Eşleşmedi!' ).

  ENDMETHOD.

  METHOD test_initial_status_open.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                     iv_mat_uuid    = ms_base_mat-mat_uuid
                     so_header_uuid = ms_base_so_hdr-so_uuid ).

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
        CREATE FIELDS ( SoId CustomerUuid Waers )
        WITH VALUE #( (
          %cid          = 'HEADER_CID'
          SoId          = ms_base_so_hdr-so_id
          CustomerUuid  = ms_base_so_hdr-customer_uuid
          Waers         = ms_base_so_hdr-waers
        ) )

      CREATE BY \_SalesItems FIELDS ( ItemPos MatUuid Quantity UnitUom UnitPrice Waers )
        WITH VALUE #( (
          %cid_ref = 'HEADER_CID'
          %target  = VALUE #( FOR ls_itm IN mt_base_so_itm (
                        %cid        = |ITEM_{ ls_itm-item_pos }|
                        ItemPos     = ls_itm-item_pos
                        MatUuid     = ls_itm-mat_uuid
                        Quantity    = ls_itm-quantity
                        UnitUom     = ls_itm-unit_uom
                        UnitPrice   = ls_itm-unit_price
                        Waers       = ls_itm-waers
                     ) )
        ) ) MAPPED DATA(lt_mapped)
            FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial(
    act = lt_failed
    msg = 'Sipariş yaratılamadı!' ).

    READ ENTITIES OF zfab_r_so_hdr ENTITY Sales ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) )
    RESULT DATA(lt_hdr_result).

    cl_abap_unit_assert=>assert_equals( act = lt_hdr_result[ 1 ]-Status exp = 'O' msg = 'Sipariş Statüsü Create Edildiğinde Statüsü Open yani O Olmadı!' ).

  ENDMETHOD.

  METHOD test_item_position_calc.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                     iv_mat_uuid    = ms_base_mat-mat_uuid
                     so_header_uuid = ms_base_so_hdr-so_uuid ).

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
        CREATE FIELDS ( SoId CustomerUuid Waers Status )
        WITH VALUE #( (
          %cid          = 'HEADER_CID'
          SoId          = ms_base_so_hdr-so_id
          CustomerUuid  = ms_base_so_hdr-customer_uuid
          Waers         = ms_base_so_hdr-waers
          Status        = ms_base_so_hdr-status
        ) )

      CREATE BY \_SalesItems FIELDS ( MatUuid Quantity UnitUom UnitPrice Waers )
        WITH VALUE #( (
          %cid_ref = 'HEADER_CID'
          %target  = VALUE #( FOR ls_itm IN mt_base_so_itm (
                        %cid        = |ITEM_{ ls_itm-item_pos }|
                        MatUuid     = ls_itm-mat_uuid
                        Quantity    = ls_itm-quantity
                        UnitUom     = ls_itm-unit_uom
                        UnitPrice   = ls_itm-unit_price
                        Waers       = ls_itm-waers
                     ) )
        ) ) MAPPED DATA(lt_mapped)
            FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial(
    act = lt_failed
    msg = 'Sipariş yaratılamadı!' ).

    READ ENTITIES OF zfab_r_so_hdr ENTITY Sales ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) )
    RESULT DATA(lt_hdr_result)
    BY \_SalesItems
    ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) ) RESULT DATA(lt_itm_result).

    SORT lt_itm_result BY ItemPos ASCENDING.

    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 1 ]-ItemPos exp = '00010' msg = 'İtem Pozisyonu Olması Gereken Değer İle Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 2 ]-ItemPos exp = '00020' msg = 'İtem Pozisyonu Olması Gereken Değer İle Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 3 ]-ItemPos exp = '00030' msg = 'İtem Pozisyonu Olması Gereken Değer İle Eşleşmedi!' ).

  ENDMETHOD.

  METHOD validate_customer_exists.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.

    TRY.
        ls_so_hdr_data-customer_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Rastgele Customer Uuid Üretilemedi!' ).
    ENDTRY.
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                   iv_mat_uuid    = ms_base_mat-mat_uuid
                   so_header_uuid = ls_so_hdr_data-so_uuid ).

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '306' ).

  ENDMETHOD.

  METHOD validate_customer_role.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-bp_role = 'S'.
    ls_bp_data-bp_id = 'SUPP_999'.

    TRY.
        ls_bp_data-bp_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için yeni uuid üretilemedi!' ).
    ENDTRY.

    DATA lt_lock_db_bp TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ls_bp_data TO lt_lock_db_bp.
    go_mock_environment->insert_test_data( i_data = lt_lock_db_bp ).

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    ls_so_hdr_data-customer_uuid = ls_bp_data-bp_uuid.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
               iv_mat_uuid    = ms_base_mat-mat_uuid
               so_header_uuid = ls_so_hdr_data-so_uuid ).

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '301' ).

  ENDMETHOD.

  METHOD validate_hdr_customer_init.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    CLEAR ls_so_hdr_data-customer_uuid.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                   iv_mat_uuid    = ms_base_mat-mat_uuid
                   so_header_uuid = ls_so_hdr_data-so_uuid ).

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '302' ).

  ENDMETHOD.

  METHOD validate_hdr_waers_init.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    CLEAR ls_so_hdr_data-waers.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                   iv_mat_uuid    = ms_base_mat-mat_uuid
                   so_header_uuid = ls_so_hdr_data-so_uuid ).

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '303' ).

  ENDMETHOD.

  METHOD validate_itm_material_init.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items( iv_mat_uuid = ms_base_mat-mat_uuid
                                                              so_header_uuid = ls_so_hdr_data-so_uuid ).
    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      CLEAR <ls_base_so_itm>-mat_uuid.

    ENDLOOP.

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '304' ).

  ENDMETHOD.

  METHOD validate_itm_price_invalid.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                           iv_mat_uuid    = ms_base_mat-mat_uuid
                           so_header_uuid = ls_so_hdr_data-so_uuid ).

    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_itm_negative>).
      <ls_itm_negative>-unit_price = -5.
    ENDLOOP.


    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '305' ).

  ENDMETHOD.

  METHOD validate_itm_qty_invalid.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                       iv_mat_uuid    = ms_base_mat-mat_uuid
                       so_header_uuid = ls_so_hdr_data-so_uuid ).

    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_itm_initial>).
      CLEAR <ls_itm_initial>-quantity.
    ENDLOOP.

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '306' ).

  ENDMETHOD.

  METHOD validate_itm_uom_init.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items( iv_mat_uuid = ms_base_mat-mat_uuid
                                                              so_header_uuid = ls_so_hdr_data-so_uuid ).
    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      CLEAR <ls_base_so_itm>-unit_uom.

    ENDLOOP.

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '307' ).

  ENDMETHOD.

  METHOD validate_material_exists.

    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items( iv_mat_uuid = ms_base_mat-mat_uuid
                                                              so_header_uuid = ls_so_hdr_data-so_uuid ).
    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      TRY.
          <ls_base_so_itm>-mat_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error.
          cl_abap_unit_assert=>fail( 'Rastgele MatUuid Üretilemedi!' ).
      ENDTRY.
    ENDLOOP.

    execute_create_test( is_so_hdr_data = ls_so_hdr_data it_so_itm_data = mt_base_so_itm iv_msgno = '308' ).

  ENDMETHOD.

  METHOD succesful_test.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                       iv_mat_uuid    = ms_base_mat-mat_uuid
                       so_header_uuid = ms_base_so_hdr-so_uuid ).

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_so_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
        CREATE FIELDS ( SoId CustomerUuid Waers Status )
        WITH VALUE #( (
          %cid          = 'HEADER_CID'
          SoId          = ms_base_so_hdr-so_id
          CustomerUuid  = ms_base_so_hdr-customer_uuid
          Waers         = ms_base_so_hdr-waers
          Status        = ms_base_so_hdr-status
        ) )

      CREATE BY \_SalesItems FIELDS ( ItemPos MatUuid Quantity UnitUom UnitPrice Waers )
        WITH VALUE #( (
          %cid_ref = 'HEADER_CID'
          %target  = VALUE #( FOR ls_itm IN mt_base_so_itm (
                        %cid        = |ITEM_{ ls_itm-item_pos }|
                        ItemPos     = ls_itm-item_pos
                        MatUuid     = ls_itm-mat_uuid
                        Quantity    = ls_itm-quantity
                        UnitUom     = ls_itm-unit_uom
                        UnitPrice   = ls_itm-unit_price
                        Waers       = ls_itm-waers
                     ) )
        ) )
      FAILED lt_failed
      REPORTED lt_reported.

    cl_abap_unit_assert=>assert_initial(
      act = lt_failed-sales
      msg = 'Kusursuz Sipariş (Header) yaratılırken hata alındı!' ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_failed-salesitems
      msg = 'Kusursuz Sipariş Kalemleri (Item) yaratılırken hata alındı!' ).

  ENDMETHOD.

  METHOD test_det_item_currency.

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.
    DATA(ls_so_hdr_data) = ms_base_so_hdr.
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items( iv_mat_uuid = ms_base_mat-mat_uuid
                                                              so_header_uuid = ls_so_hdr_data-so_uuid ).
    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      CLEAR <ls_base_so_itm>-waers.

    ENDLOOP.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY Sales
    CREATE FIELDS ( SoId CustomerUuid Status Waers )
    WITH VALUE #( (
          %cid          = 'HEADER_CID'
          SoId          = ms_base_so_hdr-so_id
          CustomerUuid  = ms_base_so_hdr-customer_uuid
          Waers         = ms_base_so_hdr-waers
          Status        = ms_base_so_hdr-status
     ) )
    CREATE BY \_SalesItems
    FIELDS ( ItemPos MatUuid Quantity UnitUom UnitPrice Waers )
    WITH VALUE #( (
          %cid_ref = 'HEADER_CID'
          %target  = VALUE #( FOR ls_itm IN mt_base_so_itm (
                        %cid        = |ITEM_{ ls_itm-item_pos }|
                        ItemPos     = ls_itm-item_pos
                        MatUuid     = ls_itm-mat_uuid
                        Quantity    = ls_itm-quantity
                        UnitUom     = ls_itm-unit_uom
                        UnitPrice   = ls_itm-unit_price
                        Waers       = ls_itm-waers
    ) )
    ) ) MAPPED DATA(lt_mapped)
        FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed msg = 'Sistem kaydetmeliydi fakat hata verdi!' ).

    READ ENTITIES OF zfab_r_so_hdr ENTITY Sales ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) )
RESULT DATA(lt_hdr_result)
BY \_SalesItems
ALL FIELDS WITH VALUE #( ( %key-SoUuid = lt_mapped-sales[ 1 ]-SoUuid ) ) RESULT DATA(lt_itm_result).

    SORT lt_itm_result BY ItemPos ASCENDING.

    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 1 ]-Waers exp = lt_hdr_result[ 1 ]-Waers msg = 'İtemin Para Birimi Olması Gereken Değer İle Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 2 ]-Waers exp = lt_hdr_result[ 1 ]-Waers msg = 'İtemin Para Birimi Olması Gereken Değer İle Eşleşmedi!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_itm_result[ 3 ]-Waers exp = lt_hdr_result[ 1 ]-Waers msg = 'İtemin Para Birimi Olması Gereken Değer İle Eşleşmedi!' ).

  ENDMETHOD.

  METHOD validate_active_req_item.

    DATA(ls_so_hdr) = ms_base_so_hdr.

    CLEAR mt_base_so_itm.

    execute_create_test( is_so_hdr_data = ls_so_hdr it_so_itm_data = mt_base_so_itm iv_msgno = '309' ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_so_update_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: tt_so_itm TYPE STANDARD TABLE OF zfab_t_so_itm WITH DEFAULT KEY.

    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.

    DATA: ms_base_so_hdr TYPE zfab_t_so_hdr,
          mt_base_so_itm TYPE tt_so_itm,
          ms_base_mat    TYPE zfab_t_mat,
          ms_base_bp     TYPE zfab_t_bp.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_update_test IMPORTING is_so_hdr_data TYPE zfab_t_so_hdr
                                    it_so_itm_data TYPE tt_so_itm
                                    iv_msgno       TYPE symsgno,
      validate_quantity_invalid  FOR TESTING,
      validate_unitprice_invalid FOR TESTING,
      update_recalculate_total   FOR TESTING,
      validate_completed_so      FOR TESTING,
      succesful_test             FOR TESTING.


ENDCLASS.

CLASS ltcl_so_update_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_MAT' )
                                                                                                      ( i_for_entity = 'ZFAB_R_BP' )
                                                                                                      ( i_for_entity = 'ZFAB_R_SO_HDR' )
                                                                                                      ( i_for_entity = 'ZFAB_R_SO_ITM' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'C' ).
    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).

    DATA: lt_bp  TYPE STANDARD TABLE OF zfab_t_bp,
          lt_mat TYPE STANDARD TABLE OF zfab_t_mat.

    APPEND ms_base_mat TO lt_mat.
    APPEND ms_base_bp TO lt_bp.

    go_mock_environment->insert_test_data( i_data = lt_bp ).
    go_mock_environment->insert_test_data( i_data = lt_mat ).

    ms_base_so_hdr = zcl_fab_mock_factory=>get_valid_so_header( iv_customer_uuid = ms_base_bp-bp_uuid ).
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items( so_header_uuid = ms_base_so_hdr-so_uuid iv_mat_uuid = ms_base_mat-mat_uuid ).

    DATA: lt_so_hdr TYPE STANDARD TABLE OF zfab_t_so_hdr.

    APPEND ms_base_so_hdr TO lt_so_hdr.
    go_mock_environment->insert_test_data( i_data = lt_so_hdr ).
    go_mock_environment->insert_test_data( i_data = mt_base_so_itm ).

  ENDMETHOD.

  METHOD teardown.

    go_mock_environment->clear_doubles(  ).
    CLEAR: ms_base_so_hdr,
           ms_base_mat,
           ms_base_bp,
           mt_base_so_itm.

  ENDMETHOD.

  METHOD execute_update_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_so_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY SalesItems
    UPDATE FIELDS ( Quantity UnitPrice )
    WITH VALUE #( FOR ls_itm IN it_so_itm_data (
    %key-SoItmUuid = ls_itm-so_itm_uuid
    Quantity = ls_itm-quantity
    UnitPrice = ls_itm-unit_price
     ) )
     FAILED lt_failed
     REPORTED lt_reported.

    cl_abap_unit_assert=>assert_true(
        act = xsdbool( lt_failed-sales IS NOT INITIAL OR lt_failed-salesitems IS NOT INITIAL )
        msg = 'Update islemi engellenmeliydi ama basari ile Update edildi!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-sales INTO DATA(ls_rep_hdr).
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
      LOOP AT lt_reported-salesitems INTO DATA(ls_rep_itm).
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

  METHOD succesful_test.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      <ls_base_so_itm>-quantity = '150.00'.
      <ls_base_so_itm>-unit_price = '50.00'.

    ENDLOOP.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY SalesItems
    UPDATE FIELDS ( Quantity UnitPrice )
    WITH VALUE #( FOR ls_item IN mt_base_so_itm (
    %key-SoItmUuid = ls_item-so_itm_uuid
    Quantity = ls_item-quantity
    UnitPrice = ls_item-unit_price
     ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-salesitems
                                         msg = 'Kusursuz Sipariş Kalemleri (Item) Güncellenirken Hata Alındı!' ).

    READ ENTITIES OF zfab_r_so_hdr ENTITY SalesItems FIELDS ( Quantity UnitPrice )
    WITH VALUE #( FOR ls_item IN mt_base_so_itm ( %key-SoItmUuid = ls_item-so_itm_uuid ) ) RESULT DATA(lt_item_result).

    cl_abap_unit_assert=>assert_equals( act = lt_item_result[ 1 ]-Quantity  exp = '150.00' msg = 'Update başarılı dendi ama Miktar güncellenmemiş!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_item_result[ 1 ]-UnitPrice  exp = 50  msg = 'Update başarılı dendi ama Fiyat güncellenmemiş!' ).

    cl_abap_unit_assert=>assert_equals( act = lt_item_result[ 2 ]-Quantity   exp = '150.00' msg = 'Update başarılı dendi ama Miktar güncellenmemiş!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_item_result[ 2 ]-UnitPrice  exp = 50  msg = 'Update başarılı dendi ama Fiyat güncellenmemiş!' ).

    cl_abap_unit_assert=>assert_equals( act = lt_item_result[ 3 ]-Quantity   exp = '150.00' msg = 'Update başarılı dendi ama Miktar güncellenmemiş!' ).
    cl_abap_unit_assert=>assert_equals( act = lt_item_result[ 3 ]-UnitPrice  exp = 50  msg = 'Update başarılı dendi ama Fiyat güncellenmemiş!' ).

  ENDMETHOD.

  METHOD update_recalculate_total.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      <ls_base_so_itm>-quantity = '150.00'.
      <ls_base_so_itm>-unit_price = '50.00'.

    ENDLOOP.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY SalesItems
    UPDATE FIELDS ( Quantity UnitPrice )
    WITH VALUE #( FOR ls_item IN mt_base_so_itm (
    %key-SoItmUuid = ls_item-so_itm_uuid
    Quantity = ls_item-quantity
    UnitPrice = ls_item-unit_price
     ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-salesitems
                                         msg = 'Kusursuz Sipariş Kalemleri (Item) Güncellenirken Hata Alındı!' ).

    READ ENTITIES OF zfab_r_so_hdr ENTITY Sales FIELDS ( TotalAmount )
    WITH VALUE #( ( %key-SoUuid = ms_base_so_hdr-so_uuid ) ) RESULT DATA(ls_so_hd_result).

    cl_abap_unit_assert=>assert_equals( act = ls_so_hd_result[ 1 ]-TotalAmount exp = '22500.00' msg = 'Update İşlemi Başarılı Fakat Header Total Amount Güncellenmedi!' ).

  ENDMETHOD.

  METHOD validate_completed_so.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY Sales UPDATE FIELDS ( Status )
    WITH VALUE #( ( %key-SoUuid = ms_base_so_hdr-so_uuid
                    Status = 'C' ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-sales msg = 'Update Başarılı Olmalıydı Fakat Hata Verdi!' ).

    LOOP AT mt_base_so_itm ASSIGNING FIELD-SYMBOL(<ls_base_so_itm>).

      <ls_base_so_itm>-quantity = '150.00'.
      <ls_base_so_itm>-unit_price = '50.00'.

    ENDLOOP.

    execute_update_test( is_so_hdr_data = ms_base_so_hdr it_so_itm_data = mt_base_so_itm iv_msgno = '310' ).

  ENDMETHOD.

  METHOD validate_quantity_invalid.

    DATA(lt_so_itm) = mt_base_so_itm.

    LOOP AT lt_so_itm ASSIGNING FIELD-SYMBOL(<ls_so_itm>).
      CLEAR <ls_so_itm>-quantity.
    ENDLOOP.

    execute_update_test( is_so_hdr_data = ms_base_so_hdr it_so_itm_data = lt_so_itm iv_msgno = '311' ).

  ENDMETHOD.

  METHOD validate_unitprice_invalid.

    DATA(lt_so_itm) = mt_base_so_itm.

    LOOP AT lt_so_itm ASSIGNING FIELD-SYMBOL(<ls_so_itm>).
      CLEAR <ls_so_itm>-unit_price.
    ENDLOOP.

    execute_update_test( is_so_hdr_data = ms_base_so_hdr it_so_itm_data = lt_so_itm iv_msgno = '312' ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_so_delete_test DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.

    TYPES: tt_so_itm TYPE STANDARD TABLE OF zfab_t_so_itm WITH DEFAULT KEY.

    DATA: ms_base_so_hdr TYPE zfab_t_so_hdr,
          mt_base_so_itm TYPE tt_so_itm,
          ms_base_bp     TYPE zfab_t_bp,
          ms_base_mat    TYPE zfab_t_mat.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      successful_test           FOR TESTING,
      validate_delete_complete  FOR TESTING,
      test_recalculate_total    FOR TESTING.



ENDCLASS.

CLASS ltcl_so_delete_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_SO_HDR' )
                                                                                                      ( i_for_entity = 'ZFAB_R_SO_ITM' )
                                                                                                      ( i_for_entity = 'ZFAB_R_MAT' )
                                                                                                      ( i_for_entity = 'ZFAB_R_BP' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'C' ).
    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).

    DATA: lt_mock_db_bp  TYPE STANDARD TABLE OF zfab_t_bp,
          lt_mock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.

    APPEND ms_base_bp TO lt_mock_db_bp.
    APPEND ms_base_mat TO lt_mock_db_mat.

    go_mock_environment->insert_test_data( i_data = lt_mock_db_bp ).
    go_mock_environment->insert_test_data( i_data = lt_mock_db_mat ).

    ms_base_so_hdr = zcl_fab_mock_factory=>get_valid_so_header( iv_customer_uuid = ms_base_bp-bp_uuid ).
    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items( so_header_uuid = ms_base_so_hdr-so_uuid iv_mat_uuid = ms_base_mat-mat_uuid ).

    DATA: lt_mock_db_so_hdr TYPE STANDARD TABLE OF zfab_t_so_hdr.

    APPEND ms_base_so_hdr TO lt_mock_db_so_hdr.

    go_mock_environment->insert_test_data( i_data = lt_mock_db_so_hdr ).
    go_mock_environment->insert_test_data( i_data = mt_base_so_itm ).

  ENDMETHOD.

  METHOD teardown.

    go_mock_environment->clear_doubles(  ).
    CLEAR: ms_base_bp,
           ms_base_mat,
           ms_base_so_hdr,
           mt_base_so_itm.

  ENDMETHOD.

  METHOD successful_test.

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY Sales DELETE FROM VALUE #( ( SoUuid = ms_base_so_hdr-so_uuid ) )
    FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-sales msg = 'Silme İşlemi Hata Vermemeliydi Fakat Verdi!' ).

    READ ENTITIES OF zfab_r_so_hdr
    ENTITY SalesItems ALL FIELDS WITH VALUE #( FOR ls_item IN mt_base_so_itm ( %key-SoItmUuid = ls_item-so_itm_uuid ) ) RESULT DATA(lt_item_result).

    cl_abap_unit_assert=>assert_initial( act = lt_item_result msg = 'Silme İşlemi Tamamlandı Ama Ona Bağlı Alt İtemler Silinmemiş!' ).

  ENDMETHOD.

  METHOD test_recalculate_total.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
    ENTITY SalesItems DELETE FROM VALUE #( ( %key-SoItmUuid = mt_base_so_itm[ 1 ]-so_itm_uuid ) )
    FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-salesitems msg = 'Silme İşlemi Hata Vermemeliydi Fakat Verdi!' ).

    READ ENTITIES OF zfab_r_so_hdr
    ENTITY Sales FIELDS ( TotalAmount ) WITH VALUE #( ( %key-SoUuid = ms_base_so_hdr-so_uuid ) ) RESULT DATA(ls_so_hdr_result).

    cl_abap_unit_assert=>assert_equals( act = ls_so_hdr_result[ 1 ]-TotalAmount exp = '10850.00' msg = 'Silme İşlemi Gerçekleşti Fakat Header Tablosunun Total Amountu Değişmedi!' ).

  ENDMETHOD.

METHOD validate_delete_complete.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_so_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
      UPDATE FIELDS ( Status )
      WITH VALUE #( ( %key-SoUuid = ms_base_so_hdr-so_uuid
                      Status      = 'C' ) )
      FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial(
      act = lt_failed-sales
      msg = 'Statü C (Completed) yapılırken hata alındı, sahne hazırlanamadı!' ).

    CLEAR lt_failed.

    MODIFY ENTITIES OF zfab_r_so_hdr
      ENTITY Sales
      DELETE FROM VALUE #( ( %key-SoUuid = ms_base_so_hdr-so_uuid ) )
      FAILED lt_failed
      REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
      act = lt_failed-sales
      msg = 'Statüsü Tamamlandı (C) olan sipariş silinmemeliydi ama sistem buna izin verdi!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-sales INTO DATA(ls_reported).
      IF ls_reported-%msg IS BOUND AND ls_reported-%msg IS INSTANCE OF if_t100_message.
        DATA(lo_msg) = CAST if_t100_message( ls_reported-%msg ).

        IF lo_msg->t100key-msgid = 'ZFAB_MC_MINIERP' AND
           lo_msg->t100key-msgno = '317'.

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
