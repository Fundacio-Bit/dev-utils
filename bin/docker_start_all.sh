#!/usr/bin/env bash

#### Description: Starts all containers
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021
#### State REVIEW

# Revision 2024-08-01

###################################
###         Start               ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_start_all.sh

Starts all containers

'
    exit
fi

COMMAND=docker

DOCKER=$(command -v $COMMAND)
echo "docker at $DOCKER"

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Stopping lingering containers..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

dckr=$(lib_env_utils.check_docker)
echo $dckr

DOCKER=$dckr


IFS=' '
#Read the split words into an array based on space delimiter
read -a START_ARRAY <<< ${APP_ARRAY}

APPS_PATH=${PROJECT_PATH}/../../..
echo ${APPS_PATH}
# bin/docker_start.sh


for START in ${START_ARRAY[*]}; do
    echo Executing $START
    cd ${APPS_PATH}/${START}/jee-app-dist
    echo Current folder is $(pwd)
    echo
    bin/docker_start.sh&
    cd ${APPS_PATH}
    echo Current folder now is $(pwd)
    echo
    
done

cd $PROJECT_PATH