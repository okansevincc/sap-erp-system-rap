CLASS ltcl_mat_test DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA: go_mock_environment TYPE REF TO if_cds_test_environment.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      create_value  IMPORTING
                      iv_CId         TYPE string
                      iv_MatId       TYPE zfab_t_mat-mat_id DEFAULT 'Bakır01'
                      iv_MatType     TYPE zfab_t_mat-mat_type DEFAULT 'Ürün'
                      iv_MatGroup    TYPE zfab_t_mat-mat_group DEFAULT 'Hammadde'
                      iv_Description TYPE zfab_t_mat-description DEFAULT 'Bakır'
                      iv_Weight      TYPE zfab_t_mat-weight DEFAULT 100
                      iv_WeightUnit  TYPE zfab_t_mat-weight_unit DEFAULT 'KG'
                      iv_SafetyStock TYPE zfab_t_mat-safety_stock DEFAULT 100
                      iv_BaseUom     TYPE zfab_t_mat-base_uom DEFAULT 'KG'
                      iv_NetPrice    TYPE zfab_t_mat-net_price DEFAULT 100
                      iv_Waers       TYPE zfab_t_mat-waers DEFAULT 'TRY'
                      iv_Message     TYPE string
                      iv_expect_fail TYPE abap_bool DEFAULT abap_true,
      is_MatId_initial       FOR TESTING,
      is_MatType_initial     FOR TESTING,
      is_MatGroup_initial    FOR TESTING,
      is_Description_initial FOR TESTING,
      is_Weight_initial      FOR TESTING,
      is_WeightUnit_initial  FOR TESTING,
      is_SafetyStock_initial FOR TESTING,
      is_BaseUom_initial     FOR TESTING,
      is_NetPrice_initial    FOR TESTING,
      is_Waers_initial       FOR TESTING.

ENDCLASS.

CLASS ltcl_mat_test IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create( i_for_entity = 'ZFAB_R_MAT' ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    DATA: lt_mock_mat TYPE STANDARD TABLE OF zfab_t_mat.

  ENDMETHOD.

  METHOD teardown.
    go_mock_environment->clear_doubles(  ).
  ENDMETHOD.

  METHOD create_value.

    DATA: lt_failed TYPE RESPONSE FOR FAILED zfab_r_mat.

    MODIFY ENTITIES OF zfab_r_mat
        ENTITY _MaterialProduct
        CREATE FIELDS ( MatId MatType MatGroup Description Weight WeightUnit SafetyStock BaseUom NetPrice Waers )
        WITH VALUE #( (
         %cid = iv_CId
         MatId = iv_matid
         MatType = iv_mattype
         MatGroup = iv_matgroup
         Description = iv_description
         Weight = iv_weight
         WeightUnit = iv_weightunit
         SafetyStock = iv_safetystock
         BaseUom = iv_baseuom
         NetPrice = iv_netprice
         waers = iv_waers
         )  ) FAILED lt_failed.


    IF iv_expect_fail = abap_true.
      cl_abap_unit_assert=>assert_not_initial(
       act = lt_failed-_materialproduct
       msg = iv_message ).

    ELSE.
      cl_abap_unit_assert=>assert_initial(
       act = lt_failed-_materialproduct
       msg = iv_message ).
    ENDIF.

  ENDMETHOD.

  METHOD is_MatId_initial.

    create_value( iv_cid = 'Cid_test_1' iv_matid = '' iv_message = 'MatId Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_baseuom_initial.

    create_value( iv_cid = 'Cid_test_2' iv_baseuom = '' iv_message = 'BaseUom Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_description_initial.

    create_value( iv_cid = 'Cid_test_3' iv_description = '' iv_message = 'Desc Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_matgroup_initial.

    create_value( iv_cid = 'Cid_test_4' iv_matgroup = '' iv_message = 'MatGroup Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_mattype_initial.

    create_value( iv_cid = 'Cid_test_5' iv_mattype = '' iv_message = 'MatType Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_netprice_initial.

    create_value( iv_cid = 'Cid_test_6' iv_netprice = 0 iv_message = 'NetPrice Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_safetystock_initial.

    create_value( iv_cid = 'Cid_test_7' iv_safetystock = 0 iv_message = 'SafetyStock Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_waers_initial.

    create_value( iv_cid = 'Cid_test_8' iv_waers = '' iv_message = 'Waers Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_weightunit_initial.

    create_value( iv_cid = 'Cid_test_9' iv_weightunit = '' iv_message = 'WeightUnit Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

  METHOD is_weight_initial.

    create_value( iv_cid = 'Cid_test_10' iv_weight = 0 iv_message = 'Weight Olmayan bir Kayıt Açıldı!' iv_expect_fail = abap_true ).

  ENDMETHOD.

ENDCLASS.
