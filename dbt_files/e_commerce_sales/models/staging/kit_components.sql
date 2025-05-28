{{
    config(
        materialized='table'
    )
}}

SELECT *
FROM {{ ("supplies", "kit_components") }}