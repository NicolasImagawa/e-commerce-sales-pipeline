{{
    config(
        materialized='incremental',
        unique_key='date_id',
        incremental_strategy='merge'
    )
}}

WITH new_data AS (
    SELECT orders_results.date_id,
           stg_shopee.data_de_criacao_do_pedido AS date_created,
           stg_shopee.hora_do_pagamento_do_pedido AS date_approved,
           EXTRACT( YEAR FROM stg_shopee.hora_do_pagamento_do_pedido ) AS year_approved,
           EXTRACT( MONTH FROM stg_shopee.hora_do_pagamento_do_pedido ) AS month_approved,
           EXTRACT( DAY FROM stg_shopee.hora_do_pagamento_do_pedido ) AS day_approved,
           stg_shopee.hora_completa_do_pedido AS date_delivered,
           EXTRACT( YEAR FROM stg_shopee.hora_completa_do_pedido ) AS year_delivered,
           EXTRACT( MONTH FROM stg_shopee.hora_completa_do_pedido ) AS month_delivered,
           EXTRACT( DAY FROM stg_shopee.hora_completa_do_pedido ) AS day_delivered,
           stg_shopee.load_timestamp AS ld_timestamp
        FROM {{ ref("shopee_orders_results") }} AS orders_results,
             {{ ref("shopee_new_id") }} AS shopee_new_id,
             {{ source("entry_shopee", "stg_shopee") }} AS stg_shopee
        WHERE orders_results.main_id = shopee_new_id.main_id
        AND shopee_new_id.id_do_pedido = stg_shopee.id_do_pedido

        {% if is_incremental() %}

            AND ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

        {% endif %}

), update_data AS (
        SELECT  date_id,
                date_created,
                date_approved,
                year_approved,
                month_approved,
                day_approved,
                date_delivered,
                year_delivered,
                month_delivered,
                day_delivered,
                ld_timestamp
        FROM new_data

    {% if is_incremental() %}

        where date_id IN (SELECT date_id FROM {{ this }})

    {% endif %}

), insert_data AS (
        SELECT  date_id,
                date_created,
                date_approved,
                year_approved,
                month_approved,
                day_approved,
                date_delivered,
                year_delivered,
                month_delivered,
                day_delivered,
                ld_timestamp
        FROM new_data
        WHERE date_id NOT IN (SELECT date_id FROM update_data)
) SELECT update_data.date_id,
         update_data.date_created,
         update_data.date_approved,
         update_data.year_approved,
         update_data.month_approved,
         update_data.day_approved,
         update_data.date_delivered,
         update_data.year_delivered,
         update_data.month_delivered,
         update_data.day_delivered,
         update_data.ld_timestamp
    FROM update_data
    UNION
SELECT insert_data.date_id,
       insert_data.date_created,
       insert_data.date_approved,
       insert_data.year_approved,
       insert_data.month_approved,
       insert_data.day_approved,
       insert_data.date_delivered,
       insert_data.year_delivered,
       insert_data.month_delivered,
       insert_data.day_delivered,
       insert_data.ld_timestamp
    FROM insert_data