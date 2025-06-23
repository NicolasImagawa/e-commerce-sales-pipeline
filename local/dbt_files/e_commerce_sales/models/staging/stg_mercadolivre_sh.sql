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
            snapshot_packing__snapshot_id, 
            snapshot_packing__pack_hash, 
            last_updated, 
            date_created, 
            origin__shipping_address__country__id, 
            origin__shipping_address__country__name, 
            origin__shipping_address__address_line, 
            origin__shipping_address__scoring, 
            origin__shipping_address__city__id, 
            origin__shipping_address__city__name, 
            origin__shipping_address__geolocation_type, 
            origin__shipping_address__latitude, 
            origin__shipping_address__address_id, 
            origin__shipping_address__location_id, 
            origin__shipping_address__street_name, 
            origin__shipping_address__zip_code, 
            origin__shipping_address__geolocation_source, 
            origin__shipping_address__street_number, 
            origin__shipping_address__state__id, 
            origin__shipping_address__state__name, 
            origin__shipping_address__neighborhood__name, 
            origin__shipping_address__geolocation_last_updated, 
            origin__shipping_address__longitude, 
            origin__type, origin__sender_id, 
            origin__snapshot__id, 
            origin__snapshot__version, 
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
            destination__shipping_address__geolocation_source, 
            destination__shipping_address__delivery_preference, 
            destination__shipping_address__street_number, 
            destination__shipping_address__state__id, 
            destination__shipping_address__state__name, 
            destination__shipping_address__neighborhood__name, 
            destination__shipping_address__geolocation_last_updated, 
            destination__shipping_address__longitude, destination__type, 
            destination__receiver_phone, 
            destination__snapshot__id, 
            destination__snapshot__version, 
            source__site_id, source__market_place, 
            declared_value, logistic__mode, 
            logistic__type, logistic__direction, 
            priority_class__id, lead_time__cost, 
            lead_time__cost_type, 
            lead_time__estimated_delivery_final__date, 
            lead_time__estimated_delivery_final__offset, 
            lead_time__list_cost,
            lead_time__estimated_delivery_limit__date,
            lead_time__estimated_delivery_limit__offset,
            lead_time__priority_class__id,
            lead_time__delivery_promise,
            lead_time__shipping_method__name,
            lead_time__shipping_method__deliver_to,
            lead_time__shipping_method__id,
            lead_time__shipping_method__type,
            lead_time__delivery_type,
            lead_time__service_id,
            lead_time__estimated_delivery_time__date,
            lead_time__estimated_delivery_time__pay_before,
            lead_time__estimated_delivery_time__unit,
            lead_time__estimated_delivery_time__shipping,
            lead_time__estimated_delivery_time__handling,
            lead_time__estimated_delivery_time__type,
            lead_time__option_id,
            lead_time__estimated_delivery_extended__date,
            lead_time__estimated_delivery_extended__offset,
            lead_time__currency_id,
            tracking_number,
            id,
            tracking_method,
            status,
            dimensions__height,
            dimensions__width,
            dimensions__length,
            dimensions__weight,
            substatus,
            destination__shipping_address__comment,
            external_reference,
            lead_time__estimated_delivery_time__offset__date,
            lead_time__estimated_delivery_time__offset__shipping,
            origin__node__node_id,
            origin__shipping_address__node__logistic_center_id,
            origin__shipping_address__node__node_id,
            max_timestamp.load_timestamp
        FROM {{ source("entry_ml", "entry_mercadolivre_sh") }}, max_timestamp
        {% if is_incremental() %}

            WHERE max_timestamp.load_timestamp > (SELECT MAX(load_timestamp) FROM {{this}})

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