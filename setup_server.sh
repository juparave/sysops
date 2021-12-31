#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
BLUEBG=$(tput setaf 123)
ENDCOLR=$(tput setaf 7)
ENDCOLOR="\e[0m"

# Install a new server with common apps
# Assuming this is an Ubuntu distro

echo -e "${BLUEBG}Updating instance${ENDCOLR}"
apt-get update
apt-get install aptitude
aptitude -y safe-upgrade
