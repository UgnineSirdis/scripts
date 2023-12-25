#! /usr/bin/env python3
import os
import sys

def is_root(directory):
    return os.path.exists(os.path.join(directory, '.arcadia.root')) or os.path.exists(os.path.join(directory, '.git'))


def get_root():
    directory = os.getcwd()

    while directory and directory != '/' and not is_root(directory):
        directory = os.path.dirname(directory)
    if not is_root(directory):
        raise Exception('Failed to find arcadia from {}'.format(os.getcwd()))
    return directory


def main():
    try:
        print(get_root())
    except Exception as ex:
        sys.stderr.write('Error: {}\n'.format(ex))
        sys.exit(1)


if __name__ == '__main__':
    main()
