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
      execute_create_test IMPORTING is_mat_data    TYPE zfab_t_mat
                                    iv_msgno       TYPE symsgno,
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
      validate_Invalid_WeightUnit   FOR TESTING.

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

ENDCLASS.
