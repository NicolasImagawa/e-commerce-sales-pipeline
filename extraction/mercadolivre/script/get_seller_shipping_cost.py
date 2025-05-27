def get_shipping_id(test_run):
    import pandas as pd
    import os

    if test_run:
        id = os.environ["SHIPPING_ID_TEST_1"]
        shipping_ids = [id]

    else:
        id_path = "./extraction/mercadolivre/data/clean/shipping_ids_mercadolivre.csv"

        df = pd.read_csv(id_path, encoding="utf-8")

        df["shipping__id"] = df["shipping__id"].astype(int)
        shipping_ids = df["shipping__id"].tolist()

    # get_access_token(shipping_ids)
    if test_run:
        test_data = extract_shipping_cost(shipping_ids, test_run)
        return test_data
    else:
        extract_shipping_cost(shipping_ids, test_run)

def extract_shipping_cost(sh_list, test_run):
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
        print(type(data))
        print(data["id"], type(data["id"]))
        print(data["lead_time"]["list_cost"], type(data["lead_time"]["list_cost"]))

        with open(f"./extraction/mercadolivre/data/shipping_cost_ml/sh_cost_{file_num}.json", "w", encoding="utf-8") as data_json:
            json.dump(data, data_json)

        offset += limit
        file_num += 1
    
    if test_run:
        test_results = {
            "id": data["id"],
            "list_cost": data["lead_time"]["list_cost"]
        }
        print("json file id is: " + str(data["id"]))
        print("test results id is:" + str(test_results["id"]))

        return test_results
    
# get_shipping_id()
# get_access_token()