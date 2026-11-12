#!/usr/bin/env bash

#### Description: Takes necessary actions after installing docker.
#### Written by: Guillermo de Ignacio - gdeignacio on 09-2021
#### WARNING: Check if DOCKER_CUSTOM_USERNAME is set. See settings/500_docker file

# Revision 2024-08-01

###################################
###   DOCKER POST INSTALL UTILS ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_post_install.sh

Takes necessary actions after installing docker.

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Post Installing docker..."
echo ""

# Taking values from .env file

LIB_PATH=$PROJECT_PATH/bin/lib

for lib in $LIB_PATH/lib*.sh; do
    source ${lib}
done

# Taking values from .env file

isLinux=$(lib_env_utils.check_os)
echo $isLinux

if [[ $isLinux -eq 1 ]]; then

    if ! getent group docker >/dev/null; then
        sudo groupadd docker
    fi

    if getent group docker >/dev/null; then
        sudo usermod -aG docker "${DOCKER_CUSTOM_USERNAME_ON_INSTALL}"
    else
        echo "Group 'docker' does not exist; skipping user membership update"
    fi

    for service in docker.service containerd.service; do
        if systemctl cat "$service" >/dev/null 2>&1; then
            sudo systemctl enable "$service"
        else
            echo "Systemd unit '$service' does not exist; skipping enable"
        fi
    done
    
else
    echo ""
    echo "Docker should be installed manually"
    echo ""
fi
