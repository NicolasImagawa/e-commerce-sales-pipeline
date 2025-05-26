COPY supplies.product_sku_cost (main_sku, product, sku, component_name, begin_date, end_date, "cost")
FROM '/input_data/clean/clean_cost_data.csv'
DELIMITER ','
CSV HEADER

-- COPY mercadolivre.product_sku_cost (main_sku, product, sku, component_name, begin_date, end_date, "cost")
-- FROM '/input_data/clean/clean_cost_data.csv'
-- DELIMITER ','
-- CSV HEADER