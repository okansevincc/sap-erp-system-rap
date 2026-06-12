@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Item Consumption View'
@Metadata.allowExtensions: true
define view entity ZFAB_C_PO_ITM as projection on ZFAB_R_PO_ITM
{
    key PoItmUuid,
    PoUuid,
    ItemPos,
    @ObjectModel.text.element: [ 'MatDesc' ]
    @UI.textArrangement: #TEXT_ONLY
    MatUuid,
    Quantity,
    UnitUom,
    UnitPrice,
    Waers,
    
    //Admin Data
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    LocalLastChangedAt,
    
    /* Associations */
    _Material : redirected to ZFAB_C_MAT,
    _Purchase : redirected to parent ZFAB_C_PO_HDR,
    _Material.Description as MatDesc
}
