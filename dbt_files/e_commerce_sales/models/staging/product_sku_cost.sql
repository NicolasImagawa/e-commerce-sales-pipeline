{{
    config(
        materialized='table'
    )
}}

SELECT *
FROM {{ ("supplies", "product_sku_cost") }}