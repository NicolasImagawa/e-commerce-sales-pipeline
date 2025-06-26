def extract_mercado(test_run: bool, order_init_date: str, order_end_date: str, env: str) -> None: #Returns dict if is test run    
    import requests
    import json
    import pathlib
    import os
    from dotenv import load_dotenv
    from config.config import PATHS

    if test_run:
        load_dotenv(PATHS['extract_ml_data']['test']['dotenv_path'])
    else:
        load_dotenv(PATHS['extract_ml_data']['prod_and_dev']['dotenv_path'])

    seller_id = os.environ["SELLER_ID"]
    access_token = os.environ["ACCESS_TOKEN"]
    order_data_created_from = order_init_date
    order_data_created_to = order_end_date

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
            download_path = f"{PATHS['extract_ml_data']['test']['download_path']}{order_data_created_from}_{order_data_created_to}_{file_num}.json"
        elif env == 'prod':
            download_path = f"{PATHS['extract_ml_data']['prod']['download_path']}{order_data_created_from}_{order_data_created_to}_{file_num}.json"
        else:
            download_path = f"{PATHS['extract_ml_data']['dev']['download_path']}{order_data_created_from}_{order_data_created_to}_{file_num}.json"

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
