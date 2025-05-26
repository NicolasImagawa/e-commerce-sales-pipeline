def extract_mercado():
    import requests
    import json
    import pathlib

    config_path = "./extraction/mercadolivre/script/configs/user.json"

    with open (config_path, "r") as config_file:
        user_configs = json.load(config_file)

    limit = 50
    offset = 0
    file_num = 0
    is_csv = True

    while True:
        token_filepath = "./extraction/mercadolivre/token.json"
        with open(token_filepath, "r") as token_json:
            token_file = json.load(token_json)
        
        seller_id = user_configs["seller_id"]

        order_data_created_from = "2024-07-01T00:00:00.000-03:00"
        order_data_created_to = "2025-04-01T00:00:00.000-03:00"
        url = (
                f"https://api.mercadolibre.com/orders/search?seller={seller_id}"
                f"&order.date_created.from={order_data_created_from}"
                f"&order.date_created.to={order_data_created_to}"
                f"&offset={offset}"
                f"&limit={limit}"
            )

        access_token = token_file["access_token"]
        headers = {
            "Authorization": f"Bearer {access_token}"
        }

        response = requests.get(url, headers=headers)
        data = response.json()

        if not data["results"]:
            break

        with open(f"./extraction/mercadolivre/data/raw/ml_sell_data_{order_data_created_from}_{order_data_created_to}_{file_num}.json", "w", encoding="utf-8") as data_json:
            json.dump(data["results"], data_json)

        offset += limit
        file_num += 1
        print(offset, data["results"])

        is_csv = (pathlib.Path('/foo/bar.txt').suffix == ".csv")

    results_dict = {
        "orders_range": (order_data_created_from < order_data_created_to),
        "all_csv": is_csv
    }

    return results_dict

# get_access_token()