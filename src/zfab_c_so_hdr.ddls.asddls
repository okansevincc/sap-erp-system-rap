@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Consumption View'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'SoId' ]
define root view entity ZFAB_C_SO_HDR provider contract transactional_query as projection on ZFAB_R_SO_HDR
{
    key SoUuid,
    @Search.defaultSearchElement: true
    SoId,
    @ObjectModel.text.element: [ 'CompanyName' ]
    @UI.textArrangement: #TEXT_ONLY
    CustomerUuid,
    Status,
    TotalAmount,
    Waers,
    
    //Admin Data
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    LocalLastChangedAt,
    
    //Associations
    _BussinesPartner : redirected to ZFAB_C_BP,
    _SalesItems : redirected to composition child ZFAB_C_SO_ITM,
    _BussinesPartner.CompanyName as CompanyName
}
