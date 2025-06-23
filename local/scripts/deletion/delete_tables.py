def delete_entry_tables(env):
    import psycopg2
    host = "pgdatabase"
    user = "airflow"
    
    tables = [
        "entry.entry_mercadolivre",
        "entry.entry_mercadolivre__context__flows",
        "entry.entry_mercadolivre__mediations",
        "entry.entry_mercadolivre__order_items",
        "entry.entry_mercadolivre__order_items__item__variation_attributes",
        "entry.entry_mercadolivre__payments",
        "entry.entry_mercadolivre__payments__available_actions",
        "entry.entry_mercadolivre__tags",
        "entry.entry_mercadolivre_sh",
        "entry.entry_mercadolivre_sh__destination__shipping_address__types",
        "entry.entry_mercadolivre_sh__items_types",
        "entry.entry_mercadolivre_sh__origin__shipping_address__types",
        "entry.entry_mercadolivre_sh__tags",
        "entry.entry_shopee",
        "entry._dlt_loads",
        "entry._dlt_pipeline_state",
        "entry._dlt_version"
    ]

    if env == 'prod':
        db = "sales_db"
    elif env == 'dev':
        db = "dev_sales_db"

    conn = psycopg2.connect(database=db, host=host, user=user, password="airflow", port="5432")

    cursor = conn.cursor()

    for table in tables:
        try:
            cursor.execute(f"DROP TABLE IF EXISTS {table}")
            print(f"Table {table} successfully deleted.")
        except Exception as e:
            print(f"Table {table} could not be deleted: {e}")

    conn.commit()

    cursor.close()
    conn.close()