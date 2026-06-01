#!/usr/bin/env bash

#### Description: Installs python tools in a virtual environment. 
#### The virtual environment is created in the parent directory of the project with the name ${APP_PROJECT_NAME}-virtualenv.
#### The python version is specified in the .env file with the variable PYTHON.
#### The script also loads environment variables from the .env file.
#### The script is idempotent, meaning that it can be run multiple times without causing issues.
#### If the virtual environment already exists, it will be recreated.
#### Also checks the operating system and prints it out.
#### Intended to be run from the bin directory of the project.

#### Written by: Guillermo de Ignacio - gdeignacio on 11-2022

# Revision 2024-08-01
# Revision 2024-08-01: Updated to use virtualenv and load environment variables from .env file.
# Revision 2026-05-26: Minor updates and improvements

###################################
###   PYTHON VIRTUAL ENV UTILS  ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./python_venv.sh

    Installs python tools in a virtual environment.

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing python virtual environment..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

VENV_BASE_PATH=${PYTHON_VENV_BASE_PATH}
VENV_NAME=${PYTHON_VENV_APP_NAME}

VENV_PATH=${VENV_BASE_PATH}/${VENV_NAME}

virtualenv ${VENV_PATH} --python=${PYTHON}

