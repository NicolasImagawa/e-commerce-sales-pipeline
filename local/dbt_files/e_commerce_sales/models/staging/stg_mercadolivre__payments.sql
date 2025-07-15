{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key="load_id",
        database=target.database
    )
}}

WITH max_timestamp AS (SELECT CURRENT_TIMESTAMP AS load_timestamp)
, new_data AS (
    SELECT  CONCAT(id, payment_method_id) AS load_id,
            reason,
            total_paid_amount, 
            transaction_amount,
            date_approved,
            id,
            shipping_cost,
            date_created,
            payment_method_id,
            order_id,
            status,
            _dlt_parent_id,
            _dlt_list_idx,
            _dlt_id,
            installment_amount,
            max_timestamp.load_timestamp
        FROM {{ source("entry_ml", "entry_mercadolivre__payments") }}, max_timestamp
        {% if is_incremental() %}

            WHERE max_timestamp.load_timestamp > (SELECT MAX(load_timestamp) FROM {{this}})

        {% endif %}
) SELECT * FROM new_data