#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"

ENDCOLOR="\e[0m"

# Install a new server with common apps
# Assuming this is an Ubuntu distro

echo "${GREEN}Updating instance${ENDCOLOR}"
apt-get update
apt-get install aptitude
aptitude -y safe-upgrade
