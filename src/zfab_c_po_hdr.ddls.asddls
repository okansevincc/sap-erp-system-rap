@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Header Consumption View'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'PoId' ]
define root view entity ZFAB_C_PO_HDR
  provider contract transactional_query as projection on ZFAB_R_PO_HDR
{
    key PoUuid,
    @Search.defaultSearchElement: true
    PoId,
    @ObjectModel.text.element: [ 'CompanyName' ]
    @UI.textArrangement: #TEXT_ONLY
    VendorUuid,
    Status,
    TotalAmount,
    Waers,
    
    //Admin Data
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    LocalLastChangedAt,
    
    /* Associations */
    _BussinesPartner :redirected to ZFAB_C_BP,
    _PurchaseItems : redirected to composition child ZFAB_C_PO_ITM,
    _BussinesPartner.CompanyName as CompanyName

}
