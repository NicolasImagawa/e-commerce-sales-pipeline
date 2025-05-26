def get_access_token(test_run):
    import requests
    import json
    import pathlib
    import os

    if test_run == False:
        config_path = "./extraction/mercadolivre/script/configs/user.json"

        with open(config_path, "r") as config_json:
            config_file = json.load(config_json)
        
        client_id = config_file["client_id"]
        client_secret = config_file["client_secret"]
        code = config_file["code"]
        redirect_uri = config_file["redirect_uri"]

    else:
        client_id = os.environ["CLIENT_ID"]
        client_secret = os.environ["CLIENT_SECRET"]
        code = os.environ["CODE"]
        redirect_uri = os.environ["REDIRECT_URI"]

    token_url = "https://api.mercadolibre.com/oauth/token"

    headers = {
        "accept": "application/json",
        "content-type": "application/x-www-form-urlencoded",
        "Accept-Charset": 'UTF-8'
    }

    payload = {
        "grant_type": "authorization_code",
        "client_id": client_id,
        "client_secret": client_secret,
        "code": code,
        "redirect_uri": redirect_uri
    }

    response = requests.post(
        token_url,
        headers=headers,
        data=payload
    )

    token_path = "./extraction/mercadolivre/token.json"
    with open(token_path, "w+", encoding="utf-8") as token_json:
         json.dump(response.json(), token_json)

    is_json = (pathlib.Path(token_path).suffix == ".json")

    return is_json
