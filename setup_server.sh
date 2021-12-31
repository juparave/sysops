#!/bin/bash
# call it using curl, $RANDOM is used to avoid server cache
# curl -s https://raw.githubusercontent.com/juparave/sysops/main/setup_server.sh?$RANDOM | bash

RED=$(tput setaf 160)
GREEN=$(tput setaf 076)
BLUE=$(tput setaf 123)
ENDCOLR=$(tput setaf 7)

# Install a new server with common apps
# Assuming this is an Ubuntu distro

if [ -f "STEP_01"]; then
    echo "${BLUE}Updating instance${ENDCOLR}"
    apt-get update
    apt-get install aptitude
    aptitude -y safe-upgrade

    echo "${GREEN} please enter desired hostname${ENDCOLR}"
    read hm
    echo "setting hostname to: ${hm}"
    hostname ${hm}
    touch STEP_01
fi


echo ""
