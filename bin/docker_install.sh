#!/usr/bin/env bash

#### Description: Installs docker.
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021
#### WARNING: Check if DOCKER_CUSTOM_USERNAME is set. See settings/500_docker file

# Revision 2024-08-01
# Revision 2026-10-22

###################################
###   DOCKER INSTALL UTILS      ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_install.sh

Installs docker packages

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing docker..."
echo ""

LIB_PATH=$PROJECT_PATH/bin/lib

for lib in $LIB_PATH/lib*.sh; do
    source ${lib}
done

# Taking values from .env file

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

if [[ $isLinux -eq 1 ]]; then

    sudo apt-get update
    
    sudo apt-get remove \
        docker \
        docker.io \
        docker-compose \
        docker-compose-v2 \
        docker-doc \
        docker-buildx \
        podman-docker \
        containerd \
        runc

    echo "remove docker docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc"

    sudo apt-get remove docker-engine
    echo "remove docker-engine"

    sudo apt-get autoremove
    
    sudo apt-get update

    sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o  /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    echo Adding: \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable"

    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo docker run hello-world

    # TO DO:  Check path if needed
    # Deprecated
    # sudo mkdir -p /app/docker

else
    echo ""
    echo "Docker should be installed manually"
    echo ""
fi


