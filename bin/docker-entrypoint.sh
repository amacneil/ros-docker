#!/bin/bash
set -euo pipefail

# initialize home directory
if [ ! -f /home/ubuntu/.profile ]; then
    cp -R /etc/skel/. /home/ubuntu
    chown -R ubuntu:ubuntu /home/ubuntu
fi

# carry on
exec "$@"
