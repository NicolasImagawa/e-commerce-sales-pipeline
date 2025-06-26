def delete_entry_tables(env: str) -> None:
    from config.config import ENTRY_TABLES_NAMES
    
    import psycopg2
    host = "pgdatabase"
    user = "airflow"
    
    tables = ENTRY_TABLES_NAMES

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