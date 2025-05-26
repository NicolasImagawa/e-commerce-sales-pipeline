COPY supplies.kit_components (main_sku, product, sku, component_sku, component_name)
FROM '/input_data/clean/kit_components.csv'
DELIMITER ','
CSV HEADER

-- COPY mercadolivre.kit_components (main_sku, product, sku, component_sku, component_name)
-- FROM '/input_data/clean/kit_components.csv'
-- DELIMITER ','
-- CSV HEADER
