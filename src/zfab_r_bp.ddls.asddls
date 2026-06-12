@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bussines Partner Root / Restricted View'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'BpId' ]
define root view entity ZFAB_R_BP as select from zfab_t_bp
{
    key bp_uuid as BpUuid,
    @Search.defaultSearchElement: true
    bp_id as BpId,
    bp_role as BpRole,
    @Search.defaultSearchElement: true
    company_name as CompanyName,
    tax_number as TaxNumber,
    tax_office as TaxOffice,
    
    //Contact Information
    @Semantics.telephone.type: [#CELL]
    phone as Phone,
    @Semantics.eMail.address: true
    email as Email,
    
    //Address Information
    @Semantics.address.country: true
    @EndUserText.label: 'Ülke'
    country as Country,
    @Semantics.address.city: true
    @EndUserText.label: 'Şehir'
    city as City,
    @EndUserText.label: 'İlçe'
    district as District,
    @EndUserText.label: 'Mahalle'
    @Semantics.address.street: true
    neighborhood as Neighborhood,
    @EndUserText.label: 'Adres Detayı'
    @UI.multiLineText: true
    addr_detail as AddrDetail,
    @Semantics.address.zipCode: true
    postal_code as PostalCode,
    
    concat_with_space( concat_with_space(neighborhood, addr_detail, 1), concat_with_space(concat_with_space(city,district,1),country,1),1) as FullAddress,
    
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
