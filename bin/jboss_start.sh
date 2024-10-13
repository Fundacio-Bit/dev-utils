#!/usr/bin/env bash

#### Description: Run local jboss
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###         Start jboss         ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./jboss_start.sh

 Starts jboss

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Starting JBOSS.."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}

JBOSS=$JBOSS_HOME/bin/run.sh
echo "JBOSS at $JBOSS"

#export USER_ID=${UID}
#export GROUP_ID=${UID}


${JBOSS} -b 0.0.0.0