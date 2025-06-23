def extract_mercado(test_run, order_init_date, order_end_date, env):
    import requests
    import json
    import pathlib
    import os
    from dotenv import load_dotenv

    # config_path = "./extraction/mercadolivre/script/configs/user.json"
    # token_filepath = "./extraction/mercadolivre/token.json"

    if test_run:
        load_dotenv("./local/.env")
    else:
        load_dotenv("/opt/airflow/.env")

    seller_id = os.environ["SELLER_ID"]
    access_token = os.environ["ACCESS_TOKEN"]
    order_data_created_from = order_init_date
    order_data_created_to = order_end_date

    if env == 'prod':
        folder = 'prod'
    else:
        folder = 'dev'

    limit = 50
    offset = 0
    file_num = 0
    is_json = True

    while True:
        url = (
                f"https://api.mercadolibre.com/orders/search?seller={seller_id}"
                f"&order.date_created.from={order_data_created_from}"
                f"&order.date_created.to={order_data_created_to}"
                f"&offset={offset}"
                f"&limit={limit}"
            )

        headers = {
            "Authorization": f"Bearer {access_token}"
        }

        response = requests.get(url, headers=headers)
        data = response.json()

        if not data["results"]:
            break

        if test_run:
            download_path = f"./local/data/mercadolivre/raw/{folder}/ml_sell_data_{order_data_created_from}_{order_data_created_to}_{file_num}.json"
        else:
            download_path = f"/opt/airflow/data/mercadolivre/raw/{folder}/ml_sell_data_{order_data_created_from}_{order_data_created_to}_{file_num}.json"

        with open(download_path, "w", encoding="utf-8") as data_json:
            json.dump(data["results"], data_json)

        offset += limit
        file_num += 1

        is_json = (pathlib.Path(download_path).suffix == ".json")

    results_dict = {
        "orders_range": (order_data_created_from < order_data_created_to),
        "all_json": is_json
    }

    if test_run == True:
        print("Data successfully extracted.")
        return results_dict
    else:
        print("Data successfully extracted.")
