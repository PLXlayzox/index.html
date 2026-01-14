SELECT
    oitem.ord_id,
	ord.basket_id,
    oitem.basket_id
FROM
    t_ord_order AS ord 
    INNER JOIN  t_ord_basket AS bsk ON ord.basket_id = bsk.basket_id
    INNER JOIN t_ord_item AS oitem ON oitem.ord_id = ord.ord_id
WHERE
    ord.basket_id <> oitem.basket_id