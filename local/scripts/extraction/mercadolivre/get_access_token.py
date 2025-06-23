def get_access_token(test_run):
    import requests
    import os
    from dotenv import load_dotenv, set_key

    if test_run:
        env_path = "./local/.env"
        load_dotenv(env_path, override=True)
    else:
        env_path = "/opt/airflow/.env"
        load_dotenv(env_path, override=True)

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

    set_key(env_path, "ACCESS_TOKEN", token_data["access_token"], encoding='utf-8')