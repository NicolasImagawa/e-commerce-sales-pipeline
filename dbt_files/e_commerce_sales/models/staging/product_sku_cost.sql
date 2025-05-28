{{
    config(
        materialized='table'
    )
}}

SELECT *
FROM {{ source("supplies", "product_sku_cost") }}