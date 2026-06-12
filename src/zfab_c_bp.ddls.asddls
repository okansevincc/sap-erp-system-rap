@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Partner Consumption View'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'BpId' ]
define root view entity ZFAB_C_BP 
  provider contract transactional_query
  as projection on ZFAB_R_BP
{
    key BpUuid,  
      
    @Search.defaultSearchElement: true
    BpId,   
    BpRole,  
    
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    CompanyName,   
    TaxNumber,
    TaxOffice,
    Phone,
    Email,
    
    @Search.defaultSearchElement: true
    Country,
    City,
    District,
    Neighborhood,
    AddrDetail,
    PostalCode,
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    LocalLastChangedAt 
}
