#!/usr/bin/env bash

#### Description: Stops all containers
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

### Revision 2024-08-01

###################################
###         Cleanup             ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_cleanup.sh

Stops all containers 

'
    exit
fi


echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Stopping and removing all the containers..."
echo ""

#source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

#lib_env_utils.loadenv ${PROJECT_PATH}
#echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

dckr=$(lib_env_utils.check_docker)
echo $dckr

DOCKER=$dckr

if [[ "${DOCKER}" == "/dev/null" ]]; then
  echo "Docker not installed. Exiting"
  exit 1
fi

${DOCKER} stop $(${DOCKER} ps -a -q) && ${DOCKER} rm $(${DOCKER} ps -a -q) --volumes
