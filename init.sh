#!/bin/sh

FILE=/bootstrap.sh
if test -f "$FILE"; then
    echo "Running $FILE"
    source $FILE
fi

# bug where smbd stops on "end of input"
ionice -c 3 smbd --foreground --log-stdout < /dev/null
