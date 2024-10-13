#!/usr/bin/env bash

#### Description: Uninstalls docker.
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021
#### WARNING: Check if DOCKER_CUSTOM_USERNAME is set. See settings/500_docker file

# Revision 2024-08-01

###################################
###   DOCKER UNINSTALL UTILS    ###
###################################


set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_uninstall.sh

Uninstalls docker

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Uninstalling docker..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""
lib_env_utils.check_os
echo ""

isLinux=$(lib_env_utils.check_os)

if [[ isLinux -eq 1 ]]; then

    sudo systemctl disable docker.service
    sudo systemctl disable containerd.service

    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Manual deleting from /var/lib/docker and /var/lib/containerd is recommended
    #
    # rm -rf /var/lib/docker
    # rm -rf /var/lib/containerd
    #
    # with sudo option
    #

    echo "Manual deleting from /var/lib/docker and /var/lib/containerd is recommended"
    echo ""
    echo "rm -rf /var/lib/docker"
    echo "rm -rf /var/lib/containerd"
    echo ""
    echo "with sudo option"
    echo ""

else

    echo ""
    echo "Docker should be installed manually"
    echo ""

fi



