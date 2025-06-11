def get_shipping_id(test_run):
    import pandas as pd
    import os
    from dotenv import load_dotenv

    load_dotenv()

    if test_run:
        id = os.environ["SHIPPING_ID_TEST_1"]
        shipping_ids = [id]

    else:
        id_path = "./extraction/mercadolivre/data/clean/shipping_ids_mercadolivre.csv"

        df = pd.read_csv(id_path, encoding="utf-8")

        df["shipping_id"] = df["shipping_id"].astype(int)
        shipping_ids = df["shipping_id"].tolist()

    if test_run:
        test_data = extract_shipping_cost(shipping_ids, test_run)
        return test_data
    else:
        extract_shipping_cost(shipping_ids, test_run)

def extract_shipping_cost(sh_list, test_run):
    import requests
    import json
    import os
    from dotenv import load_dotenv

    load_dotenv()


    limit = 50
    offset = 0
    file_num = 0

    sh_ids = sh_list

    access_token = os.environ["ACCESS_TOKEN"]

    for id in sh_ids:
        url = (
                f"https://api.mercadolibre.com/shipments/{id}"
            )
        
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
    
    if test_run:
        test_results = {
            "id": data["id"],
            "list_cost": data["lead_time"]["list_cost"]
        }
        return test_results
    
# get_shipping_id()
# get_access_token()