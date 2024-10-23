#!/usr/bin/env bash

#### Description: Installs dbt tools
#### Written by: Guillermo de Ignacio - gdeignacio on 11-2022

# Revision 2024-08-01

###################################
###   DBT INSTALL UTILS      ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./python_dbt_project.sh

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
    source $VENV_PATH/bin/activate
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

### BEGIN ###

echo off
if [[ -f help.txt ]]
then
  cat help.txt
else
  echo "help.txt no existe"
fi

if [ "$APP_PROJECT_FOLDER" == "" ]; then
  # Project dir value is empty
  echo  =================================================================
  echo    Definex la variable d\'entorn APP_PROJECT_FOLDER apuntant al
  echo    directori del projecte a generar.
  echo  =================================================================
  # End of not project section
else
  # Project dir value is informed
  echo on
  # Check if APP_FOLDER directory exists 
  if [ -d "$APP_PROJECT_FOLDER" ]; then
    ### Take action if $DIR exists ###
    echo --------- La carpeta $APP_PROJECT_FOLDER existeix  ---------
  else
    ###  Control will jump here if dir does NOT exists ###
    echo "${APP_PROJECT_FOLDER} not found. Creating ..."
    mkdir -p $APP_PROJECT_FOLDER
  fi

#cd $PROJECT_PATH/..
cd $APP_PROJECT_PATH

#dbt-init --client acme_corp --warehouse snowflake --target-dir ~/clients/

# Initialize the dbt project with all options
dbt-init --client "${DBT_CLIENT}" --warehouse "${DBT_WAREHOUSE}" --target-dir "${APP_PROJECT_FOLDER}" --profile "${DBT_PROFILE}" --project-name "${DBT_PROJECT_NAME}" --adapter "${DBT_ADAPTER}"


cd $PROJECT_PATH


### END ###

# Deactivate the virtual environment
deactivate
echo "Virtual environment deactivated."