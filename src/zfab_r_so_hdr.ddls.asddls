@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Data Definition'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'SoId' ]
define root view entity ZFAB_R_SO_HDR as select from zfab_t_so_hdr
association[1..1] to ZFAB_R_BP as _BussinesPartner on $projection.CustomerUuid = _BussinesPartner.BpUuid
composition[0..*] of ZFAB_R_SO_ITM as _SalesItems
{
    key so_uuid as SoUuid,
    @Search.defaultSearchElement: true
    so_id as SoId,
    customer_uuid as CustomerUuid,
    status as Status,
    @Semantics.amount.currencyCode: 'Waers'
    total_amount as TotalAmount,
    waers as Waers,
    
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
    
    //Association
    _BussinesPartner,
    _SalesItems
}
