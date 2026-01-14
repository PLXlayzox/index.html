SELECT
  sup.sup_name_en AS 'supplier_name',
  sup.status_code,
  sup.sup_corp_name_en AS 'legal_name',
  CONCAT(
    contact.contact_firstname,
    ' ',
    contact.contact_lastname,
    ': ',
    grpcontact.role_code
  ) AS 'ContactInfo',
  -- contact.contact_firstname AS 'contact firstname',
  -- contact.contact_lastname AS 'contact lastname',
  --  contact.contact_email AS 'contact email',
  GetContactList.list,
  -- contact.contact_function_en AS 'contact function',
  adr.adr_voie AS 'adresseLigne1',
  adr.adr_voie_complt AS 'adresseLigne2',
  adr.zip_label_en AS 'ville',
  (select 
  bi.bi_iban as 'iban',
  country.country_label_en AS 'banking_country',
  bi.bi_bic_code AS 'SWIFT',
  case
    bi.bi_default
    when 1 then 'is_default'
    when 0 then 'is_not_default'
    when null then 'is_not_default'
  end AS 'is_default',
  bi.bi_payee_name AS 'name_ON_account',
  bi.unit_code_currency AS 'currency',
  bi.bi_order_bank as 'bank_name'
   FROM t_buy_banking_information AS bi
   INNER JOIN t_bas_country AS country ON bi.country_code = country.country_code
   WHERE bi.sup_id = sup.sup_id
    AND bi.bi_iban IS NOT null
FOR XML PATH ('Banking_information'), TYPE
  ) AS 'Banking_informations' 
   
FROM
  t_sup_supplier AS sup -- link for contact
  LEFT JOIN t_usr_contact_group AS grpcontact ON sup.grp_id = grpcontact.grp_id
  LEFT JOIN t_usr_contact AS contact ON grpcontact.contact_id = contact.contact_id
  OUTER APPLY (
    SELECT
      STRING_AGG(ctc.contact_email, ';') AS list
    FROM
      t_usr_contact AS ctc
      INNER JOIN t_usr_contact_group AS gc ON gc.contact_id = ctc.contact_id
    WHERE
      sup.grp_id = gc.grp_id
  ) AS GetContactList -- link for legacy
  LEFT JOIN t_sup_legacy AS lega ON lega.sup_id = sup.sup_id -- link for adress
  LEFT JOIN t_bas_address AS adr ON sup.adr_id_office = adr.adr_id --link for banking information
  LEFT JOIN t_buy_banking_information as bi on sup.sup_id = bi.sup_id --link for country code
  
WHERE
  sup.status_code NOT IN('del', 'ini') 
AND bi.bi_iban IS NOT NULL
FOR XML PATH('supplier'), ROOT('suppliers')