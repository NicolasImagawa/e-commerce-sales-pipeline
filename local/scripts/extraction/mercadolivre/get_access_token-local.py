def get_access_token():
    import requests
    import json
    from dotenv import load_dotenv
    import os

    load_dotenv()

    token_url = "https://api.mercadolibre.com/oauth/token"

    headers = {
        "accept": "application/json",
        "content-type": "application/x-www-form-urlencoded",
        "Accept-Charset": 'UTF-8'
    }

    payload = {
        "grant_type": "authorization_code",
        "client_id": os.environ["CLIENT_ID"],
        "client_secret": os.environ["CLIENT_SECRET"], 
        "code": os.environ["CODE"],
        "redirect_uri": os.environ["REDIRECT_URI"]
    }

    response = requests.post(
        token_url,
        headers=headers,
        data=payload
    )

    with open("./extraction/mercadolivre/token.json", "w+", encoding="utf-8") as token_json:
         json.dump(response.json(), token_json)
         
get_access_token()