#!/usr/bin/env bash

#### Description: Run version patch database scripts from APP_PROJECT_DB_PROPERTIES_FOLDER
####              by executing psql from docker container
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   SET DB PROPERTIES UTILS   ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./docker_bdproperties.sh

    Run version patch database scripts from APP_PROJECT_DB_PROPERTIES_FOLDER
    by executing psql from docker container

'
    exit
fi


echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Loading database..."
echo ""

# Taking values from .env file
source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

dckr=$(lib_env_utils.check_docker)
echo $dckr

DOCKER=$dckr

if [[ "${DOCKER}" == "/dev/null" ]]; then
  echo "Docker not installed. Exiting"
  exit 1
fi

APPLICATION_PATH=${APP_PROJECT_DB_PROPERTIES_FOLDER}
echo "Processing $APPLICATION_PATH"
if [ -d "$APPLICATION_PATH" ]; then
  # Copy section
  for FILE in $APPLICATION_PATH/*.sql; do
    if [[ -f "$FILE" ]]; then
      echo Loading $FILE
      ${DOCKER} exec -i ${APP_PROJECT_DOCKER_SERVER_NAME}-pg psql -v ON_ERROR_STOP=1 --username ${APP_PROJECT_DB_NAME} --dbname ${APP_PROJECT_DB_NAME} < $FILE
    fi
  done
  exit 0
else
  echo "${APPLICATION_PATH} not found"
  exit 1
fi
