CLASS ltcl_bp_create_tests DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CLASS-DATA go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA ms_base_bp TYPE zfab_t_bp.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_create_test IMPORTING is_bp_data TYPE zfab_t_bp
                                    iv_msgno   TYPE symsgno,
      validate_BpId_initial        FOR TESTING,
      validate_BpRole_initial      FOR TESTING,
      validate_CompanyName_initial FOR TESTING,
      validate_TaxNumber_initial   FOR TESTING,
      validate_TaxOffice_initial   FOR TESTING,
      validate_Country_initial     FOR TESTING,
      validate_Email_initial       FOR TESTING,
      validate_City_initial        FOR TESTING,
      validate_Email_invalid       FOR TESTING,
      validate_Role_invalid        FOR TESTING,
      validate_TaxNumber_invalid   FOR TESTING,
      validate_Country_invalid     FOR TESTING,
      validate_dublicate_bpid      FOR TESTING,
      succesful_test               FOR TESTING.


ENDCLASS.

CLASS ltcl_bp_create_tests IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create( i_for_entity = 'ZFAB_R_BP' ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.
    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'C' ).
  ENDMETHOD.

  METHOD teardown.
    CLEAR ms_base_bp.
    go_mock_environment->clear_doubles(  ).
  ENDMETHOD.

  METHOD execute_create_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    CREATE FIELDS ( BpId BpRole CompanyName TaxNumber TaxOffice Phone Email Country City District Neighborhood AddrDetail PostalCode )
    WITH VALUE #( (
    %cid = 'MOCK_BP'
    BpId = is_bp_data-bp_id
    BpRole = is_bp_data-bp_role
    CompanyName = is_bp_data-company_name
    TaxNumber = is_bp_data-tax_number
    TaxOffice = is_bp_data-tax_office
    Phone =  is_bp_data-phone
    Email = is_bp_data-email
    Country = is_bp_data-country
    City = is_bp_data-city
    District = is_bp_data-district
    Neighborhood = is_bp_data-neighborhood
    AddrDetail = is_bp_data-addr_detail
    PostalCode = is_bp_data-postal_code
    ) ) FAILED lt_failed
        REPORTED lt_reported.


    cl_abap_unit_assert=>assert_not_initial(
     act = lt_failed-_businesspartner
     msg = 'Hata vermesi gerekiyordu ama kayit basarili oldu!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_businesspartner INTO DATA(ls_reported).

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

  METHOD validate_bpid_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-bp_id = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '101' ).

  ENDMETHOD.

  METHOD validate_bprole_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-bp_role = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '102' ).

  ENDMETHOD.

  METHOD validate_city_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-city = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '103' ).

  ENDMETHOD.

  METHOD validate_companyname_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-company_name = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '104' ).

  ENDMETHOD.

  METHOD validate_country_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-country = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '105' ).

  ENDMETHOD.

  METHOD validate_country_invalid.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-country = 'XYZ'.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '109' ).

  ENDMETHOD.

  METHOD validate_email_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-email = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '106' ).

  ENDMETHOD.

  METHOD validate_email_invalid.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-email = 'okan.sevinc.com'.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '110' ).

  ENDMETHOD.

  METHOD validate_role_invalid.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-bp_role = 'K'.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '111' ).

  ENDMETHOD.

  METHOD validate_taxnumber_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-tax_number = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '107' ).

  ENDMETHOD.

  METHOD validate_taxnumber_invalid.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-tax_number = '123abc'.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '112' ).

  ENDMETHOD.

  METHOD validate_taxoffice_initial.

    DATA(ls_test_data) = ms_base_bp.
    ls_test_data-tax_office = ''.

    execute_create_test( is_bp_data = ls_test_data iv_msgno = '108' ).

  ENDMETHOD.

  METHOD succesful_test.

    DATA(ls_test_data) = ms_base_bp.
    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    CREATE FIELDS ( BpId BpRole CompanyName TaxNumber TaxOffice Phone Email Country City District Neighborhood AddrDetail PostalCode )
    WITH VALUE #( (
    %cid = 'MOCK_BP'
    BpId = ls_test_data-bp_id
    BpRole = ls_test_data-bp_role
    CompanyName = ls_test_data-company_name
    TaxNumber = ls_test_data-tax_number
    TaxOffice = ls_test_data-tax_office
    Phone =  ls_test_data-phone
    Email = ls_test_data-email
    Country = ls_test_data-country
    City = ls_test_data-city
    District = ls_test_data-district
    Neighborhood = ls_test_data-neighborhood
    AddrDetail = ls_test_data-addr_detail
    PostalCode = ls_test_data-postal_code
    ) ) FAILED lt_failed
        REPORTED lt_reported.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-_businesspartner
                                        msg = 'BP Create Happy Path patladı: Kusursuz Oluşturma hata aldı!' ).

  ENDMETHOD.

  METHOD validate_dublicate_bpid.

    DATA(ls_bp_data) = ms_base_bp.
    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_bp TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ls_bp_data TO lt_mock_db_bp.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_bp ).

    execute_create_test( is_bp_data = ls_bp_data iv_msgno = '113' ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_bp_update_tests DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CLASS-DATA go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA ms_base_bp TYPE zfab_t_bp.



    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_update_test IMPORTING is_bp_data TYPE zfab_t_bp
                                    iv_msgno   TYPE symsgno,
      validate_BpId_readonly        FOR TESTING,
      validate_BpRole_readonly      FOR TESTING,
      validate_CompanyName_initial  FOR TESTING,
      validate_TaxNumber_initial    FOR TESTING,
      validate_TaxOffice_initial    FOR TESTING,
      validate_Country_initial      FOR TESTING,
      validate_Email_initial        FOR TESTING,
      validate_City_initial         FOR TESTING,
      validate_Email_invalid        FOR TESTING,
      validate_TaxNumber_invalid    FOR TESTING,
      validate_Country_invalid      FOR TESTING,
      succesful_test                FOR TESTING.


ENDCLASS.

CLASS ltcl_bp_update_tests IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create( i_for_entity = 'ZFAB_R_BP' ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'C' ).

    DATA lt_mock_db_data TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ms_base_bp TO lt_mock_db_data.

    go_mock_environment->insert_test_data( i_data = lt_mock_db_data ).

  ENDMETHOD.

  METHOD teardown.

    go_mock_environment->clear_doubles(  ).
    CLEAR ms_base_bp.

  ENDMETHOD.

  METHOD execute_update_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    UPDATE FIELDS ( CompanyName TaxNumber TaxOffice Phone Email Country City District Neighborhood AddrDetail PostalCode )
    WITH VALUE #( (
    BpUuid = is_bp_data-bp_uuid
    CompanyName = is_bp_data-company_name
    TaxNumber = is_bp_data-tax_number
    TaxOffice = is_bp_data-tax_office
    Phone = is_bp_data-phone
    Email = is_bp_data-email
    Country = is_bp_data-country
    City = is_bp_data-city
    District = is_bp_data-district
    Neighborhood = is_bp_data-neighborhood
    AddrDetail = is_bp_data-addr_detail
    PostalCode = is_bp_data-postal_code
    ) ) FAILED lt_failed
        REPORTED lt_reported.


    cl_abap_unit_assert=>assert_not_initial(
     act = lt_failed-_businesspartner
     msg = 'Hata vermesi gerekiyordu ama kayit basarili oldu!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_businesspartner INTO DATA(ls_reported).

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

  METHOD validate_city_initial.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-city = ''.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '103' ).

  ENDMETHOD.

  METHOD validate_companyname_initial.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-company_name = ''.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '104' ).

  ENDMETHOD.

  METHOD validate_country_initial.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-country = ''.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '105' ).

  ENDMETHOD.

  METHOD validate_country_invalid.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-country = 'XYZ'.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '109' ).

  ENDMETHOD.

  METHOD validate_email_initial.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-email = ''.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '106' ).

  ENDMETHOD.

  METHOD validate_email_invalid.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-email = 'okan.sevinc.com'.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '110' ).

  ENDMETHOD.


  METHOD validate_taxnumber_initial.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-tax_number = ''.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '107' ).

  ENDMETHOD.

  METHOD validate_taxnumber_invalid.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-tax_number = '123asd'.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '112' ).

  ENDMETHOD.

  METHOD validate_taxoffice_initial.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-tax_office = ''.

    execute_update_test( is_bp_data = ls_bp_data iv_msgno = '108' ).

  ENDMETHOD.

  METHOD validate_bpid_readonly.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-bp_id = 'BP-1'.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    UPDATE FIELDS ( BpId )
    WITH VALUE #( (
    BpUuid = ls_bp_data-bp_uuid
    BpId = ls_bp_data-bp_id
    ) ) FAILED lt_failed
        REPORTED lt_reported.


    cl_abap_unit_assert=>assert_not_initial(
     act = lt_failed-_businesspartner
     msg = 'Hata vermesi gerekiyordu ama kayit basarili oldu!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_businesspartner INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = '114'.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_correct_error_found
      msg = |Kayit istenilen { '114' } nolu hatadan dolayı patlamadı!| ).

  ENDMETHOD.

  METHOD validate_bprole_readonly.

    DATA(ls_bp_data) = ms_base_bp.
    ls_bp_data-bp_role = 'C'.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    UPDATE FIELDS ( BpRole )
    WITH VALUE #( (
    BpUuid = ls_bp_data-bp_uuid
    BpRole = ls_bp_data-bp_role
    ) ) FAILED lt_failed
        REPORTED lt_reported.


    cl_abap_unit_assert=>assert_not_initial(
     act = lt_failed-_businesspartner
     msg = 'Hata vermesi gerekiyordu ama kayit basarili oldu!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_businesspartner INTO DATA(ls_reported).

      IF ls_reported-%msg IS BOUND AND
         ls_reported-%msg->if_t100_message~t100key-msgid = 'ZFAB_MC_MINIERP' AND
         ls_reported-%msg->if_t100_message~t100key-msgno = '115'.

        lv_correct_error_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_correct_error_found
      msg = |Kayit istenilen { '115' } nolu hatadan dolayı patlamadı!| ).

  ENDMETHOD.

  METHOD succesful_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.
    DATA(ls_bp_data) = ms_base_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    UPDATE FIELDS ( CompanyName TaxNumber TaxOffice Phone Email Country City District Neighborhood AddrDetail PostalCode )
    WITH VALUE #( (
    BpUuid = ls_bp_data-bp_uuid
    CompanyName = ls_bp_data-company_name
    TaxNumber = ls_bp_data-tax_number
    TaxOffice = ls_bp_data-tax_office
    Phone = ls_bp_data-phone
    Email = ls_bp_data-email
    Country = ls_bp_data-country
    City = ls_bp_data-city
    District = ls_bp_data-district
    Neighborhood = ls_bp_data-neighborhood
    AddrDetail = ls_bp_data-addr_detail
    PostalCode = ls_bp_data-postal_code
    ) ) FAILED lt_failed
        REPORTED lt_reported.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-_businesspartner
                                        msg = 'BP Update Happy Path patladı: Kusursuz güncelleme hata aldı!' ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_bp_delete_tests DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CLASS-DATA go_mock_environment TYPE REF TO if_cds_test_environment.
    DATA ms_base_bp TYPE zfab_t_bp.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup,
      teardown,
      execute_delete_test IMPORTING is_bp_data TYPE zfab_t_bp
                                    iv_msgno   TYPE symsgno,
      validate_delete_has_so FOR TESTING,
      validate_delete_has_po FOR TESTING,
      succesful_test         FOR TESTING.



ENDCLASS.

CLASS ltcl_bp_delete_tests IMPLEMENTATION.

  METHOD class_setup.

    go_mock_environment = cl_cds_test_environment=>create_for_multiple_cds( i_for_entities = VALUE #( ( i_for_entity = 'ZFAB_R_BP' )
                                                                                                       ( i_for_entity = 'ZFAB_R_PO_HDR' )
                                                                                                       ( i_for_entity = 'ZFAB_R_PO_ITM' )
                                                                                                       ( i_for_entity = 'ZFAB_R_SO_HDR' )
                                                                                                       ( i_for_entity = 'ZFAB_R_SO_ITM' ) ) ).

  ENDMETHOD.

  METHOD class_teardown.

    go_mock_environment->destroy(  ).

  ENDMETHOD.

  METHOD setup.

    ms_base_bp = zcl_fab_mock_factory=>get_valid_businesspartner( iv_bp_role = 'C' ).

  ENDMETHOD.

  METHOD teardown.

    CLEAR ms_base_bp.
    go_mock_environment->clear_doubles(  ).

  ENDMETHOD.

  METHOD execute_delete_test.

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
      ENTITY _BusinessPartner
      DELETE FROM VALUE #( ( BpUuid = is_bp_data-bp_uuid ) )
      FAILED lt_failed
      REPORTED lt_reported.

    cl_abap_unit_assert=>assert_not_initial(
       act = lt_failed-_businesspartner
       msg = 'Silme işlemi engellenmeliydi ama kayit silindi!' ).

    DATA(lv_correct_error_found) = abap_false.

    LOOP AT lt_reported-_businesspartner INTO DATA(ls_reported).

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
      msg = |Silme islemi istenilen { iv_msgno } nolu hatadan dolayı patlamadı!| ).

  ENDMETHOD.

  METHOD succesful_test.

    DATA(ls_bp_data) = ms_base_bp.
    DATA lt_lock_db_bp TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ls_bp_data TO lt_lock_db_bp.
    go_mock_environment->insert_test_data( i_data = lt_lock_db_bp ).

    DATA: lt_failed   TYPE RESPONSE FOR FAILED zfab_r_bp,
          lt_reported TYPE RESPONSE FOR REPORTED zfab_r_bp.

    MODIFY ENTITIES OF zfab_r_bp
    ENTITY _BusinessPartner
    DELETE FROM VALUE #( ( BpUuid = ls_bp_data-bp_uuid ) )
    FAILED lt_failed
    REPORTED lt_reported.

    cl_abap_unit_assert=>assert_initial( act = lt_failed-_businesspartner
                                        msg = 'BP Delete Happy Path patladı: Kusursuz Silme Hata Aldı!' ).

  ENDMETHOD.

  METHOD validate_delete_has_po.

    DATA(ls_bp_data) = ms_base_bp.
    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_bp TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ls_bp_data TO lt_mock_db_bp.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_bp ).

    DATA: lt_mock_db_po_hdr TYPE STANDARD TABLE OF zfab_t_po_hdr.
    DATA(ls_po_hdr_data) = zcl_fab_mock_factory=>get_valid_po_header( iv_vendor_uuid = ls_bp_data-bp_uuid ).
    APPEND ls_po_hdr_data TO lt_mock_db_po_hdr.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_po_hdr ).

    TRY.
        DATA(lt_po_itm_data) = zcl_fab_mock_factory=>get_valid_po_items(
                                 po_header_uuid = ls_po_hdr_data-po_uuid
                                 iv_mat_uuid    = cl_system_uuid=>create_uuid_x16_static( ) ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için Material UUID üretilemedi!' ).
    ENDTRY.

    go_mock_environment->insert_test_data( i_data = lt_po_itm_data ).

    execute_delete_test( is_bp_data = ls_bp_data iv_msgno = '116' ).

  ENDMETHOD.

  METHOD validate_delete_has_so.

    DATA(ls_bp_data) = ms_base_bp.

    go_mock_environment->clear_doubles( ).

    DATA lt_mock_db_bp TYPE STANDARD TABLE OF zfab_t_bp.
    APPEND ls_bp_data TO lt_mock_db_bp.
    go_mock_environment->insert_test_data( i_data = lt_mock_db_bp ).

    DATA: lt_mock_db_so_hdr TYPE STANDARD TABLE OF zfab_t_so_hdr,
          lt_mock_db_so_itm TYPE STANDARD TABLE OF zfab_t_so_itm.

    DATA(ls_so_hdr_data) = zcl_fab_mock_factory=>get_valid_so_header( iv_customer_uuid = ls_bp_data-bp_uuid ).
    TRY.
        DATA(ls_so_itm_data) = zcl_fab_mock_factory=>get_valid_so_itm( iv_so_header_uuid = ls_so_hdr_data-so_uuid iv_mat_uuid = cl_system_uuid=>create_uuid_x16_static( ) ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için Material UUID üretilemedi!' ).
    ENDTRY.

    APPEND ls_so_hdr_data TO lt_mock_db_so_hdr.
    APPEND ls_so_itm_data TO lt_mock_db_so_itm.

    go_mock_environment->insert_test_data( i_data = lt_mock_db_so_hdr ).
    go_mock_environment->insert_test_data( i_data = lt_mock_db_so_itm ).

    execute_delete_test( is_bp_data = ls_bp_data iv_msgno = '117' ).

  ENDMETHOD.

ENDCLASS.
