{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key="id",
        database=target.database
    )
}}

WITH max_timestamp AS (SELECT CURRENT_TIMESTAMP AS load_timestamp)
, new_data AS (
    SELECT  _dlt_load_id, 
            _dlt_id, 
            id,
            lead_time__cost, 
            lead_time__cost_type, 
            lead_time__list_cost,
            lead_time__currency_id,
            status,
            lead_time__estimated_delivery_time__date,
            lead_time__estimated_delivery_limit__date,
            lead_time__shipping_method__type,
            snapshot_packing__snapshot_id, 
            snapshot_packing__pack_hash, 
            last_updated, 
            date_created,
            destination__receiver_id, 
            destination__receiver_name, 
            destination__shipping_address__country__id, 
            destination__shipping_address__country__name, 
            destination__shipping_address__address_line, 
            destination__shipping_address__scoring, 
            destination__shipping_address__city__id, 
            destination__shipping_address__city__name, 
            destination__shipping_address__geolocation_type, 
            destination__shipping_address__latitude, 
            destination__shipping_address__address_id, 
            destination__shipping_address__location_id, 
            destination__shipping_address__street_name, 
            destination__shipping_address__zip_code,
            destination__shipping_address__comment,
            destination__shipping_address__geolocation_source, 
            destination__shipping_address__delivery_preference, 
            destination__shipping_address__street_number,
            destination__shipping_address__state__id, 
            destination__shipping_address__state__name, 
            destination__shipping_address__neighborhood__name, 
            destination__shipping_address__geolocation_last_updated, 
            destination__shipping_address__longitude, 
            destination__type, 
            destination__receiver_phone, 
            source__site_id, 
            source__market_place, 
            declared_value, 
            logistic__mode, 
            logistic__type, 
            logistic__direction, 
            priority_class__id,
            tracking_number,
            max_timestamp.load_timestamp
        FROM {{ source("entry_ml", "entry_mercadolivre_sh") }}, max_timestamp
        {% if is_incremental() %}

            WHERE max_timestamp.load_timestamp > (SELECT MAX(load_timestamp) FROM {{this}})

        {% endif %}
) SELECT * FROM new_data