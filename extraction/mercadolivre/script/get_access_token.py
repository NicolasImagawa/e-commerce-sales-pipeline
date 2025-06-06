def get_access_token(test_run):
    import requests
    import json
    import pathlib
    import os
    from dotenv import load_dotenv, set_key
    from airflow.models import Variable

    load_dotenv("/opt/airflow/.env", override=True)

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

    token_data = response.json()

    print(token_data)

    # with open(os.path.expanduser("~/.bashrc"), "a") as f:
    #     f.write(f'\nexport ACCESS_TOKEN={token_data["access_token"]}\n')

    # os.system("source ~/.bashrc")
    set_key("/opt/airflow/.env", "ACCESS_TOKEN", token_data["access_token"], encoding='utf-8')

    # token_path = "./extraction/mercadolivre/token.json"
    # with open(token_path, "w+", encoding="utf-8") as token_json:
    #      json.dump(response.json(), token_json)

    # is_json = (pathlib.Path(token_path).suffix == ".json")

    # return is_json
