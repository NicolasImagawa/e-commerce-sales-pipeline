{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key="id",
        database=target.database
    )
}}

WITH max_timestamp AS (SELECT CURRENT_TIMESTAMP AS load_timestamp)
,new_data AS (
    SELECT  fulfilled, 
            expiration_date, 
            shipping__id, 
            date_closed, id, 
            date_last_updated, 
            last_updated, 
            coupon__amount, 
            date_created, 
            buyer__id, 
            buyer__nickname, 
            seller__id, 
            seller__nickname, 
            total_amount, 
            paid_amount, 
            currency_id, 
            status, 
            context__channel, 
            context__site, 
            _dlt_load_id, 
            _dlt_id, 
            cancel_detail__group, 
            cancel_detail__code, 
            cancel_detail__description, 
            cancel_detail__requested_by, 
            cancel_detail__date, 
            cancel_detail__application_id, 
            pack_id, 
            taxes__amount, 
            taxes__currency_id, 
            feedback__purchase__date_created, 
            feedback__purchase__fulfilled, 
            feedback__purchase__rating, 
            feedback__purchase__id, 
            feedback__purchase__status, 
            feedback__buyer__id,
            max_timestamp.load_timestamp
        FROM {{ source("entry_ml", "entry_mercadolivre") }}, max_timestamp

        {% if is_incremental() %}
            WHERE max_timestamp.load_timestamp > (SELECT MAX(load_timestamp ) FROM {{this}})
        {% endif %}
), update_data AS (
    SELECT * 
    FROM new_data
    {% if is_incremental() %}
        WHERE id IN (SELECT id FROM {{this}})
    {% endif %}
), insert_data AS (
    SELECT * 
    FROM new_data
    {% if is_incremental() %}
        WHERE id NOT IN (SELECT id FROM update_data)
    {% endif %}
) 
SELECT * FROM update_data
UNION
SELECT * FROM insert_data
