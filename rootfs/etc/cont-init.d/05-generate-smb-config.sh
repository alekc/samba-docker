#!/bin/sh

set -o nounset
set -e

# generate config
python3 /etc/config-gen/config.py

# bug where smbd stops on "end of input"

