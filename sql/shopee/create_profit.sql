CREATE TABLE IF NOT EXISTS shopee.profits (
    main_id VARCHAR(35) UNIQUE NOT NULL,
	buyer__id VARCHAR(50),
	date_created TIMESTAMP WITH TIME ZONE NOT NULL,
	date_approved TIMESTAMP WITH TIME ZONE NOT NULL,
	product VARCHAR(200) NOT NULL,
	sku VARCHAR(30),
	qt INT NOT NULL,
	CHECK (qt > 0),
	price NUMERIC(7,2),
	unit_comission_fee NUMERIC(6,2),
	unit_service_fee NUMERIC(6,2),
	sh_cost NUMERIC(6,2),
	sh_discount NUMERIC(6,2),
	reverse_sh_fee NUMERIC(6,2),
	refund_status VARCHAR(50),
    total_cost NUMERIC(7,2),
    profit NUMERIC(7,2)
)