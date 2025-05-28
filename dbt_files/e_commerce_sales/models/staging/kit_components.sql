{{
    config(
        materialized='table'
    )
}}

SELECT *
FROM {{ source("supplies", "kit_components") }}