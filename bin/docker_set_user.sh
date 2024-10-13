#!/usr/bin/env bash

#### Description: Adds user to docker group
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021
#### WARNING: Check if DOCKER_CUSTOM_USERNAME is set. See settings/500_docker file

# Revision 2024-08-01

###################################
###   DOCKER SET USER           ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_set_user.sh

Adds user to docker group

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Setting user for docker..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

if [[ isLinux -eq 1 ]]; then
    # sudo useradd -p $(openssl passwd -1 docker) docker -g docker
    # sudo usermod -a -G docker emiserv
    sudo usermod -a -G docker ${DOCKER_CUSTOM_USERNAME_ON_INSTALL}
else
    echo ""
    echo "Docker should be installed manually"
    echo ""
fi



