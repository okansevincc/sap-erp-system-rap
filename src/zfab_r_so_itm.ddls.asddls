@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Data Definition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFAB_R_SO_ITM as select from zfab_t_so_itm
association to parent ZFAB_R_SO_HDR as _Sales
    on $projection.SoUuid = _Sales.SoUuid
association[1..1] to ZFAB_R_MAT as _Product on $projection.MatUuid = _Product.MatUuid
{
    key so_itm_uuid as SoItmUuid,
    so_uuid as SoUuid,
    item_pos as ItemPos,
    mat_uuid as MatUuid,
    @Semantics.quantity.unitOfMeasure: 'UnitUom'
    quantity as Quantity,
    unit_uom as UnitUom,
    @Semantics.amount.currencyCode: 'Waers'
    unit_price as UnitPrice,
    waers as Waers,
    @Semantics.amount.currencyCode: 'Waers'
    total_price as TotalPrice,
    
    //Admin Data
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    
    //Associations
    _Sales,
    _Product
}
