--D619148
SELECT 
bsk.bsk_code_calculated,
bsk.basket_label_!$ AS basket_label,
bsktyp.btype_label_!$ AS bsktyp,
bsk._bsk_project_id AS project_id,
status.status_label_!$ AS status,
orga.orga_node+' - '+orga.orga_label_!$ AS organization,
contact.contact_firstname+' '+contact.contact_lastname AS requester,
cProcSpe.contact_firstname+' '+cProcSpe.contact_lastname AS proc_specialist,
bsk.created,
blogpr.blog_text 'internal_PR_comment',
CASE WHEN bsk._bsk_is_exemption = 1 THEN 'Yes' ELSE 'No' END AS is_recovery,
oitem.oitem_id,
oitem.oitem_seq,
oitem.oitem_ext_code ,
oitem.oitem_label,
oitem.oitem_quantity,
ISNULL(oitem.oitem_delivery_date,oitem.oitem_end_date) as delivery_date,
oiPO.oitem_delivery_free AS final_delivery,
oiPO._oitem_final_invoice AS final_invoice,
pdt.pdt_code,
pdt.pdt_label_en AS 'short_desc',
fam.dom_code AS 'Commodity',
sup.sup_code_calculated,
sup.sup_code, 
sup.sup_name_!$ AS sup_name,
COALESCE(oiPO.unit_code, oitem.unit_code) AS unit_code,
wbs._wbs_code AS wbs_code,
cce._cce_sap_code AS cce_code,
iorde._iorde_code AS iorde_code,
COALESCE(wbs._farea_code, cce._farea_code, iorde._farea_code) AS farea_code,
pcent._pcent_code AS profit_center,
oitem.oitem_price_entry oitem_price_entry ,
oitem.oitem_total_amount oitem_total_amount,
oitem.unit_code_currency unit_code_currency,
oitem.oitem_price_entry * 1/case when oitem.unit_code_currency='EUR' then 1 else unitcnv.conv_coeff end oitem_price_entry_lc ,
oitem.oitem_total_amount * 1/case when oitem.unit_code_currency='EUR' then 1 else unitcnv.conv_coeff end oitem_total_amount_lc,
ord.ord_code_calculated,
ord.ord_ext_code,
status_ord.status_label_!$ order_status,
oiPO.oitem_quantity AS po_line_quantity,
oiPO.oitem_total_amount AS po_line_amount,
oiPO.oitem_ext_code AS po_sap_line,
ord.created AS POcreated,
'EUR' local_curr,
oiPO.oitem_total_amount * 1/case when oiPO.unit_code_currency='EUR' then 1 else unitcnv.conv_coeff end AS po_line_amount_lc,
ctr.ctr_code_calculated+' - '+ctr.ctr_label_!$ AS contract,
CASE
  WHEN ISNULL(getGRAmount.total,0) > 0 AND ISNULL(oiPO.oitem_delivered_in_amount,0) = 1 THEN 'Amount'
  WHEN ISNULL(getGRAmount.total,0) > 0 AND ISNULL(oiPO.oitem_delivered_in_amount,0) = 0 THEN 'Quantity'
  ELSE NULL
  END AS receipt_mode,
oiPO.oitem_quantity * getGRAmount.total / oiPO.oitem_total_amount AS quantity_receipt,
getGRAmount.total AS amount_receipt,
getGRAmount.total * 1/case when oitem.unit_code_currency='EUR' then 1 else unitcnv.conv_coeff end AS amount_receipt_lc ,
oiPO.oitem_quantity * getInvAmount.total / oiPO.oitem_total_amount AS quantity_invoiced,
getInvAmount.total AS amount_invoiced,
getInvAmount.total * 1/case when oitem.unit_code_currency='EUR' then 1 else unitcnv.conv_coeff end AS amount_invoiced_lc 
,blog.blog_text 'internal_PO_comment',
oiPO.oitem_delivery_free



FROM t_ord_basket AS bsk

 -- Basket Type
 INNER JOIN t_ord_basket_type AS bsktyp ON bsktyp.btype_code=bsk.btype_code
 
--Get the organization information
LEFT JOIN x_orga_all AS orga ON orga.orga_id = bsk.orga_id

--Get the requester
LEFT JOIN t_usr_contact AS contact ON contact.contact_id = bsk.contact_id

--Get the PR status
LEFT JOIN t_bas_status AS status ON status.status_code = bsk.status_code AND status.tdesc_name = 't_ord_basket'

--Get the line information
LEFT JOIN t_ord_item AS oitem ON oitem.basket_id = bsk.basket_id AND oitem.ord_id IS NULL AND oitem.status_code <>'del'

--Get the supplier
LEFT JOIN t_sup_supplier AS sup ON sup.sup_id = oitem.sup_id

--Get the product AND material information
LEFT JOIN t_pdt_item AS pitem ON pitem.item_id = oitem.item_id
LEFT JOIN t_pdt_product AS pdt ON pdt.pdt_id = pitem.pdt_id
LEFT JOIN x_fam_all fam ON fam.fam_level=pdt.fam_level AND fam.fam_node=pdt.fam_node
--Get allocation information
LEFT JOIN t_ord_cost_center AS cce ON cce.cce_code = oitem._cce_code
LEFT JOIN t_ord_wbs_ AS wbs ON wbs._wbs_code = oitem._wbs_code
LEFT JOIN t_ord_internal_orders_ AS iorde ON iorde._iorde_code = oitem._iorde_code
--D658443 Add the profit center defined for each allocation axis
LEFT JOIN t_ord_profit_center_ AS pcent ON pcent._pcent_code = COALESCE(cce._pcent_code, wbs._pcent_code, iorde._pcent_code)

--Get the conversion rate
left JOIN t_bas_unit_conversion AS unitcnv ON unitcnv.unit_code_from='EUR' 
AND unitcnv.unit_code_to =oitem.unit_code_currency 
AND unitcnv.perio_level='m' 
AND unitcnv.perio_node=month(oitem.created) 
AND unitcnv.year_id=year(oitem.created)


--Get the link PO
LEFT JOIN t_ord_item AS oiPO ON oiPO.oitem_id_from = oitem.oitem_id
LEFT JOIN t_ord_order AS ord ON ord.ord_id = oiPO.ord_id
LEFT JOIN t_bas_status AS status_ord ON status_ord.status_code = ord.status_code AND status_ord.tdesc_name = 't_ord_order'

--Get the Contract information
LEFT JOIN t_ctr_contract AS ctr ON ctr.ctr_id = COALESCE (oitem.ctr_id, oiPO.ctr_id)

--Get the Good Receipt amount
OUTER APPLY (
  SELECT
  SUM(CASE WHEN deliv.delivtype_code = 'ret' THEN -delitm.ditem_quantity*delitm.ditem_price_entry ELSE delitm.ditem_quantity*delitm.ditem_price_entry END) AS total
  FROM t_ord_delivery_item AS delitm
  INNER JOIN t_ord_delivery AS deliv ON deliv.deliv_id = delitm.deliv_id
  WHERE delitm.oitem_id = oiPO.oitem_id
--  AND deliv.status_code NOT IN ('del', 'can')
AND deliv.status_code = 'end'
) AS getGRAmount

--Get the Invoice amount
OUTER APPLY (
  SELECT
  SUM(CASE WHEN inv.invtype_code = 'CRE' THEN - COALESCE(tax_iitem_.iitem_tax_taxable_amount, iitem.iitem_total_price_entry) ELSE COALESCE(tax_iitem_.iitem_tax_taxable_amount, iitem.iitem_total_price_entry) END ) AS total
  FROM t_ord_invoice_item AS iitem
LEFT JOIN t_ord_invoice_item_tax tax_iitem_ ON iitem.iitem_id = tax_iitem_.iitem_id
  INNER JOIN t_ord_invoice AS inv ON inv.invoice_id = iitem.invoice_id AND inv.status_code<>'del'
  WHERE iitem.oitem_id = oiPO.oitem_id
--  AND inv.status_code NOT IN ('can', 'del', 'imp')
) AS getInvAmount

--D658443 Add the name of the user who validated the Procurement Specialist step
LEFT JOIN t_wfl_worklist AS wli ON wli.tdesc_name = 't_ord_basket' AND wli.x_id = bsk.basket_id AND wli.act_code = 'PROC_SPE' AND wli.wli_date_val IS NOT NULL
LEFT JOIN t_usr_contact AS cProcSpe ON cProcSpe.contact_id = wli.contact_id_performer

--Filter ON the connected user orga scope
INNER JOIN t_usr_login AS lconn ON lconn.login_name = @login_name
INNER JOIN t_org_contact_perimeter AS ctcper ON ctcper.contact_id = lconn.contact_id AND ctcper.orga_id = orga.orga_id
--PO internal comment blog
LEFT JOIN (  SELECT test.*,blog.blog_text FROM t_ctn_blog AS blog 
INNER JOIN (
SELECT blog.x_id, max(blog.blog_date) dateb, ord.ord_id
FROM 
t_ord_order AS ord

INNER JOIN t_ctn_blog AS blog ON x_id='t_ord_order'+';'+cast(ord.ord_id AS varchar(12)) AND otype_code='workflow'
GROUP BY blog.x_id, ord.ord_id) test ON test.x_id=blog.x_id AND test.dateb=blog.blog_date 
) AS blog ON blog.ord_id=ord.ord_id

--PR internal comment blog
LEFT JOIN (  SELECT test.*,blog.blog_text FROM t_ctn_blog AS blog 
INNER JOIN (
SELECT blog.x_id, max(blog.blog_date) dateb, bsk.basket_id
FROM 
t_ord_basket AS bsk

INNER JOIN t_ctn_blog AS blog ON x_id='t_ord_basket'+';'+cast(bsk.basket_id AS varchar(12)) AND otype_code='workflow'
GROUP BY blog.x_id, bsk.basket_id) test ON test.x_id=blog.x_id AND test.dateb=blog.blog_date 
) AS blogpr ON blogpr.basket_id=bsk.basket_id


WHERE bsk.status_code NOT IN('del','ini') 
--
AND  (bsk._bsk_season_code <> deliv._deliv_season_code 
      or (bsk._bsk_season_code = deliv._deliv_season_code 
      and deliv._deliv_season_code <> wbs._seas_code))
      AND (( EXISTS (SELECT 1 FROM @st_code AS status WHERE status.MY_VALUE =bsk.status_code))
      OR 
      (NOT EXISTS (SELECT 1 FROM  @st_code AS status)))
		  and
	 (	 (EXISTS (SELECT 1 FROM @orga AS orga_param WHERE orga_param.MY_VALUE = orga.orga_level AND orga_param.MY_VALUE_1 = orga.orga_node))

        OR 

        NOT EXISTS (SELECT 1 FROM @orga AS orga_param))
		AND (( EXISTS (SELECT 1 FROM @dom_code AS dom_param WHERE '0'+cast(dom_param.MY_VALUE_1 AS varchar) =fam.dom_code ))
        OR 
        NOT EXISTS (SELECT 1 FROM  @dom_code AS dom))

		AND (@del_final IS null OR oiPO.oitem_delivery_free=@del_final)
			AND
		 (  (EXISTS (SELECT 1 FROM @order_status AS order_status WHERE order_status.MY_VALUE =status_ord.status_code))
        OR 
        NOT EXISTS (SELECT 1 FROM  @order_status AS order_status))
		AND
		 (  (EXISTS (SELECT 1 FROM @farea AS farea WHERE farea.MY_VALUE = COALESCE(wbs._farea_code, cce._farea_code, iorde._farea_code)))
        OR 
        NOT EXISTS (SELECT 1 FROM  @farea AS farea))
		AND
		 (  (EXISTS (SELECT 1 FROM @all_wbs AS all_wbs WHERE all_wbs.MY_VALUE =wbs._wbs_code))
        OR 
        NOT EXISTS (SELECT 1 FROM  @all_wbs AS all_wbs))
		AND
	 (  (EXISTS (SELECT 1 FROM @all_iord AS all_iord WHERE all_iord.MY_VALUE =iorde._iorde_code))
     OR 
        NOT EXISTS (SELECT 1 FROM  @all_iord AS all_iord))

		AND
		 (  (EXISTS (SELECT 1 FROM @all_cce AS all_cce WHERE all_cce.MY_VALUE =cce.cce_code))
       OR 
        NOT EXISTS (SELECT 1 FROM  @all_cce AS all_cce))
		AND (bsk.created >=  @created_from OR @created_from IS null) AND (bsk.created <=  @created_to OR @created_to IS null)
		AND (ord.created >=  @POcreated_from OR @POcreated_from IS null) AND (ord.created <=  @POcreated_to OR @POcreated_to IS null)
		AND (ISNULL(oitem.oitem_delivery_date,oitem.oitem_end_date) >=  @del_date_from OR @del_date_from IS null) AND (ISNULL(oitem.oitem_delivery_date,oitem.oitem_end_date) <=  @del_date_to OR @del_date_to IS null)
			AND
		 (  (EXISTS (SELECT 1 FROM @pcenter AS pcenter WHERE pcenter.MY_VALUE =pcent._pcent_code))
       OR 
        NOT EXISTS (SELECT 1 FROM  @pcenter AS pcenter))
		AND
		 (  (EXISTS (SELECT 1 FROM @btype_code AS btype WHERE btype.MY_VALUE =bsktyp.btype_code))
     OR 
   NOT EXISTS (SELECT 1 FROM  @btype_code AS btype_code))