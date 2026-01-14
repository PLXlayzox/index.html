/*
tables :
t_bas_address
t_usr_contact
t_sup_supplier
t_sup_legacy


*/
SELECT 
  --sup.sup_id,
  sup.sup_name_en AS 'supplier name',
  styp.styp_label_en AS 'type',
  status.status_label_en AS 'supplier status',
  sup.sup_corp_name_en AS 'legal name',
  contact.contact_firstname AS 'contact firstname',
  contact.contact_lastname AS 'contact lastname',
  contact.contact_email AS 'contact email',
  role.role_label_en AS 'role',
  status1.status_label_en AS 'contact status',
  adr.adr_voie AS 'adresseLigne 1',
  adr.adr_voie_complt AS 'adresseLigne 2',
  adr.zip_code AS 'ZIP code',
  adr.zip_label_en AS 'ville',
  country.country_label_en AS 'pays'
  
FROM t_sup_supplier AS sup
-- link for contact
LEFT  JOIN t_usr_contact_group AS grpcontact ON sup.grp_id = grpcontact.grp_id
LEFT JOIN t_usr_contact AS contact ON  grpcontact.contact_id = contact.contact_id
outer apply(
  select 
  contact.contact_firstname ,
  contact.contact_lastname,
  contact.contact_email,
  role.role_label_en
  from
  LEFT  JOIN t_usr_contact_group AS grpcontact ON sup.grp_id = grpcontact.grp_id
  LEFT JOIN t_usr_contact AS contact ON  grpcontact.contact_id = contact.contact_id
  LEFT JOIN t_usr_role AS role ON grpcontact.role_code = role.role_code)
-- link for legacy
LEFT  JOIN t_sup_legacy AS lega ON  lega.sup_id = sup.sup_id
-- link for adress
LEFT  JOIN t_bas_address AS adr ON  sup.adr_id_office = adr.adr_id
--link for contry
LEFT JOIN t_bas_country AS country ON adr.country_code = country.country_code
--link for role
LEFT JOIN t_usr_role AS role ON grpcontact.role_code = role.role_code
--link for type
LEFT JOIN t_sup_supplier_type AS styp ON sup.styp_code = styp.styp_code
--link for status
LEFT JOIN t_bas_status AS status ON sup.status_code = status.status_code AND status.tdesc_name = 't_sup_supplier'
LEFT JOIN t_bas_status AS status1 ON contact.status_code = status1.status_code AND status1.tdesc_name = 't_usr_contact'
WHERE 
sup.status_code NOT IN('del','ini')


;SELECT 

  sup.sup_name_en AS 'supplier name',

  sup.status_code,

  sup.sup_corp_name_!$ AS 'legal name',

  CONCAT(contact.contact_firstname, ' ', contact.contact_lastname, ': ', grpcontact.role_code) AS 'ContactInfo',

-- contact.contact_firstname AS 'contact firstname',

-- contact.contact_lastname AS 'contact lastname',

--  contact.contact_email AS 'contact email',

  GetContactList.list, 

-- contact.contact_function_en AS 'contact function',

  adr.adr_voie AS 'adresseLigne 1',

  adr.adr_voie_complt AS 'adresseLigne 2',

  adr.zip_label_en AS 'ville',

  bi.bi_iban as 'iban',
  
  country.country_label_en  AS 'banking country',
  
  bi.bi_bic_code AS 'SWIFT',
   
  case 
    when bi.bi_default = 1 then 'is default'
    when bi.bi_default = 0 then 'is not default'
    when bi.bi_default is null then 'is not default'
  end AS 'is default',
  
  bi.bi_payee_name AS 'name ON account',

  bi.unit_code_currency AS 'currency',

  bi.bi_order_bank as 'bank name'

FROM t_sup_supplier AS sup

-- link for contact

LEFT  JOIN t_usr_contact_group AS grpcontact ON sup.grp_id = grpcontact.grp_id

LEFT  JOIN t_usr_contact AS contact ON  grpcontact.contact_id = contact.contact_id

OUTER APPLY

(SELECT STRING_AGG(ctc.contact_email, ';') AS list

 FROM t_usr_contact AS ctc 

 INNER  JOIN t_usr_contact_group AS gc ON gc.contact_id = ctc.contact_id

 WHERE sup.grp_id = gc.grp_id

) AS GetContactList 

-- link for legacy

LEFT  JOIN t_sup_legacy AS lega ON  lega.sup_id = sup.sup_id

-- link for adress

LEFT  JOIN t_bas_address AS adr ON  sup.adr_id_office = adr.adr_id

--link for banking information

LEFT JOIN t_buy_banking_information as bi on sup.sup_id = bi.sup_id

--link for country code

LEFT JOIN t_bas_country AS country ON bi.country_code = country.country_code

WHERE 

sup.status_code NOT IN('del','ini')

FOR XML PATH('Supplier'), ROOT('Supplier'), TYPE