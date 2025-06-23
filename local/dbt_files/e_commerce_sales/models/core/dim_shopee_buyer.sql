{{
    config(
        materialized='incremental',
        unique_key='buyer__id',
        incremental_strategy='merge',
        database=target.database
    )
}}

WITH max_date AS (
        SELECT stg_shopee.nome_de_usuario__comprador_,
               MAX(stg_shopee.hora_do_pagamento_do_pedido) AS time_related_to_last_address --By getting the last purchase, 
            FROM {{ ref("stg_shopee") }} AS stg_shopee                                                       --it ensures that the last address will be used to update the table.
            GROUP BY stg_shopee.nome_de_usuario__comprador_
), new_data AS (
    SELECT orders_results.buyer__id,
           stg_shopee.telefone AS telephone_number,
           stg_shopee.cpf_do_comprador AS cpf,
           stg_shopee.endereco_de_entrega AS address,
           stg_shopee.bairro AS neighborhood,
           stg_shopee.cidade_1 AS city_town,
           stg_shopee.uf AS state,
           stg_shopee.pais AS country,
           MAX(stg_shopee.load_timestamp) AS ld_timestamp
           FROM {{ ref('shopee_orders_results') }} AS orders_results, 
                {{ ref("stg_shopee") }} AS stg_shopee,
                max_date
           WHERE orders_results.buyer__id = max_date.nome_de_usuario__comprador_
           AND orders_results.buyer__id = stg_shopee.nome_de_usuario__comprador_
           AND max_date.nome_de_usuario__comprador_ = stg_shopee.nome_de_usuario__comprador_
           AND max_date.time_related_to_last_address = stg_shopee.hora_do_pagamento_do_pedido
           AND stg_shopee.status_da_devolucao___reembolso IS NULL
            {% if is_incremental() %}

                AND stg_shopee.load_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

            {% endif %}
            GROUP BY orders_results.buyer__id,
                     stg_shopee.telefone,
                     stg_shopee.cpf_do_comprador,
                     stg_shopee.endereco_de_entrega,
                     stg_shopee.bairro,
                     stg_shopee.cidade_1,
                     stg_shopee.uf,
                     stg_shopee.pais
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
