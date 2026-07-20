@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Item Data Definition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFAB_R_PO_ITM as select from zfab_t_po_itm
association to parent ZFAB_R_PO_HDR as _Purchase
    on $projection.PoUuid = _Purchase.PoUuid
association[1..1] to ZFAB_R_MAT as _Material on $projection.MatUuid = _Material.MatUuid
{
    key po_itm_uuid as PoItmUuid,
    po_uuid as PoUuid,
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
    _Purchase,
    _Material
}
