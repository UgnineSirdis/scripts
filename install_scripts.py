#! /usr/bin/env python3

import os

def get_scripts_dir() -> str:
    return os.path.dirname(os.path.abspath(__file__))


def file_has_scripts_dir(p: str) -> bool:
    p = os.path.expanduser(p)
    substr = get_scripts_dir()
    with open(p, "r") as f:
        for l in f:
            if substr in l:
                return True
    return False


def add_to_the_end(p: str, s: str):
    p = os.path.expanduser(p)
    with open(p, "a") as f:
        f.write("\n")
        f.write(s)
        f.write("\n")


def install():
    if not file_has_scripts_dir("~/.bashrc"):
        print("Install bashrc...")
        bashrc_path = os.path.join(get_scripts_dir(), "bashrc.sh")
        add_to_the_end("~/.bashrc", f"source {bashrc_path}")

    if not file_has_scripts_dir("~/.profile"):
        print("Install profile...")
        scripts_dir = get_scripts_dir()
        profile_path = os.path.join(scripts_dir, "profile.sh")
        add_to_the_end("~/.profile", f"export SCRIPTS_DIR=\"{scripts_dir}\"\nsource {profile_path}")

install()
