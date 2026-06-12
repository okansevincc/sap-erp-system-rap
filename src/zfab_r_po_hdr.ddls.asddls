@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Header Data Definition'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'PoId' ]
define root view entity ZFAB_R_PO_HDR as select from zfab_t_po_hdr
association[1..1] to ZFAB_R_BP as _BussinesPartner on $projection.VendorUuid = _BussinesPartner.BpUuid
composition[0..*] of ZFAB_R_PO_ITM as _PurchaseItems
{
    key po_uuid as PoUuid,
    @Search.defaultSearchElement: true
    po_id as PoId,
    vendor_uuid as VendorUuid,
    status as Status,
    @Semantics.amount.currencyCode: 'Waers'
    total_amount as TotalAmount,
    waers as Waers,
    
    // Admin Data
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
    _BussinesPartner,
    _PurchaseItems
}
