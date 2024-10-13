#!/usr/bin/env bash

#### Description: Minimal stuff for every script
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

###################################
###   BEFORE ANY ACTION         ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./script.sh arg-one arg-two

This is an awesome bash script to make your life better.

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at ${PROJECT_PATH}"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Do something..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""