#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import jwt
import time
import json
import requests
import argparse

from requests_toolbelt.utils import dump

jwt_expiration_timeout = 3600


def get_jwt(args):
    with open(args.private_key_path, "r") as pk:
        private_key = pk.read()
    now = time.time()
    #now_utc = datetime.utcfromtimestamp(now)
    #exp_utc = datetime.utcfromtimestamp(now + jwt_expiration_timeout)
    return jwt.encode(
        key=private_key,
        algorithm="RS256",
        headers={"typ": "JWT", "alg": "RS256", "kid": args.key_id},
        payload={
            "iss": args.service_account_id,
            "sub": args.service_account_id,
            "aud": "token-service.iam.new.nebiuscloud.net",
            "iat": now,
            "exp": now + jwt_expiration_timeout,
        },
    )


def exchange_token_with_http(token):
    params = {
        "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
        "requested_token_type": "urn:ietf:params:oauth:token-type:access_token",
        "subject_token": token,
        "subject_token_type": "urn:ietf:params:oauth:token-type:jwt"
    }
    encoding = "application/x-www-form-urlencoded"
    headers = {"Content-Type": encoding}
    r = requests.post("https://auth.new.nebiuscloud.net/oauth2/token/exchange", data=params, headers=headers)
    if r.status_code == 200:
        ret = json.loads(r.content)
        return ret["access_token"]
    else:
        raise Exception("Error. Status: {}. Message: {}".format(r.status_code, r.content))


def parse_args():
    parser = argparse.ArgumentParser(
        usage="%(prog)s options",
        description="JWT exhange"
    )
    parser.add_argument(
        "-k", "--private-key-path", help="private key file path in pem format"
    )
    parser.add_argument(
        "-i", "--key-id", help="key id"
    )
    parser.add_argument(
        "-a", "--service-account-id", help="service account id"
    )
    return parser.parse_args()


def main():
    args = parse_args()

    jwt = get_jwt(args)
    token = exchange_token_with_http(jwt)

    print("Token: {}".format(token))

main()
