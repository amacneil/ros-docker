#!/bin/bash
set -euo pipefail

# export X11 DISPLAY env var for all users
echo "export DISPLAY=$DISPLAY" > /etc/profile.d/display.sh

# carry on
exec "$@"
