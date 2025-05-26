{{
    config(
        materialized='incremental',
        unique_key='buyer__id',
        incremental_strategy='merge'
    )
}}

WITH new_data AS (
    SELECT orders_results.buyer__id,
           stg_shopee.telefone AS telephone_number,
           stg_shopee.cpf_do_comprador AS cpf,
           stg_shopee.endereco_de_entrega AS address,
           stg_shopee.bairro AS neighborhood,
           stg_shopee.cidade_1 AS city_town,
           stg_shopee.uf AS state,
           stg_shopee.pais AS country,
           stg_shopee.load_timestamp AS ld_timestamp
           FROM {{ ref('shopee_orders_results') }} AS orders_results
           LEFT JOIN {{ source('entry_shopee', 'stg_shopee') }} AS stg_shopee
                ON orders_results.buyer__id = stg_shopee.nome_de_usuario__comprador_

            {% if is_incremental() %}

                WHERE stg_shopee.load_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

            {% endif %}

), update_data AS (
    SELECT new_data.buyer__id,
           new_data.telephone_number,
           new_data.cpf,
           new_data.address,
           new_data.neighborhood,
           new_data.city_town,
           new_data.state,
           new_data.country,
           new_data.ld_timestamp
           FROM new_data
            {% if is_incremental() %}

                WHERE new_data.buyer__id IN (SELECT buyer__id FROM {{ this }})

            {% endif %}
), insert_data AS (
    SELECT new_data.buyer__id,
           new_data.telephone_number,
           new_data.cpf,
           new_data.address,
           new_data.neighborhood,
           new_data.city_town,
           new_data.state,
           new_data.country,
           new_data.ld_timestamp
           FROM new_data
        WHERE new_data.buyer__id NOT IN (SELECT buyer__id FROM update_data)
) SELECT update_data.buyer__id,
         update_data.telephone_number,
        update_data.cpf,
        update_data.address,
        update_data.neighborhood,
        update_data.city_town,
        update_data.state,
        update_data.country,
        update_data.ld_timestamp
    FROM update_data
    UNION
SELECT insert_data.buyer__id,
        insert_data.telephone_number,
        insert_data.cpf,
        insert_data.address,
        insert_data.neighborhood,
        insert_data.city_town,
        insert_data.state,
        insert_data.country,
        insert_data.ld_timestamp
    FROM insert_data
