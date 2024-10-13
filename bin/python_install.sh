#!/usr/bin/env bash

#### Description: Installs python tools
#### Written by: Guillermo de Ignacio - gdeignacio on 11-2022

# Revision 2024-08-01

###################################
###   Python INSTALL UTILS      ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./python_install.sh

    Installs python tools

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing python ..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

if [[ isLinux -eq 1 ]]; then
    sudo apt-get update
    sudo apt-get upgrade
   
    sudo apt-get install \
        $PYTHON \
        python3-virtualenv \
        virtualenv
    echo ""
else
    echo ""
    echo "Python should be installed manually"
    echo ""
fi

