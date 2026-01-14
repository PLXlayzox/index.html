WITH
    BASKET AS (
        SELECT
            oitem.oitem_delivery_date,
            deliv.deliv_date,
            oitem.basket_id,
            oitem.oitem_id
        FROM
            t_ord_item AS oitem
            INNER JOIN t_ord_delivery_item AS delitm ON delitm.oitem_id = oitem.oitem_id
            INNER JOIN t_ord_delivery AS deliv ON delitm.deliv_id = deliv.deliv_id
        WHERE
            EXISTS (
                SELECT
                    1
                FROM
                    t_ord_season_ AS seas
                WHERE
                    (
                        oitem.oitem_delivery_date BETWEEN seas._seas_start_date AND seas._seas_end_date
                    )
                    AND (
                        deliv.deliv_date BETWEEN seas._seas_start_date AND seas._seas_end_date
                    )
                    -- A améliorer 
                    -- AND seas._seas_code = '2425'
                    
                    AND 
            )
    ),
    WBS AS (
        SELECT
            wbs._seas_code,
            wbs._wbs_code
        FROM
            t_ord_wbs_ AS wbs
            INNER JOIN t_ord_season_ AS seas ON seas._seas_code = wbs._seas_code
    )
SELECT
    bsk.*,
    wbs.*
FROM
    BASKET AS bsk
    INNER JOIN t_ord_item AS oitem ON oitem.oitem_id = bsk.oitem_id
    INNER JOIN WBS AS wbs ON wbs._wbs_code = oitem._wbs_code





    

/*WITH
    BASKET AS (
        SELECT
            oitem.oitem_delivery_date,
            deliv.deliv_date,
            oitem.basket_id,
            oitem.oitem_id
        FROM
            t_ord_item AS oitem
            INNER JOIN t_ord_delivery_item AS delitm ON delitm.oitem_id = oitem.oitem_id
            INNER JOIN t_ord_delivery AS deliv ON delitm.deliv_id = deliv.deliv_id
        WHERE
            EXISTS (
                SELECT
                    1
                FROM
                    t_ord_season_ AS seas
                WHERE
                    (
                        oitem.oitem_delivery_date BETWEEN seas._seas_start_date AND seas._seas_end_date
                    )
                    AND (
                        deliv.deliv_date BETWEEN seas._seas_start_date AND seas._seas_end_date
                    )
                    -- A améliorer
                    AND seas._seas_code = '2425'
            )
    ),
    WBS AS (
        SELECT
            wbs._seas_code,
            wbs._wbs_code
        FROM
            t_ord_wbs_ AS wbs
            INNER JOIN t_ord_season_ AS seas ON seas._seas_code = wbs._seas_code
    )
SELECT
    bsk.*,
    wbs.*
FROM
    BASKET AS bsk
    INNER JOIN t_ord_item AS oitem ON oitem.oitem_id = bsk.oitem_id
    INNER JOIN WBS AS wbs ON wbs._wbs_code = oitem._wbs_code*/