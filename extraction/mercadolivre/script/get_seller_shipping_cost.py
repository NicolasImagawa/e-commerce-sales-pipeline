def get_shipping_id():
    import pandas as pd

    id_path = "./extraction/mercadolivre/data/clean/shipping_ids_mercadolivre.csv"
    
    df = pd.read_csv(id_path, encoding="utf-8")

    df["shipping__id"] = df["shipping__id"].astype(int)
    shipping_ids = df["shipping__id"].tolist()

    # get_access_token(shipping_ids)
    extract_shipping_cost(shipping_ids)

def extract_shipping_cost(sh_list):
    import requests
    import json

    limit = 50
    offset = 0
    file_num = 0

    sh_ids = sh_list

    for id in sh_ids:
        token_filepath = "./extraction/mercadolivre/token.json"
        with open(token_filepath, "r") as token_json:
            token_file = json.load(token_json)

        url = (
                f"https://api.mercadolibre.com/shipments/{id}"
            )

        access_token = token_file["access_token"]
        headers = {
            "Authorization": f"Bearer {access_token}",
            "X-Format-New": "true"
        }

        response = requests.get(url, headers=headers)
        data = response.json()

        with open(f"./extraction/mercadolivre/data/shipping_cost_ml/sh_cost_{file_num}.json", "w", encoding="utf-8") as data_json:
            json.dump(data, data_json)

        offset += limit
        file_num += 1
        print(offset, data)

# get_shipping_id()
# get_access_token()