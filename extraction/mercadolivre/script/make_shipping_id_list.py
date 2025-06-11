def make_shipping_file(test_run: bool) -> None:
    import csv
    import psycopg2

    if test_run:
        host = "localhost"
        user = "root"
        save_path = "./extraction/mercadolivre/data/clean/shipping_ids_mercadolivre.csv"
    else:
        host = "pgdatabase"
        user = "airflow"
        save_path = "/opt/airflow/extraction/mercadolivre/data/clean/shipping_ids_mercadolivre.csv"

    conn = psycopg2.connect(database="sales_db", host=host, user=user, password="airflow", port="5432")

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