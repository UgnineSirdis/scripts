#! /usr/bin/env python3

import os
import shutil

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


def install_config_to_home_dir(cfg_name):
    print(f"Copy {cfg_name}")
    shutil.copyfile(os.path.join(get_scripts_dir(), cfg_name), os.path.expanduser(f"~/{cfg_name}"))


def install_server_name():
    name = input("(Optional) Short server name for command prompt:\n")
    if name:
        name = name.strip()
        with open(os.path.expanduser("~/.servername"), "w") as n:
            n.write(name)


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

    install_config_to_home_dir(".tmux.conf")
    install_config_to_home_dir(".gitconfig")
    install_server_name()

install()
