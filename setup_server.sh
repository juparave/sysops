#!/bin/bash

# Install a new server with common apps
# Assuming this is an Ubuntu distro

echo "Updating instance"
apt-get update
apt-get install aptitude
aptitude -y safe-upgrade
