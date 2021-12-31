#!/bin/bash
RED=$(tput setaf 160)
GREEN=$(tput setaf 076)
BLUE=$(tput setaf 123)
ENDCOLR=$(tput setaf 7)

# Install a new server with common apps
# Assuming this is an Ubuntu distro

echo "${BLUE}Updating instance${ENDCOLR}"
apt-get update
apt-get install aptitude
aptitude -y safe-upgrade
