def get_access_token():
    import requests
    import json
    import pathlib

    config_path = "./extraction/mercadolivre/script/configs/user.json"

    with open(config_path, "r") as config_json:
        config_file = json.load(config_json)

    token_url = "https://api.mercadolibre.com/oauth/token"

    headers = {
        "accept": "application/json",
        "content-type": "application/x-www-form-urlencoded",
        "Accept-Charset": 'UTF-8'
    }

    payload = {
        "grant_type": "authorization_code",
        "client_id": config_file["client_id"],
        "client_secret": config_file["client_secret"],  # Replace with your actual secret
        "code": config_file["code"],
        "redirect_uri": config_file["redirect_uri"]
    }

    response = requests.post(
        token_url,
        headers=headers,
        data=payload
    )

    with open("./extraction/mercadolivre/token.json", "w+", encoding="utf-8") as token_json:
         json.dump(response.json(), token_json)

    is_json = (pathlib.Path('/foo/bar.txt').suffix == ".json")

    return is_json