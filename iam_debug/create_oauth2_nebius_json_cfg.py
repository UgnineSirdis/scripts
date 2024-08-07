#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os


def parse_args():
    parser = argparse.ArgumentParser(
        usage="%(prog)s options",
        description="Create OAuth 2.0 key file for ydb cli",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
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
    parser.add_argument(
        "-t", "--iam-installation", help="prod/test"
    )
    parser.add_argument(
        "-o", "--output-path", help="json config output path"
    )
    args = parser.parse_args()

    if not args.private_key_path:
        print("Please specify private key path")
        exit(1)

    if not args.key_id:
        print("Please specify key id. It is something like \"publickey-e0t...\"")
        exit(1)

    if not args.service_account_id:
        print("Please specify service account id. It is something like \"serviceaccount-e0t...\"")
        exit(1)

    if not args.iam_installation or (args.iam_installation != "prod" and args.iam_installation != "test"):
        print("Please specify correct IAM installation type. prod or test")
        exit(1)

    if args.iam_installation == "prod":
        args.token_endpoint = "https://auth.eu-north1.nebius.ai:443/oauth2/token/exchange"
    elif args.iam_installation == "test":
        args.token_endpoint = "https://auth.new.nebiuscloud.net:443/oauth2/token/exchange"

    return args

def get_config(args):
    cfg = {}
    cfg["token-endpoint"] = args.token_endpoint
    jwt_cfg = {}
    jwt_cfg["type"] = "JWT"
    jwt_cfg["alg"] = "RS256"
    with open(args.private_key_path) as pk:
        jwt_cfg["private-key"] = pk.read()
    jwt_cfg["kid"] = args.key_id
    jwt_cfg["iss"] = args.service_account_id
    jwt_cfg["sub"] = args.service_account_id

    cfg["subject-credentials"] = jwt_cfg
    return cfg

def save_to_file(args, cfg):
    if args.output_path:
        with open(args.output_path, "w") as out:
            json.dump(cfg, out, indent=4)
    else:
        print(json.dumps(cfg, indent=4))

def print_ydb_help(args):
    if args.output_path:
        print("Create ydb cli profile with generated file:")
        print("ydb config profile create <new-profile-name> --iam-endpoint {} --oauth2-key-file {}".format(args.token_endpoint, args.output_path))
        print("")
        print("Test created profile:")
        print("ydb --endpoint fake -d /fake --profile <new-profile-name> auth get-token -f")

def main():
    args = parse_args()
    save_to_file(args, get_config(args))
    print_ydb_help(args)

main()
