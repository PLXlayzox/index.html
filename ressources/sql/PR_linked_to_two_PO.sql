SELECT
    i.basket_id,
    count(oitem.ord_id) 
FROM
    t_ord_basket AS i --PR 
    INNER JOIN t_ord_order AS ord ON ord.basket_id = i.basket_id
    INNER JOIN t_ord_item AS oitem ON oitem.basket_id = i.basket_id
group by
    i.basket_id
having
    count(oitem.ord_id) > 1

    