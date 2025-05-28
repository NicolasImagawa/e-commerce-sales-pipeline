{{
    config(
        materialized='table'
    )
}}

SELECT *
FROM {{ ("entry_shopee", "stg_shopee") }}
