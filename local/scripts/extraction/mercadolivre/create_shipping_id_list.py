def make_shipping_file(test_run: bool, env: str) -> None:
    from config.config import PATHS
    
    import csv
    import psycopg2

    if test_run:
        host = "localhost"
        user = "root"
        save_path = PATHS['create_shipping_id_list']['test']['save_path']
    else:
        host = "pgdatabase"
        user = "airflow"

        if env == 'prod':
            db = "sales_db"
            save_path = PATHS['create_shipping_id_list']['prod']['save_path']
        elif env == 'dev':
            db = "dev_sales_db"
            save_path = PATHS['create_shipping_id_list']['dev']['save_path']

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