CREATE TABLE IF NOT EXISTS supplies.product_sku_cost (
	main_sku VARCHAR(20),
	product VARCHAR(200),
	sku VARCHAR(30),
	component_name VARCHAR(200),
	begin_date TIMESTAMP WITH TIME ZONE,
	end_date TIMESTAMP WITH TIME ZONE,
	"cost" NUMERIC(7,2)
)


-- CREATE TABLE IF NOT EXISTS mercadolivre.product_sku_cost (
-- 	main_sku VARCHAR(20),
-- 	product VARCHAR(200),
-- 	kit INT,
-- 	sku VARCHAR(30),
-- 	component_sku VARCHAR(30),
-- 	component_name VARCHAR(200),
-- 	"cost" NUMERIC(7,2),
-- 	total_cost NUMERIC(7,2)
-- )