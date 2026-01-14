update bsk
set bsk._bsk_season_code = CASE
  WHEN (month(bsk.created) between 1 and 6) AND (right(year(bsk.created),2) = right(wbs._seas_code,2)) 
  OR (month(bsk.created) between 7 and 12) AND (right(year(bsk.created),2)+1 = right(wbs._seas_code,2)) THEN  wbs._seas_code
  ELSE  'N/A'
END
FROM t_ord_basket as bsk
INNER JOIN t_ord_item AS oitem ON oitem.basket_id = bsk.basket_id
INNER JOIN t_ord_allocation AS alloc ON alloc.oitem_id = oitem.oitem_id
INNER JOIN t_ord_wbs_ AS wbs ON wbs._wbs_code = alloc._wbs_code
WHERE bsk.status_code <> 'del'
    and bsk.basket_id = 1231

;
update deliv
set deliv._deliv_season_code = 
CONCAT (
  CASE 
	WHEN (month(deliv.created) between 1 and 6) THEN (RIGHT(YEAR(deliv.created), 2)+1)
	WHEN (month(deliv.created) between 7 and 12) THEN (RIGHT(YEAR(deliv.created), 2))
	END ,
  CASE 
	WHEN (month(deliv.created) between 1 and 6) THEN RIGHT(YEAR(deliv.created), 2)
	WHEN (month(deliv.created) between 7 and 12) THEN (RIGHT(YEAR(deliv.created), 2)+1)
	END )
FROM t_ctr_contract as deliv
WHERE deliv.status_code <> 'del'
    and deliv.ctr_id = 129


-- after save deliv
;
IF( exists(select 1 
		  from t_ctr_contract as deliv
		 where deliv._deliv_season_code is NULL 
  		 and deliv.status_code <>'del'
		 and  deliv.ctr_id = @ctr_id))
begin
update deliv
set deliv._deliv_season_code = 
CONCAT (
  CASE 
	WHEN (month(deliv.created) between 1 and 6) THEN (RIGHT(YEAR(deliv.created), 2)+1)
	WHEN (month(deliv.created) between 7 and 12) THEN (RIGHT(YEAR(deliv.created), 2))
	END ,
  CASE 
	WHEN (month(deliv.created) between 1 and 6) THEN RIGHT(YEAR(deliv.created), 2)
	WHEN (month(deliv.created) between 7 and 12) THEN (RIGHT(YEAR(deliv.created), 2)+1)
	END )
FROM t_ctr_contract as deliv
WHERE deliv.ctr_id = @ctr_id
end

-- after save bsk
;
IF( exists(select 1 
		  from t_ord_basket as bsk
		 where bsk._bsk_season_code is NULL 
  		 and bsk.status_code <>'del'
		 and  bsk.basket_id = @basket_id))
begin
update bsk
set bsk._bsk_season_code = 
CONCAT (
  CASE
	WHEN (month(bsk.created) between 1 and 6) THEN RIGHT(YEAR(bsk.created), 2)
	WHEN (month(bsk.created) between 7 and 12) THEN (RIGHT(YEAR(bsk.created), 2)+1)
	END ,
  CASE 
	WHEN (month(bsk.created) between 1 and 6) THEN (RIGHT(YEAR(bsk.created), 2)+1)
	WHEN (month(bsk.created) between 7 and 12) THEN (RIGHT(YEAR(bsk.created), 2))
	END )
FROM t_ord_basket as bsk
WHERE bsk.basket_id = @basket_id
end


;
-- update date

update t_ctr_contract
set 
	ctr_signature_date = getdate()
where 
	ctr_id = @x_id



;

       DECLARE @t_del TABLE (
               ctr_id int,
               login_name varchar(128),
               process_code varchar(128)
)
 
DECLARE @t_pex TABLE (pex_id int,ctr_id int,process_code varchar(128))
 
INSERT INTO @t_del (ctr_id, login_name, process_code)
SELECT d.ctr_id, 'scheduler', 'check_cost'
FROM t_ctr_contract d
LEFT JOIN t_wfl_process_execution pe ON pe.tdesc_name='t_ctr_contract' AND pe.x_id=CAST(d.ctr_id AS varchar(128))
WHERE d.imp_id=@imp_id AND pe.process_code IS NULL
 
MERGE INTO dbo.t_wfl_process_execution AS [target]
USING (
    SELECT 'check_cost', ts.ctr_id , 't_ctr_contract', getdate(), l.contact_id
    FROM @t_del ts
    INNER JOIN t_usr_login l ON l.login_name='scheduler'
    WHERE ts.process_code IS NOT NULL  
) AS [source]
(process_code, ctr_id, tdesc_name, begin_date, contact_id_requester)
ON 1=0
WHEN NOT MATCHED THEN
    INSERT (process_code, x_id, tdesc_name, begin_date, contact_id_requester)
    VALUES ([source].process_code, CAST([source].ctr_id AS varchar(128)), [source].tdesc_name, [source].begin_date, [source].contact_id_requester)
    OUTPUT inserted.pex_id, [source].ctr_id, [source].process_code INTO @t_pex;

INSERT INTO t_wfl_worklist (process_code, x_id, tdesc_name, act_code,pex_id, act_id, contact_id_performer, wli_date_ini, contact_id_origin)
SELECT DISTINCT ts.process_code, CAST(ts.ctr_id AS varchar(128)), 't_ctr_contract', a.act_code, pex.pex_id, a.act_id, l.contact_id, getdate(), l.contact_id
FROM @t_del ts
INNER JOIN @t_pex pex ON pex.ctr_id = ts.ctr_id AND pex.process_code =ts.process_code
INNER JOIN t_wfl_activity a ON a.process_code=ts.process_code
INNER JOIN t_usr_login l ON l.login_name=ts.login_name
WHERE a.act_code = 'ini' AND ts.process_code ='check_cost'


;
select 1
from t_ctr_contract as ctr
inner join t_ctr_contract_perimeter AS ctrper on ctr.ctr_id = ctrper.ctr_id

--inner join t_usr_login_profil as usr on ctr.status_code = usr.status_code
where  = @login_name_current
and ctr_id=@ctr_id


;
t_ctr_contract_perimeter AS ctrper
t_usr_contact as contact

t_ctr_contract_perimeter AS ctrper et t_org_contact_perimeter AS ctcper avec orga_node et orga_level