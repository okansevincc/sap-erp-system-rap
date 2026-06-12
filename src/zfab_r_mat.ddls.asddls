@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material /Product Root /Restricted View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'MatId' ]
@Search.searchable: true
define root view entity ZFAB_R_MAT as select from zfab_t_mat
{
    key mat_uuid as MatUuid,
    @Search.defaultSearchElement: true
    mat_id as MatId,
    mat_type as MatType,
    mat_group as MatGroup,
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    description as Description,
    @Semantics.quantity.unitOfMeasure: 'WeightUnit'
    weight as Weight,
    weight_unit as WeightUnit,
    @Semantics.quantity.unitOfMeasure: 'BaseUom'
    safety_stock as SafetyStock,
    base_uom as BaseUom,
    @Semantics.amount.currencyCode: 'Waers'
    net_price as NetPrice,
    waers as Waers,
    
    //Admin Information
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt

}
