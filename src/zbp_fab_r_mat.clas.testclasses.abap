CLASS ltcl_mat_create_test DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA: ms_base_mat TYPE zfab_t_mat.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_create_test IMPORTING is_mat_data TYPE zfab_t_mat
                                    iv_msgno    TYPE symsgno,
      validate_MatId_initial        FOR TESTING,
      validate_MatType_initial      FOR TESTING,
      validate_MatGroup_initial     FOR TESTING,
      validate_Description_initial  FOR TESTING,
      validate_Weight_initial       FOR TESTING,
      validate_WeightUnit_initial   FOR TESTING,
      validate_SafetyStock_initial  FOR TESTING,
      validate_BaseUom_initial      FOR TESTING,
      validate_NetPrice_initial     FOR TESTING,
      validate_Waers_initial        FOR TESTING,
      validate_Negative_netprice    FOR TESTING,
      validate_Negative_SafetyStock FOR TESTING,
      validate_Invalid_Waers        FOR TESTING,
      validate_Invalid_BaseUom      FOR TESTING,
      validate_Invalid_WeightUnit   FOR TESTING,
      succesful_test                FOR TESTING,
      validate_duplicate_entity     FOR TESTING.


ENDCLASS.

CLASS ltcl_mat_create_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create( i_for_entity = 'ZFAB_R_MAT' ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    ms_base_mat = zcl_fab_mock_factory=>get_valid_material( ).

  ENDMETHOD.

  METHOD teardown.

    go_mock_environment->clear_doubles(  ).
    CLEAR ms_base_mat.

  ENDMETHOD.

  METHOD execute_create_test.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_mat.
    DATA: lt_reported TYPE RESPONSE FOR REPORTED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
        ENTITY _MaterialProduct
        CREATE FIELDS ( MatId MatType MatGroup Description Weight WeightUnit SafetyStock BaseUom NetPrice Waers )
        WITH VALUE #( (
         %cid = 'MOCK_CID_MATERIAL'
         MatId = is_mat_data-mat_id
         MatType = is_mat_data-mat_type
         MatGroup = is_mat_data-mat_group
         Description = is_mat_data-description
         Weight = is_mat_data-weight
         WeightUnit = is_mat_data-weight_unit
         SafetyStock = is_mat_data-safety_stock
         BaseUom = is_mat_data-base_uom
         NetPrice = is_mat_data-net_price
         waers = is_mat_data-waers
         )  ) FAILED lt_failed
              REPORTED lt_reported.


    cl_abap_unit_assert=>assert_not_initial(
     act = lt_failed-_materialproduct
     msg = 'Hata vermesi gerekiyordu ama kayit basarili oldu!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_materialproduct INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = iv_msgno.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_correct_error_found
      msg = |Kayit istenilen { iv_msgno } nolu hatadan dolayı patlamadı!| ).


  ENDMETHOD.

  METHOD validate_MatId_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-mat_id = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '001' ).

  ENDMETHOD.

  METHOD validate_baseuom_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-base_uom = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '002' ).

  ENDMETHOD.

  METHOD validate_description_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-description = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '003' ).

  ENDMETHOD.

  METHOD validate_matgroup_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-mat_group = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '004' ).

  ENDMETHOD.

  METHOD validate_mattype_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-mat_type = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '005' ).

  ENDMETHOD.

  METHOD validate_netprice_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-net_price = 0.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '006' ).

  ENDMETHOD.

  METHOD validate_safetystock_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-safety_stock = 0.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '007' ).

  ENDMETHOD.

  METHOD validate_waers_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-waers = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '008' ).

  ENDMETHOD.

  METHOD validate_weightunit_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-weight_unit = ''.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '009' ).

  ENDMETHOD.

  METHOD validate_weight_initial.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-weight = 0.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '010' ).

  ENDMETHOD.

  METHOD validate_negative_netprice.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-net_price = -100.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '011' ).

  ENDMETHOD.

  METHOD validate_negative_safetystock.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-safety_stock = -100.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '012' ).

  ENDMETHOD.

  METHOD validate_invalid_waers.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-waers = 'XYZ'.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '013' ).

  ENDMETHOD.

  METHOD validate_invalid_baseuom.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-base_uom = 'XYZ'.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '014' ).

  ENDMETHOD.

  METHOD validate_invalid_weightunit.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-weight_unit = 'XYZ'.

    execute_create_test( is_mat_data = ls_test_data iv_msgno = '015' ).

  ENDMETHOD.

  METHOD succesful_test.
    DATA(ls_test_data) = ms_base_mat.
    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
    ENTITY _MaterialProduct
    CREATE FIELDS ( MatId MatType MatGroup Description Weight WeightUnit SafetyStock BaseUom NetPrice Waers )
    WITH VALUE #( (
       %cid = 'MOCK SUCCES'
       MatId = ls_test_data-mat_id
       MatType = ls_test_data-mat_type
       MatGroup = ls_test_data-mat_group
       Description = ls_test_data-description
       Weight = ls_test_data-weight
       WeightUnit = ls_test_data-weight_unit
       SafetyStock = ls_test_data-safety_stock
       BaseUom = ls_test_data-base_uom
       NetPrice = ls_test_data-net_price
       Waers = ls_test_data-waers

    ) ) FAILED lt_failed.


    cl_abap_unit_assert=>assert_initial(
    act = lt_failed-_materialproduct ).


  ENDMETHOD.

  METHOD validate_duplicate_entity.

    DATA(ls_mat_data) = ms_base_mat.
    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.
    APPEND ls_mat_data TO lt_mock_db_mat.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_mat ).

    execute_create_test( is_mat_data = ls_mat_data iv_msgno = '022' ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_mat_update_test DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA: ms_base_mat TYPE zfab_t_mat.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      update_mat_entity IMPORTING is_mat_data TYPE zfab_t_mat
                                  iv_msgno    TYPE symsgno,
      validate_matid_unchangeable   FOR TESTING,
      validate_baseuom_unchangeable FOR TESTING,
      validate_weightunit_unc       FOR TESTING,
      validate_netprice_negative    FOR TESTING,
      validate_safestock_negative   FOR TESTING,
      validate_invalid_waers        FOR TESTING,
      validate_desc_empty           FOR TESTING,
      succesful_test                FOR TESTING.




ENDCLASS.

CLASS ltcl_mat_update_test IMPLEMENTATION.

  METHOD class_setup.
    go_mock_environment = cl_cds_test_environment=>create( 'ZFAB_R_MAT' ).
  ENDMETHOD.

  METHOD class_teardown.
    go_mock_environment->destroy(  ).
  ENDMETHOD.


  METHOD setup.

    ms_base_mat = zcl_fab_mock_factory=>get_valid_material( ).

    DATA: lt_mock_db_data TYPE STANDARD TABLE OF zfab_t_mat.
    APPEND ms_base_mat TO lt_mock_db_data.

    go_mock_environment->insert_test_data( i_data = lt_mock_db_data ).

  ENDMETHOD.

  METHOD teardown.
    go_mock_environment->clear_doubles(  ).
    CLEAR ms_base_mat.
  ENDMETHOD.

  METHOD update_mat_entity.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_mat,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
            ENTITY _MaterialProduct
            UPDATE FIELDS ( MatType MatGroup Description Weight SafetyStock NetPrice Waers )
            WITH VALUE #( (
                            MatUuid = is_mat_data-mat_uuid
                            MatType = is_mat_data-mat_type
                            MatGroup = is_mat_data-mat_group
                            Description = is_mat_data-description
                            Weight = is_mat_data-weight
                            SafetyStock = is_mat_data-safety_stock
                            NetPrice = is_mat_data-net_price
                            Waers = is_mat_data-waers
    ) ) FAILED lt_failed
        REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
    act = lt_failed-_materialproduct
    msg = 'Test Hata Vermeliydi Fakat Başarılı Kayıt Yapıldı!'  ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_materialproduct INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = iv_msgno.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
    act = lv_correct_error_found
    msg = |'Sistem Istenilen ' { iv_msgno } ' Nolu Hatadan Dolayı Patlamadı!'| ).

  ENDMETHOD.

  METHOD validate_baseuom_unchangeable.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-base_uom = 'L'.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_mat,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
            ENTITY _MaterialProduct
            UPDATE FIELDS ( BaseUom )
            WITH VALUE #( (
            BaseUom = ls_test_data-base_uom
    ) ) FAILED lt_failed
        REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
    act = lt_failed-_materialproduct
    msg = 'Test Hata Vermeliydi Fakat Başarılı Kayıt Yapıldı!'  ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_materialproduct INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = '016'.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
    act = lv_correct_error_found
    msg = |'Sistem Istenilen ' { '016' } ' Nolu Hatadan Dolayı Patlamadı!'| ).

  ENDMETHOD.

  METHOD validate_matid_unchangeable.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-mat_id = 'Çinko01'.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_mat,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
            ENTITY _MaterialProduct
            UPDATE FIELDS ( MatId )
            WITH VALUE #( (
            BaseUom = ls_test_data-mat_id
    ) ) FAILED lt_failed
        REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
    act = lt_failed-_materialproduct
    msg = 'Test Hata Vermeliydi Fakat Başarılı Kayıt Yapıldı!'  ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_materialproduct INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = '017'.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
    act = lv_correct_error_found
    msg = |'Sistem Istenilen ' { '017' } ' Nolu Hatadan Dolayı Patlamadı!'| ).

  ENDMETHOD.

  METHOD validate_weightunit_unc.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-weight_unit = 'L'.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_mat,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
            ENTITY _MaterialProduct
            UPDATE FIELDS ( WeightUnit )
            WITH VALUE #( (
            BaseUom = ls_test_data-weight_unit
    ) ) FAILED lt_failed
        REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
    act = lt_failed-_materialproduct
    msg = 'Test Hata Vermeliydi Fakat Başarılı Kayıt Yapıldı!'  ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_materialproduct INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = '018'.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
    act = lv_correct_error_found
    msg = |'Sistem Istenilen ' { '018' } ' Nolu Hatadan Dolayı Patlamadı!'| ).

  ENDMETHOD.

  METHOD validate_desc_empty.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-description = ''.

    update_mat_entity( is_mat_data = ls_test_data iv_msgno = '004' ).

  ENDMETHOD.

  METHOD validate_invalid_waers.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-waers = 'XYZ'.

    update_mat_entity( is_mat_data = ls_test_data iv_msgno = '013' ).

  ENDMETHOD.

  METHOD validate_netprice_negative.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-net_price = -50.

    update_mat_entity( is_mat_data = ls_test_data iv_msgno = '011' ).

  ENDMETHOD.

  METHOD validate_safestock_negative.

    DATA(ls_test_data) = ms_base_mat.
    ls_test_data-safety_stock = -50.

    update_mat_entity( is_mat_data = ls_test_data iv_msgno = '012' ).

  ENDMETHOD.

  METHOD succesful_test.

    Data(ls_mat_data) = ms_base_mat.
    DATA lt_failed type RESPONSE FOR FAILED zfab_r_mat.

    modify ENTITIES OF zfab_r_mat
    ENTITY _MaterialProduct
    UPDATE FIELDS ( MatType MatGroup Description Weight SafetyStock NetPrice Waers )
    WITH VALUE #( (
    MatUuid = ls_mat_data-mat_uuid
    MatType = 'FERT'
    MatGroup = 'ELEC'
    Description = 'Revize Edilmiş Sensör Modülü V2'
    Weight = '12.50'
    SafetyStock = 150
    NetPrice = '850.75'
    waers = 'EUR'
     ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-_materialproduct ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_mat_delete_test DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA ms_base_mat TYPE zfab_t_mat.


    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_delete_test IMPORTING is_mat_data TYPE zfab_t_mat
                                    iv_msgno    TYPE symsgno,
      validate_po_delete_test FOR TESTING,
      validate_so_delete_test FOR TESTING,
      validate_stock_test     FOR TESTING,
      succesful_test          FOR TESTING.
ENDCLASS.

CLASS ltcl_mat_delete_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #(
    ( i_for_entity = 'ZFAB_R_MAT' )
     ( i_for_entity = 'ZFAB_R_PO_HDR' )
      ( i_for_entity = 'ZFAB_R_PO_ITM' )
      ( i_for_entity = 'ZFAB_R_SO_HDR' )
       ( i_for_entity = 'ZFAB_R_SO_ITM' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    DATA lt_mock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.
    ms_base_mat = zcl_fab_mock_factory=>get_valid_material(  ).
    APPEND ms_base_mat TO lt_mock_db_mat.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_mat ).

  ENDMETHOD.

  METHOD teardown.

    go_mock_environment->clear_doubles(  ).
    CLEAR ms_base_mat.

  ENDMETHOD.

  METHOD execute_delete_test.

    DATA: lt_reported TYPE RESPONSE FOR REPORTED zfab_r_mat,
          lt_failed   TYPE RESPONSE FOR FAILED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
      ENTITY _MaterialProduct
      DELETE FROM VALUE #( ( MatUuid = is_mat_data-mat_uuid ) )
      FAILED lt_failed
      REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
      act = lt_failed-_materialproduct
      msg = 'Test Hata Vermeliydi Fakat Başarılı Silme İşlemi Yapıldı!'  ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_materialproduct INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND ls_reported-%msg IS INSTANCE OF if_t100_message.

        DATA(lo_t100_msg) = CAST if_t100_message( ls_reported-%msg ).

        IF lo_t100_msg->t100key-msgid = 'ZFAB_MC_MINIERP' AND
           lo_t100_msg->t100key-msgno = iv_msgno.

          lv_correct_error_found = abap_true.
          EXIT.
        ENDIF.

      ENDIF.

    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_correct_error_found
      msg = |Sistem Istenilen { iv_msgno } Nolu Hatadan Dolayı Patlamadı!| ).

  ENDMETHOD.

  METHOD succesful_test.

    DATA lt_failed TYPE RESPONSE FOR FAILED zfab_r_mat.
    DATA(ls_mat_data) = ms_base_mat.
    ls_mat_data-safety_stock = 0.

    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.
    APPEND ls_mat_data TO lt_mock_db_mat.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_mat ).

    MODIFY ENTITIES OF zfab_r_mat
        ENTITY _MaterialProduct
        DELETE FROM VALUE #( ( MatUuid = ls_mat_data-mat_uuid ) ) FAILED lt_failed.

    cl_abap_unit_assert=>assert_initial(
  act = lt_failed-_materialproduct
  msg = 'Test Başarı Ile Geçti :)'  ).

  ENDMETHOD.

  METHOD validate_po_delete_test.

    DATA(ls_mat_data) = ms_base_mat.
    ls_mat_data-safety_stock = 0.

    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.
    APPEND ls_mat_data TO lt_mock_db_mat.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_mat ).

    DATA: lt_mock_db_po_hdr TYPE STANDARD TABLE OF zfab_t_po_hdr,
          ms_base_po_hdr    TYPE zfab_t_po_hdr.

    DATA: lt_mock_db_po_itm TYPE STANDARD TABLE OF zfab_t_po_itm,
          ms_base_po_itm    TYPE zfab_t_po_itm.

    try.
    ms_base_po_hdr = zcl_fab_mock_factory=>get_valid_po_header( iv_vendor_uuid = cl_system_uuid=>create_uuid_x16_static( ) ).
    CATCH cx_uuid_error.
    cl_abap_unit_assert=>fail( 'Supplier UUID üretilemedi!' ).
    ENDTRY.
    ms_base_po_itm  = zcl_fab_mock_factory=>get_valid_po_itm( iv_mat_uuid = ls_mat_data-mat_uuid iv_po_header_uuid = ms_base_po_hdr-po_uuid ).

    ms_base_po_itm-po_uuid = ms_base_po_hdr-po_uuid.
    ms_base_po_itm-mat_uuid = ls_mat_data-mat_uuid.

    APPEND ms_base_po_hdr TO lt_mock_db_po_hdr.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_po_hdr ).

    APPEND ms_base_po_itm TO lt_mock_db_po_itm.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_po_itm ).

    execute_delete_test( is_mat_data = ls_mat_data iv_msgno = '020' ).


  ENDMETHOD.

  METHOD validate_so_delete_test.

    DATA(ls_mat_data) = ms_base_mat.
    ls_mat_data-safety_stock = 0.

    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_mat TYPE STANDARD TABLE OF zfab_t_mat.
    APPEND ls_mat_data TO lt_mock_db_mat.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_mat ).

    DATA: lt_mock_db_so_hdr TYPE STANDARD TABLE OF zfab_t_so_hdr,
          ms_base_so_hdr    TYPE zfab_t_so_hdr.

    DATA: lt_mock_db_so_itm TYPE STANDARD TABLE OF zfab_t_so_itm,
          ms_base_so_itm    TYPE zfab_t_so_itm.

    try.
    ms_base_so_hdr = zcl_fab_mock_factory=>get_valid_so_header( iv_customer_uuid = cl_system_uuid=>create_uuid_x16_static( ) ).
    CATCH cx_uuid_error.
    cl_abap_unit_assert=>fail( 'Customer UUID üretilemedi!' ).
    ENDTRY.
    ms_base_so_itm  = zcl_fab_mock_factory=>get_valid_so_itm( iv_mat_uuid = ls_mat_data-mat_uuid iv_so_header_uuid = ms_base_so_hdr-so_uuid ).

    APPEND ms_base_so_hdr TO lt_mock_db_so_hdr.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_so_hdr ).

    APPEND ms_base_so_itm TO lt_mock_db_so_itm.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_so_itm ).

    execute_delete_test( is_mat_data = ls_mat_data iv_msgno = '021' ).

  ENDMETHOD.

  METHOD validate_stock_test.
    DATA(ls_mat_data) = ms_base_mat.
    execute_delete_test( is_mat_data = ls_mat_data iv_msgno = '019' ).
  ENDMETHOD.

ENDCLASS.
