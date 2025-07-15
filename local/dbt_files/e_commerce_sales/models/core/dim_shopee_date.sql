{{
    config(
        materialized='incremental',
        unique_key='date_id',
        incremental_strategy='merge',
        database=target.database
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
             {{ ref("stg_shopee") }} AS stg_shopee
        WHERE orders_results.main_id = stg_shopee.load_id

        {% if is_incremental() %}

            AND ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

        {% endif %}

)
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
