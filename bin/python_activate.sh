#!/usr/bin/env bash

#### Description: Installs python tools
#### Written by: Guillermo de Ignacio - gdeignacio on 11-2022

# Revision 2024-08-01

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
    echo 'Usage: ./python_activate.sh

    Activates python virtual environmentS

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing docker..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

if [[ -z "${APP_PROJECT_NAME-}" ]]; then
    echo "Error: APP_PROJECT_NAME is not set."
    exit 1
fi

VENV_PATH=${PROJECT_PATH}/../${APP_PROJECT_NAME}-virtualenv

if [[ -z "${VENV_PATH-}" ]]; then
    echo "Error: VENV_PATH is not set."
    exit 1
fi

# Activate the virtual environment
if [[ -d "$VENV_PATH" ]]; then
    echo "Activating virtual environment at $VENV_PATH"
    source "$VENV_PATH/bin/activate"
else
    echo "Error: Virtual environment not found at $VENV_PATH"
    exit 1
fi

# Test if the virtual environment has been activated
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Virtual environment $VIRTUAL_ENV is activated."
else
    echo "Error: Virtual environment is not activated."
    exit 1
fi


# Test the virtual environment by checking the Python version
python_version=$(python --version 2>&1)
if [[ $? -eq 0 ]]; then
    echo "Virtual environment activated successfully. Python version: $python_version"
else
    echo "Error: Failed to activate virtual environment."
    exit 1
fi

# Deactivate the virtual environment
deactivate
echo "Virtual environment deactivated."