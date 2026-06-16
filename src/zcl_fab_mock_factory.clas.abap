CLASS zcl_fab_mock_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_valid_material
      RETURNING VALUE(rs_mat) TYPE zfab_t_mat.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_fab_mock_factory IMPLEMENTATION.

  METHOD get_valid_material.
    rs_mat = VALUE #(
      mat_id       = 'Bakır01'
      mat_type     = 'Ürün'
      mat_group    = 'Hammadde'
      description  = 'Bakır'
      weight       = 100
      weight_unit  = 'KG'
      safety_stock = 100
      base_uom     = 'KG'
      net_price    = 100
      waers        = 'TRY' ).
  ENDMETHOD.

ENDCLASS.
