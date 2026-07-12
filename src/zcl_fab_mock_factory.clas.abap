CLASS zcl_fab_mock_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_so_itm TYPE STANDARD TABLE OF zfab_t_so_itm WITH DEFAULT KEY,
           tt_po_itm TYPE STANDARD TABLE OF zfab_t_po_itm WITH DEFAULT KEY.

    CLASS-METHODS:
      get_valid_material RETURNING VALUE(rs_mat) TYPE zfab_t_mat,
      get_valid_po_header RETURNING VALUE(rs_po_header) TYPE zfab_t_po_hdr,
      get_valid_po_itm RETURNING VALUE(rs_po_itm) TYPE zfab_t_po_itm,
      get_valid_so_header RETURNING VALUE(rs_so_header) TYPE zfab_t_so_hdr,
      get_valid_so_itm RETURNING VALUE(rs_so_itm) TYPE zfab_t_so_itm,
      get_valid_bussinesPartner RETURNING VALUE(rs_bp) TYPE zfab_t_bp,
      get_valid_so_items IMPORTING so_header_uuid TYPE sysuuid_x16
                                   iv_mat_uuid TYPE sysuuid_x16 RETURNING VALUE(rt_items) TYPE tt_so_itm,
      get_valid_po_items IMPORTING po_header_uuid TYPE sysuuid_x16
                                   iv_mat_uuid TYPE sysuuid_x16 RETURNING VALUE(rt_items) TYPE tt_po_itm.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_fab_mock_factory IMPLEMENTATION.

  METHOD get_valid_material.

    TRY.
        rs_mat = VALUE #(
          mat_uuid = cl_system_uuid=>create_uuid_x16_static(  )
          mat_id       = 'BKR-BOBIN-500'
          mat_type     = 'YARI MAMUL'
          mat_group    = 'Motor Parçaları'
          description  = '500W Endüstriyel Bakır Bobin Sargısı'
          weight       = '2.5'
          weight_unit  = 'KG'
          safety_stock = 150
          base_uom     = 'ST'
          net_price    = 850
          waers        = 'TRY' ).

      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi icin Material UUID uretilemedi!' ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_valid_po_header.

    TRY.
        rs_po_header = VALUE #(
            po_uuid = cl_system_uuid=>create_uuid_x16_static(  )
            po_id = '4500000001'
            vendor_uuid = cl_system_uuid=>create_uuid_x16_static(  )
            status = 'A'
            total_amount = '850000.00'
            waers = 'TRY'
         ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi icin Purchase Order Header UUID uretilemedi!' ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_valid_po_itm.

    TRY.
        rs_po_itm = VALUE #(
        po_uuid = cl_system_uuid=>create_uuid_x16_static(  )
        item_pos = '00010'
        mat_uuid = cl_system_uuid=>create_uuid_x16_static(  )
        quantity = 1000
        unit_uom = 'ST'
        unit_price = '850.00'
        waers = 'TRY'
        ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için Purhcase Order Item UUID üretilemedi!' ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_valid_so_header.

    TRY.
        rs_so_header = VALUE #(
        so_uuid = cl_system_uuid=>create_uuid_x16_static(  )
        so_id = '1000000001'
        customer_uuid = cl_system_uuid=>create_uuid_x16_static(  )
        status = 'C'
        total_amount = '42500.00'
        waers = 'TRY'
        ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için Sales Order Header UUID üretilemedi!' ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_valid_so_itm.

    TRY.
        rs_so_itm = VALUE #(
        so_uuid = cl_system_uuid=>create_uuid_x16_static(  )
        item_pos = '00010'
        mat_uuid = cl_system_uuid=>create_uuid_x16_static(  )
        quantity = 50
        unit_uom = 'ST'
        unit_price = '850'
        waers = 'TRY'
        ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için Sales Order Item UUID üretilemedi!' ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_valid_bussinespartner.

    TRY.
        rs_bp = VALUE #(
              bp_uuid       = cl_system_uuid=>create_uuid_x16_static(  )
              bp_id         = 'BP-1000'
              bp_role       = 'S'
              company_name  = 'Tech Solutions A.Ş.'
              tax_number    = '1234567890'
              tax_office    = 'Nilüfer V.D.'
              phone         = '+905551234567'
              email         = 'iletisim@techsolutions.com'
              country       = 'TR'
              city          = '16'
              district      = 'Nilüfer'
              neighborhood  = 'Odunluk Mah.'
              addr_detail   = 'Akademi Cad. No:10'
              postal_code   = '16110'
            ).
      CATCH cx_uuid_error.
        cl_abap_unit_assert=>fail( 'Mock verisi için Bussines Partner UUID üretilemedi!' ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_valid_so_items.

    TRY.

        rt_items = VALUE #(
          (
            so_itm_uuid = cl_system_uuid=>create_uuid_x16_static( )
            so_uuid     = so_header_uuid
            item_pos    = '000010'
            mat_uuid    = iv_mat_uuid
            quantity    = 10
            unit_uom    = 'PC'
            unit_price  = '450.00'
            waers       = 'TRY'
          )

          (
            so_itm_uuid = cl_system_uuid=>create_uuid_x16_static( )
            so_uuid     = so_header_uuid
            item_pos    = '000020'
            mat_uuid    = iv_mat_uuid
            quantity    = 50
            unit_uom    = 'PC'
            unit_price  = '125.50'
            waers       = 'TRY'
          )

          (
            so_itm_uuid = cl_system_uuid=>create_uuid_x16_static( )
            so_uuid     = so_header_uuid
            item_pos    = '000030'
            mat_uuid    = iv_mat_uuid
            quantity    = 100
            unit_uom    = 'PC'
            unit_price  = '45.75'
            waers       = 'TRY'
          )
        ).

      CATCH cx_uuid_error.

        cl_abap_unit_assert=>fail( 'Mock verisi için Sales Order Item UUID üretilemedi!' ).

    ENDTRY.

  ENDMETHOD.

  METHOD get_valid_po_items.

    TRY.

        rt_items = VALUE #(
          (
            po_itm_uuid = cl_system_uuid=>create_uuid_x16_static( )
            po_uuid     = po_header_uuid
            item_pos    = '000010'
            mat_uuid    = iv_mat_uuid
            quantity    = 100
            unit_uom    = 'PC'
            unit_price  = '150.00'
            waers       = 'TRY'
          )

          (
            po_itm_uuid = cl_system_uuid=>create_uuid_x16_static( )
            po_uuid     = po_header_uuid
            item_pos    = '000020'
            mat_uuid    = iv_mat_uuid
            quantity    = 500
            unit_uom    = 'PC'
            unit_price  = '85.50'
            waers       = 'TRY'
          )

          (
            po_itm_uuid = cl_system_uuid=>create_uuid_x16_static( )
            po_uuid     = po_header_uuid
            item_pos    = '000030'
            mat_uuid    = iv_mat_uuid
            quantity    = 1000
            unit_uom    = 'PC'
            unit_price  = '25.75'
            waers       = 'TRY'
          )
        ).

      CATCH cx_uuid_error.

        cl_abap_unit_assert=>fail( 'Mock verisi için Purchase Order Item UUID üretilemedi!' ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
