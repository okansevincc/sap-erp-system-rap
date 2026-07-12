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
      validate_active_req_item   FOR TESTING,
      test_initial_status_open   FOR TESTING,
      test_item_position_calc    FOR TESTING,
      test_header_total_calc     FOR TESTING,
      succesful_test             FOR TESTING.

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

    ms_base_so_hdr = zcl_fab_mock_factory=>get_valid_so_header(  ).

    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).
    ms_base_bp = zcl_fab_mock_factory=>get_valid_bussinespartner(  ).

    ms_base_so_hdr-customer_uuid = ms_base_bp-bp_uuid.

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

  ENDMETHOD.

  METHOD test_header_total_calc.

  ENDMETHOD.

  METHOD test_initial_status_open.

  ENDMETHOD.

  METHOD test_item_position_calc.

  ENDMETHOD.

  METHOD validate_active_req_item.

  ENDMETHOD.

  METHOD validate_customer_exists.

  ENDMETHOD.

  METHOD validate_customer_role.

  ENDMETHOD.

  METHOD validate_hdr_customer_init.

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

METHOD succesful_test.

    mt_base_so_itm = zcl_fab_mock_factory=>get_valid_so_items(
                       iv_mat_uuid    = ms_base_mat-mat_uuid
                       so_header_uuid = ms_base_so_hdr-so_uuid ).

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_so_hdr,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_so_hdr.

    MODIFY ENTITIES OF zfab_r_so_hdr
      " --- A) BAŞLIĞI YARAT ---
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
          SoUuid   = ms_base_so_hdr-so_uuid
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

ENDCLASS.
