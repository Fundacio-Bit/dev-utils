#!/usr/bin/env bash

#### Description: Restoring database using pg_restore
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   RESTORE UTILS             ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./pg_bdcontainerrestore.sh

    Restoring database using pg_restore

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Restoring database..."
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

echo Restoring container bd with $PG_DUMP_SCHEMA_ONLY option
${DOCKER} exec -i ${APP_PROJECT_DOCKER_SERVER_NAME}-pg pg_restore \
    $PG_DUMP_SCHEMA_ONLY \
    --format=t \
    --verbose \
    --schema=${PG_DUMP_SCHEMA} \
    --host=${PG_DUMP_HOSTNAME} \
    --port=${PG_DUMP_PORT} \
    --username=${PG_DUMP_NAME} \
    --dbname ${PG_DUMP_DBNAME} \
    ${PG_DUMP_FILENAME}