{{
    config(
        materialized='incremental',
        unique_key='main_id',
        incremental_strategy='merge'
    )
}}

WITH delivery_data AS (
    SELECT stg_shopee.load_id AS main_id,
           stg_shopee.status_do_pedido AS order_status,
           stg_shopee.status_da_devolucao___reembolso AS refund_status,
           stg_shopee.numero_de_rastreamento AS deliver_id,
           stg_shopee.opcao_de_envio AS delivery_company,
           stg_shopee.opcao_de_envio AS shipping_option,
           stg_shopee.load_timestamp AS ld_timestamp
        FROM {{ ref("stg_shopee") }} AS stg_shopee
        WHERE stg_shopee.status_da_devolucao___reembolso IS NULL
), new_data AS (
    SELECT  orders_results.main_id,
            delivery_data.order_status,
            delivery_data.refund_status,
            delivery_data.deliver_id,
            delivery_data.delivery_company,
            delivery_data.shipping_option,
            delivery_data.ld_timestamp
    FROM {{ ref('shopee_orders_results') }} AS orders_results
    LEFT JOIN delivery_data
        ON orders_results.main_id = delivery_data.main_id

    {% if is_incremental() %}

        WHERE delivery_data.ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

    {% endif %}
), update_data AS (
    SELECT  new_data.main_id,
            new_data.order_status,
            new_data.refund_status,
            new_data.deliver_id,
            new_data.delivery_company,
            new_data.shipping_option,
            new_data.ld_timestamp
    FROM new_data
    {% if is_incremental() %}

        WHERE new_data.main_id IN (SELECT main_id FROM {{ this }})

    {% endif %}
), insert_data AS (
    SELECT  new_data.main_id,
            new_data.order_status,
            new_data.refund_status,
            new_data.deliver_id,
            new_data.delivery_company,
            new_data.shipping_option,
            new_data.ld_timestamp
    FROM new_data
    {% if is_incremental() %}

        WHERE new_data.main_id NOT IN (SELECT main_id FROM update_data)

    {% endif %}
) 
SELECT update_data.main_id,
        update_data.order_status,
        update_data.refund_status,
        update_data.deliver_id,
        update_data.delivery_company,
        update_data.shipping_option,
        update_data.ld_timestamp
    FROM update_data
    UNION 
SELECT insert_data.main_id,
        insert_data.order_status,
        insert_data.refund_status,
        insert_data.deliver_id,
        insert_data.delivery_company,
        insert_data.shipping_option,
        insert_data.ld_timestamp
FROM insert_data