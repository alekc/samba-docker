#!/bin/sh

set -o nounset
set -e

# Generate config
FILE=/bootstrap.sh
if test -f "$FILE"; then
    echo "Running $FILE"
    source $FILE
fi

# generate config
python3 /etc/config-gen/config.py

# bug where smbd stops on "end of input"
ionice -c 3 smbd --foreground --log-stdout < /dev/null
