@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Consumption View'
@Metadata.allowExtensions: true
define view entity ZFAB_C_SO_ITM as projection on ZFAB_R_SO_ITM
{
    key SoItmUuid,
    SoUuid,
    ItemPos,
    @ObjectModel.text.element: [ 'MatId' ]
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
    
    //Associations
    _Product : redirected to ZFAB_C_MAT,
    _Sales : redirected to parent ZFAB_C_SO_HDR,
    _Product.MatId as MatId
}
