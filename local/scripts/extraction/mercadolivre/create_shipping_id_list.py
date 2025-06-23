def make_shipping_file(test_run: bool, env: str) -> None:
    import csv
    import psycopg2

    if test_run:
        host = "localhost"
        user = "root"
        save_path = "./local/data/mercadolivre/shipping_cost_ml/dev/shipping_ids_mercadolivre.csv"
    else:
        host = "pgdatabase"
        user = "airflow"

        if env == 'prod':
            db = "sales_db"
        elif env == 'dev':
            db = "dev_sales_db"

    save_path = f"/opt/airflow/data/mercadolivre/shipping_cost_ml/{env}/shipping_ids_mercadolivre.csv"

    conn = psycopg2.connect(database=db, host=host, user=user, password="airflow", port="5432")

    cursor = conn.cursor()

    cursor.execute("""
                    SELECT shipping__id AS shipping_id FROM entry.entry_mercadolivre
                    WHERE shipping__id IS NOT NULL
                    AND id IS NOT NULL
                    GROUP BY shipping_id
                   """
                  )
    
    headers = [column[0] for column in cursor.description]

    data = cursor.fetchall()

    file = csv.writer(open(save_path, "w"))
    file.writerow(headers)
    file.writerows(data)

    cursor.close()
    conn.close()