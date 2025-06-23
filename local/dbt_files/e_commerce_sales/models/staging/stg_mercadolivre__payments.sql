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
            operation_type, 
            transaction_amount, 
            transaction_amount_refunded, 
            date_approved, 
            collector__id, 
            installments, 
            taxes_amount, 
            id, 
            date_last_modified, 
            coupon_amount, 
            shipping_cost, 
            date_created, 
            overpaid_amount, 
            status_detail, 
            issuer_id, 
            payment_method_id, 
            payment_type, 
            atm_transfer_reference__company_id, 
            site_id, 
            payer_id, 
            order_id, 
            currency_id, 
            status, 
            _dlt_parent_id, 
            _dlt_list_idx, 
            _dlt_id, 
            transaction_amount_refunded__v_double, 
            authorization_code, 
            installment_amount, 
            card_id, 
            shipping_cost__v_double, 
            atm_transfer_reference__transaction_id, 
            activation_uri,
            max_timestamp.load_timestamp
        FROM {{ source("entry_ml", "entry_mercadolivre__payments") }}, max_timestamp
        {% if is_incremental() %}

            WHERE max_timestamp.load_timestamp > (SELECT MAX(load_timestamp) FROM {{this}})

        {% endif %}
), update_data AS (
    SELECT * 
    FROM new_data
    {% if is_incremental() %}
        WHERE load_id IN (SELECT load_id FROM {{this}})
    {% endif %}
), insert_data AS (
    SELECT * 
    FROM new_data
    {% if is_incremental() %}
        WHERE load_id NOT IN (SELECT load_id FROM update_data)
    {% endif %}
) 
SELECT * FROM update_data
UNION
SELECT * FROM insert_data