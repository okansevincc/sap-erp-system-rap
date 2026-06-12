@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material / Product Consumption View'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'MatId' ]
define root view entity ZFAB_C_MAT provider contract transactional_query as projection on ZFAB_R_MAT
{
    key MatUuid,
    
    @Search.defaultSearchElement: true
    MatId,
    MatType,
    MatGroup,
    
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    Description,
    Weight,
    WeightUnit,
    SafetyStock,
    BaseUom,
    NetPrice,
    Waers,
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    LocalLastChangedAt
}
