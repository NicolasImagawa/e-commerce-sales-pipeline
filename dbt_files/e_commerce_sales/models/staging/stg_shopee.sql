{{
    config(
        materialized='table'
    )
}}

SELECT *
FROM {{ source("entry_shopee", "stg_shopee") }}
